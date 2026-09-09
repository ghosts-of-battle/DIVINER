"""Every read and write against the TAC//PAC collection.

ONE PLACE THAT TOUCHES MONGO. The document ids, the legacy unwrapping, the
caching and the write guards all live here so a cog can ask for "the store" or
"the ranks" and get a plain dict, and so there is exactly one place to look when
the shape changes.

WHY THE ASYNC DRIVER IS NOT A PREFERENCE. discord.py keeps a gateway heartbeat
on the event loop. A blocking pymongo call parks that loop for the length of the
round trip to Atlas, and a few hundred milliseconds at the wrong moment is a
missed heartbeat and a reconnect. pymongo.AsyncMongoClient is the native async
client (motor is deprecated in its favour), so every call here is awaited and
nothing blocks.

WHAT THE INFRASTRUCTURE ADDS. The game's extension and the pacdb service both
store real BSON fields, with `_id` first and a BSON `updatedAt` last, stripping
both again on read. The bot reads Mongo directly, so it SEES both - and keeps
them, because `updatedAt` is exactly how it tells whether a server is live and
how the watcher knows anything changed.

THE LEGACY SHAPE. A document written before the move to real fields carries the
whole body as a JSON string in a field called `json`. Reads unwrap it. Writes
refuse it - a targeted $set against one would add a `players` field beside the
string, where the game would never look.
"""

from __future__ import annotations

import json
import logging
import re
import time
from typing import Any

from pymongo import AsyncMongoClient
from pymongo.errors import PyMongoError, ServerSelectionTimeoutError

from .config import Config
from .errors import DbDown, LegacyStore, NoStore

log = logging.getLogger(__name__)

#: Sections that are `{section, items:{id:item}}` documents.
SECTIONS = (
    "settings",
    "ranks",
    "skills",
    "awards",
    "statuses",
    "admins",
    "nets",
    "radio",
    "templates",
    "schemes",
    "promotion",
    "trainings",
)


def unwrap(doc: dict[str, Any] | None) -> dict[str, Any] | None:
    """A stored document as the mod means it.

    A legacy document is a single JSON string under `json`; that string IS the
    document and every other field on it is ignored.
    """
    if doc is None:
        return None
    legacy = doc.get("json")
    if isinstance(legacy, str):
        try:
            parsed = json.loads(legacy)
        except (ValueError, TypeError):
            log.warning("document %s has an unparsable legacy json field", doc.get("_id"))
            return None
        if isinstance(parsed, dict):
            # Carry the infrastructure fields across so liveness and the watcher
            # still work on a unit that has not been rewritten yet.
            parsed.setdefault("_id", doc.get("_id"))
            if "updatedAt" in doc:
                parsed.setdefault("updatedAt", doc["updatedAt"])
            parsed["_legacy"] = True
            return parsed
    return doc


def is_legacy(doc: dict[str, Any] | None) -> bool:
    return bool(doc and doc.get("_legacy"))


class _Cache:
    """A tiny time-to-live cache.

    Autocomplete fires on every keystroke with about three seconds to answer,
    and the roster commands re-read the same store repeatedly. Neither should
    become a round trip to Atlas.
    """

    def __init__(self, seconds: int) -> None:
        self.seconds = seconds
        self._values: dict[str, tuple[float, Any]] = {}

    def get(self, key: str) -> Any | None:
        if self.seconds <= 0:
            return None
        hit = self._values.get(key)
        if not hit:
            return None
        at, value = hit
        if time.monotonic() - at > self.seconds:
            self._values.pop(key, None)
            return None
        return value

    def put(self, key: str, value: Any) -> None:
        if self.seconds > 0:
            self._values[key] = (time.monotonic(), value)

    def drop(self, key: str | None = None) -> None:
        if key is None:
            self._values.clear()
        else:
            self._values.pop(key, None)


class Store:
    """The TAC//PAC collection, for one unit."""

    def __init__(self, cfg: Config) -> None:
        self.cfg = cfg
        self._client: AsyncMongoClient | None = None
        self._cache = _Cache(cfg.cache_seconds)

    # ------------------------------------------------------------ connection
    @property
    def client(self) -> AsyncMongoClient:
        if self._client is None:
            self._client = AsyncMongoClient(
                self.cfg.mongo_uri,
                # Fail in five seconds, not the thirty-second default: a command
                # that cannot answer should say so inside the interaction's life.
                serverSelectionTimeoutMS=5000,
                connectTimeoutMS=5000,
                appname="pacbot",
                tz_aware=True,
            )
        return self._client

    @property
    def collection(self):
        return self.client[self.cfg.mongo_db][self.cfg.mongo_collection]

    async def close(self) -> None:
        if self._client is not None:
            await self._client.close()
            self._client = None

    async def ping(self) -> str:
        """A startup self-test. Returns a line for the console either way."""
        try:
            await self.client.admin.command("ping")
        except ServerSelectionTimeoutError as exc:
            return f"database UNREACHABLE ({_short(exc)})"
        except PyMongoError as exc:
            return f"database ERROR ({_short(exc)})"
        return f"database ok ({self.cfg.mongo_db}/{self.cfg.mongo_collection})"

    # ------------------------------------------------------------------ reads
    async def _one(self, doc_id: str) -> dict[str, Any] | None:
        try:
            return unwrap(await self.collection.find_one({"_id": doc_id}))
        except ServerSelectionTimeoutError as exc:
            raise DbDown(_short(exc)) from exc
        except PyMongoError as exc:
            raise DbDown(_short(exc)) from exc

    async def store(self, *, cached: bool = True) -> dict[str, Any]:
        """The store document. Raises NoStore when the unit has none."""
        key = "store"
        if cached:
            hit = self._cache.get(key)
            if hit is not None:
                return hit
        doc = await self._one(self.cfg.doc_id())
        if doc is None:
            raise NoStore(self.cfg.unit_id)
        self._cache.put(key, doc)
        return doc

    async def store_or_none(self) -> dict[str, Any] | None:
        try:
            return await self.store()
        except NoStore:
            return None

    async def section(self, name: str, *, cached: bool = True) -> dict[str, Any]:
        """One section's items, keyed by id. Missing section is an empty map."""
        key = f"section:{name}"
        if cached:
            hit = self._cache.get(key)
            if hit is not None:
                return hit
        doc = await self._one(self.cfg.doc_id(name))
        items = (doc or {}).get("items") or {}
        if not isinstance(items, dict):
            items = {}
        # The admins document also carries a plain `ids` array, edited on the
        # database site by people who never open the game. Fold it in the way
        # fnc_svcStructure does, so both halves are one list here too.
        if name == "admins" and doc:
            for uid in doc.get("ids") or []:
                uid = str(uid)
                items.setdefault(uid, {"id": uid, "name": ""})
        self._cache.put(key, items)
        return items

    async def settings(self) -> dict[str, Any]:
        return await self.section("settings")

    async def roles(self, *, cached: bool = True) -> dict[str, Any]:
        """Every role, one document each, tombstones skipped."""
        key = "roles"
        if cached:
            hit = self._cache.get(key)
            if hit is not None:
                return hit
        out: dict[str, Any] = {}
        async for doc in self._prefix(self.cfg.doc_id("role") + "."):
            doc = unwrap(doc) or {}
            if doc.get("deleted"):
                continue  # a role removed in game leaves a tombstone behind
            rid = doc.get("id") or str(doc.get("_id", "")).rsplit(".", 1)[-1]
            role = doc.get("role")
            if rid and isinstance(role, dict):
                out[rid] = role
        self._cache.put(key, out)
        return out

    async def opords(self, *, cached: bool = True) -> dict[str, Any]:
        key = "opords"
        if cached:
            hit = self._cache.get(key)
            if hit is not None:
                return hit
        out: dict[str, Any] = {}
        async for doc in self._prefix(self.cfg.doc_id("opord") + "."):
            doc = unwrap(doc) or {}
            oid = doc.get("id") or str(doc.get("_id", "")).rsplit(".", 1)[-1]
            order = doc.get("order")
            if oid and isinstance(order, dict):
                out[oid] = order
        self._cache.put(key, out)
        return out

    async def orbat(self) -> dict[str, Any]:
        return (await self._one(self.cfg.doc_id("orbat"))) or {}

    async def current_opord_id(self) -> str:
        """Which order is on.

        It lives in two places. Under sync = "service" the settings document
        wins at boot, so it wins here; the store's own copy is the fallback for
        a unit running from its profile.
        """
        settings = await self.settings()
        current = settings.get("currentOpord")
        if isinstance(current, str) and current:
            return current
        store = await self.store_or_none() or {}
        edited = (store.get("structureEdited") or {}).get("_settings") or {}
        current = edited.get("currentOpord")
        return current if isinstance(current, str) else ""

    async def _prefix(self, prefix: str):
        """Every document whose id starts with `prefix`."""
        pattern = "^" + re.escape(prefix)
        try:
            async for doc in self.collection.find({"_id": {"$regex": pattern}}):
                yield doc
        except ServerSelectionTimeoutError as exc:
            raise DbDown(_short(exc)) from exc
        except PyMongoError as exc:
            raise DbDown(_short(exc)) from exc

    async def document_ids(self) -> list[str]:
        """Every document id for this unit - what `/pac status` shows when the
        store is missing, because a wrong unit id is by far the likeliest cause
        and this makes it obvious at a glance."""
        ids: list[str] = []
        pattern = "^" + re.escape(self.cfg.unit_id)
        try:
            async for doc in self.collection.find(
                {"_id": {"$regex": pattern}}, {"_id": 1}
            ):
                ids.append(str(doc["_id"]))
        except PyMongoError as exc:
            raise DbDown(_short(exc)) from exc
        return sorted(ids)

    def invalidate(self, key: str | None = None) -> None:
        self._cache.drop(key)

    # ----------------------------------------------------------------- writes
    async def assert_writable(self) -> dict[str, Any]:
        """The store, checked for the things that make a write unsafe."""
        store = await self.store(cached=False)
        if is_legacy(store):
            raise LegacyStore(self.cfg.unit_id)
        return store

    async def update_record(
        self,
        uid: str,
        sets: dict[str, Any],
        *,
        seen_updated_at: Any,
        pushes: dict[str, Any] | None = None,
    ) -> bool:
        """A targeted write to one record, guarded against a concurrent change.

        NEVER A DOCUMENT REPLACE, and never an upsert. The narrower the write
        and the shorter its life, the less of it a game server's next save can
        take away - and upsert=False means a mistyped unit id can only fail,
        never quietly create a second empty roster.

        The filter carries the record's `updatedAt` as we last read it. If the
        game (or another admin) wrote in between, nothing matches and the caller
        is told to try again rather than overwriting somebody's change.

        Returns False when the guard did not match.
        """
        criteria: dict[str, Any] = {
            "_id": self.cfg.doc_id(),
            f"players.{uid}": {"$exists": True},
        }
        # A record with no updatedAt at all is legal on an old store, so only
        # guard on it when there is one to guard on.
        if seen_updated_at not in (None, ""):
            criteria[f"players.{uid}.updatedAt"] = seen_updated_at

        update: dict[str, Any] = {"$set": sets}
        if pushes:
            update["$push"] = pushes

        try:
            result = await self.collection.update_one(criteria, update, upsert=False)
        except ServerSelectionTimeoutError as exc:
            raise DbDown(_short(exc)) from exc
        except PyMongoError as exc:
            raise DbDown(_short(exc)) from exc

        self.invalidate("store")
        return result.matched_count > 0

    async def read_field(self, uid: str, field: str) -> Any:
        """One field, straight from the database - the verify-after-write read."""
        try:
            doc = await self.collection.find_one(
                {"_id": self.cfg.doc_id()}, {f"players.{uid}.{field}": 1}
            )
        except PyMongoError as exc:
            raise DbDown(_short(exc)) from exc
        record = ((doc or {}).get("players") or {}).get(uid) or {}
        return record.get(field)

    # ------------------------------------------------------- the bot's own doc
    async def state(self) -> dict[str, Any]:
        """The watcher's cursor document.

        Its id sits outside the section names and the `role.` / `opord.`
        prefixes that the mod and pac_sync.py scan, so nothing in the game ever
        reads or writes it. That also means writing it carries none of the
        overwrite risk that a record write does.
        """
        return (await self._one(self.cfg.state_doc_id)) or {}

    async def save_state(self, state: dict[str, Any]) -> None:
        body = {k: v for k, v in state.items() if k not in ("_id", "_legacy")}
        body["section"] = "discordbot"
        try:
            await self.collection.update_one(
                {"_id": self.cfg.state_doc_id}, {"$set": body}, upsert=True
            )
        except PyMongoError as exc:
            raise DbDown(_short(exc)) from exc


def _short(exc: Exception) -> str:
    """The first line of a driver error - they run to paragraphs."""
    text = str(exc).replace("\n", " ").strip()
    return text[:200] + ("..." if len(text) > 200 else "")
