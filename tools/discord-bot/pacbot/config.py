"""Every setting the bot has, read once from the environment.

WHY ENVIRONMENT VARIABLES AND NOTHING ELSE. The bot runs as a Pelican egg, and
an egg's only way to configure a server is the environment. A config file would
be a second source of truth that the panel cannot edit.

WHY THE PACBOT_ PREFIX. Pelican injects SERVER_MEMORY, SERVER_IP, SERVER_PORT
and friends into every container. A bare MONGO_URI or TOKEN would sit in the
same namespace as those and as whatever the next panel version adds.

FAIL FAST, IN ONE LINE. A missing token must stop the process with a sentence
naming the variable, not a traceback five seconds later inside discord.py. The
Pelican console is the only diagnostic surface this thing has, and a panel set
to restart on crash will scroll a traceback away in seconds.
"""

from __future__ import annotations

import os
from dataclasses import dataclass, field

from .errors import ConfigError

PREFIX = "PACBOT_"

#: Printed on ready, and matched by the egg's `config.startup.done`. The panel
#: shows the server as running when it sees this, so the bot prints it only
#: after the command tree is synced - "running" then means "commands work".
READY_LINE = "PACBOT READY"


def _raw(name: str, default: str | None = None) -> str | None:
    return os.environ.get(PREFIX + name, default)


def _text(name: str, default: str = "") -> str:
    return (_raw(name) or default).strip()


def _required(name: str) -> str:
    value = _text(name)
    if not value:
        raise ConfigError(
            f"{PREFIX}{name} is not set. The bot cannot start without it."
        )
    return value


def _int(name: str, default: int, low: int | None = None, high: int | None = None) -> int:
    raw = _text(name)
    if not raw:
        return default
    try:
        value = int(raw)
    except ValueError:
        raise ConfigError(f"{PREFIX}{name} must be a whole number, not {raw!r}.") from None
    if low is not None and value < low:
        value = low
    if high is not None and value > high:
        value = high
    return value


def _bool(name: str, default: bool) -> bool:
    raw = _text(name).lower()
    if not raw:
        return default
    if raw in ("1", "true", "yes", "on"):
        return True
    if raw in ("0", "false", "no", "off"):
        return False
    raise ConfigError(f"{PREFIX}{name} must be true or false, not {raw!r}.")


def _snowflake(name: str, required: bool = False) -> int | None:
    """One Discord id. They are 64-bit and must never be floats."""
    raw = _text(name)
    if not raw:
        if required:
            raise ConfigError(f"{PREFIX}{name} is not set. The bot cannot start without it.")
        return None
    if not raw.isdigit():
        raise ConfigError(f"{PREFIX}{name} must be a Discord id (digits only), not {raw!r}.")
    return int(raw)


def _snowflakes(name: str) -> frozenset[int]:
    """A comma-separated list of Discord ids. Empty is allowed and meaningful."""
    raw = _text(name)
    if not raw:
        return frozenset()
    out: set[int] = set()
    for part in raw.replace(";", ",").split(","):
        part = part.strip()
        if not part:
            continue
        if not part.isdigit():
            raise ConfigError(
                f"{PREFIX}{name} must be Discord ids separated by commas; {part!r} is not one."
            )
        out.add(int(part))
    return frozenset(out)


def _words(name: str, default: str) -> frozenset[str]:
    raw = _text(name, default)
    return frozenset(w.strip().lower() for w in raw.replace(";", ",").split(",") if w.strip())


@dataclass(frozen=True)
class Config:
    # --- required -----------------------------------------------------------
    token: str
    guild_id: int
    mongo_uri: str

    # --- where the data is --------------------------------------------------
    mongo_db: str = "ghostd"
    mongo_collection: str = "pac"
    unit_id: str = "framework"
    #: Stamped into every record the bot writes, so a merged store says which
    #: writer made the change. The game stamps its own settings.serverId here.
    server_id: str = "discord"

    # --- who may do what ----------------------------------------------------
    staff_role_ids: frozenset[int] = frozenset()
    command_role_ids: frozenset[int] = frozenset()
    owner_ids: frozenset[int] = frozenset()
    require_pac_admin: bool = False

    # --- channels -----------------------------------------------------------
    announce_channel_id: int | None = None
    opord_channel_id: int | None = None
    staff_log_channel_id: int | None = None
    link_request_channel_id: int | None = None
    staff_log_note_text: bool = False

    # --- writing ------------------------------------------------------------
    writes_enabled: bool = True
    refuse_writes_when_live: bool = False
    live_window_minutes: int = 20
    idle_minutes: int = 30

    # --- the watcher --------------------------------------------------------
    watch_enabled: bool = True
    poll_seconds: int = 60
    announce_types: frozenset[str] = frozenset({"rank", "award"})
    announce_max_per_tick: int = 5

    # --- odds and ends ------------------------------------------------------
    cache_seconds: int = 20
    state_doc_id: str = ""
    attendance_threshold: float = 60.0
    embed_colour: int = 0x39FF7A
    log_level: str = "INFO"

    @classmethod
    def from_env(cls) -> "Config":
        unit = _text("UNIT_ID", "framework")
        if not unit:
            raise ConfigError(f"{PREFIX}UNIT_ID cannot be empty.")

        threshold_raw = _text("ATTENDANCE_THRESHOLD", "60")
        try:
            threshold = float(threshold_raw)
        except ValueError:
            raise ConfigError(
                f"{PREFIX}ATTENDANCE_THRESHOLD must be a number, not {threshold_raw!r}."
            ) from None

        colour_raw = _text("EMBED_COLOR") or _text("EMBED_COLOUR") or "0x39FF7A"
        try:
            colour = int(colour_raw, 0)
        except ValueError:
            raise ConfigError(
                f"{PREFIX}EMBED_COLOR must be a colour like 0x39FF7A, not {colour_raw!r}."
            ) from None

        level = _text("LOG_LEVEL", "INFO").upper()
        if level not in ("DEBUG", "INFO", "WARNING", "ERROR"):
            raise ConfigError(
                f"{PREFIX}LOG_LEVEL must be DEBUG, INFO, WARNING or ERROR, not {level!r}."
            )

        return cls(
            token=_required("DISCORD_TOKEN"),
            guild_id=_snowflake("GUILD_ID", required=True),  # type: ignore[arg-type]
            mongo_uri=_required("MONGO_URI"),
            mongo_db=_text("MONGO_DB", "ghostd"),
            mongo_collection=_text("MONGO_COLLECTION", "pac"),
            unit_id=unit,
            server_id=_text("SERVER_ID", "discord"),
            staff_role_ids=_snowflakes("STAFF_ROLE_IDS"),
            command_role_ids=_snowflakes("COMMAND_ROLE_IDS"),
            owner_ids=_snowflakes("OWNER_IDS"),
            require_pac_admin=_bool("REQUIRE_PAC_ADMIN", False),
            announce_channel_id=_snowflake("ANNOUNCE_CHANNEL_ID"),
            opord_channel_id=_snowflake("OPORD_CHANNEL_ID"),
            staff_log_channel_id=_snowflake("STAFF_LOG_CHANNEL_ID"),
            link_request_channel_id=_snowflake("LINK_REQUEST_CHANNEL_ID"),
            staff_log_note_text=_bool("STAFF_LOG_NOTE_TEXT", False),
            writes_enabled=_bool("WRITES_ENABLED", True),
            refuse_writes_when_live=_bool("REFUSE_WRITES_WHEN_LIVE", False),
            live_window_minutes=_int("LIVE_WINDOW_MINUTES", 20, low=1),
            idle_minutes=_int("IDLE_MINUTES", 30, low=1),
            watch_enabled=_bool("WATCH_ENABLED", True),
            # Floor of 15 s: the store only changes on SAVE, logon, logoff and
            # mission end, so polling faster buys nothing and costs connections.
            poll_seconds=_int("POLL_SECONDS", 60, low=15, high=3600),
            announce_types=_words("ANNOUNCE_TYPES", "rank,award"),
            announce_max_per_tick=_int("ANNOUNCE_MAX_PER_TICK", 5, low=1, high=25),
            cache_seconds=_int("CACHE_SECONDS", 20, low=0, high=600),
            state_doc_id=_text("STATE_DOC_ID") or f"{unit}.discordbot",
            attendance_threshold=threshold,
            embed_colour=colour,
            log_level=level,
        )

    # ------------------------------------------------------------------ views
    @property
    def opord_channel(self) -> int | None:
        """Where an order goes. Falls back to the announce channel."""
        return self.opord_channel_id or self.announce_channel_id

    def doc_id(self, *parts: str) -> str:
        """A document id under this unit: doc_id() -> 'framework',
        doc_id('ranks') -> 'framework.ranks',
        doc_id('role', 'rifleman') -> 'framework.role.rifleman'."""
        return ".".join((self.unit_id, *parts)) if parts else self.unit_id

    def summary(self) -> str:
        """One line for the console, so a misconfigured server is obvious."""
        writes = "ON" if self.writes_enabled else "OFF"
        announce = self.announce_channel_id or "none"
        return (
            f"unit={self.unit_id} db={self.mongo_db}/{self.mongo_collection} "
            f"writes={writes} staff_roles={len(self.staff_role_ids)} "
            f"announce={announce} poll={self.poll_seconds}s "
            f"pac_admin_check={'on' if self.require_pac_admin else 'off'}"
        )
