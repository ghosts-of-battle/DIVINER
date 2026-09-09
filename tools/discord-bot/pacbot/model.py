"""Reading a record without tripping over its shape.

TWO THINGS THIS FILE EXISTS FOR.

First, the positional arrays. A record's awards, training, qualifications and
admin actions are all arrays-of-arrays in BSON, and their lengths are not
guaranteed: a training row written before the course catalogue existed has three
elements, not four, and an old record may carry no `qualifications` at all. Every
decoder here reads defensively by position and never subscripts blindly.

Second, and more important: PUBLIC AND STAFF VIEWS ARE DIFFERENT TYPES.

`notes` is obviously private - an admin writes it about a player. What is not
obvious, and what a reasonable person would leak by accident, is that
`adminActions` is just as private: fnc_adminSet's noteAdd passes the note's text
into fnc_logAction, which copies it into the record's adminActions row. So the
note text exists in two places on the record, and hiding only `notes` would
publish it anyway.

So `PublicRecord` is built from an explicit allow-list and simply has no field
for either. The renderer for public embeds accepts a PublicRecord and nothing
else, which means a field added to the schema later cannot leak by being
forgotten - it has to be added to the allow-list on purpose.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Sequence


def _s(row: Sequence[Any], i: int, default: str = "") -> str:
    """One string out of a positional row, whatever its length."""
    if row is None or i >= len(row):
        return default
    value = row[i]
    return value if isinstance(value, str) else (default if value is None else str(value))


@dataclass(frozen=True)
class Award:
    award_id: str
    at: str
    by: str
    citation: str

    @classmethod
    def of(cls, row: Sequence[Any]) -> "Award":
        # [awardId, dateStamp, byName, citation]
        return cls(_s(row, 0), _s(row, 1), _s(row, 2), _s(row, 3))


@dataclass(frozen=True)
class Training:
    at: str
    by: str
    text: str
    course_id: str

    @classmethod
    def of(cls, row: Sequence[Any]) -> "Training":
        # [dateStamp, byName, text, courseId] - courseId absent on older rows,
        # which is why this is a four-field read of a possibly-three-long array.
        return cls(_s(row, 0), _s(row, 1), _s(row, 2), _s(row, 3))


@dataclass(frozen=True)
class Qualification:
    skill_id: str
    name: str
    earned: str

    @classmethod
    def of(cls, row: Sequence[Any]) -> "Qualification":
        # [skillId, name, dateEarned]
        return cls(_s(row, 0), _s(row, 1), _s(row, 2))


@dataclass(frozen=True)
class Note:
    at: str
    by: str
    text: str

    @classmethod
    def of(cls, row: Sequence[Any]) -> "Note":
        # [dateStamp, byName, text]
        return cls(_s(row, 0), _s(row, 1), _s(row, 2))


@dataclass(frozen=True)
class AdminAction:
    log_id: str
    kind: str
    at: str
    by_uid: str
    by_name: str
    notes: str

    @classmethod
    def of(cls, row: Sequence[Any]) -> "AdminAction":
        # [logId, type, dateStamp, byUid, byName, notes]
        return cls(_s(row, 0), _s(row, 1), _s(row, 2), _s(row, 3), _s(row, 4), _s(row, 5))


@dataclass(frozen=True)
class LogRow:
    log_id: str
    at: str
    by_uid: str
    by_name: str
    kind: str
    target_uid: str
    target_name: str
    detail: str

    @classmethod
    def of(cls, row: Sequence[Any]) -> "LogRow":
        # [logId, dateStamp, byUid, byName, type, targetUid, targetName, detail]
        return cls(
            _s(row, 0), _s(row, 1), _s(row, 2), _s(row, 3),
            _s(row, 4), _s(row, 5), _s(row, 6), _s(row, 7),
        )


@dataclass(frozen=True)
class Window:
    window_id: str
    name: str
    started: str
    ended: str
    source: str

    @classmethod
    def of(cls, row: Sequence[Any]) -> "Window":
        # [id, name, startedAt, endedAt, source]
        return cls(_s(row, 0), _s(row, 1), _s(row, 2), _s(row, 3), _s(row, 4))

    @property
    def open(self) -> bool:
        return not self.ended.strip()


@dataclass(frozen=True)
class Session:
    uid: str
    name: str
    joined: str
    last_seen: str
    left: str
    window_id: str

    @classmethod
    def of(cls, row: Sequence[Any]) -> "Session":
        # [uid, name, joinedAt, lastSeenAt, leftAt, windowId]
        return cls(_s(row, 0), _s(row, 1), _s(row, 2), _s(row, 3), _s(row, 4), _s(row, 5))

    @property
    def open(self) -> bool:
        return not self.left.strip()


# ---------------------------------------------------------------- the record
#: Everything a player may see about anybody, including themselves. Anything
#: not on this list does not reach a public reply, and the two omissions that
#: matter are deliberate: `notes`, and `adminActions` because it carries the
#: note text too. `loadouts` is left off for a different reason - it is
#: kilobytes of gear per role and nothing renders it.
PUBLIC_FIELDS = (
    "name",
    "operatorId",
    "milsimName",
    "discordId",
    "enlistedAt",
    "rankId",
    "promotedAt",
    "statusId",
    "company",
    "groupId",
    "roleId",
    "reportsTo",
    "skillIds",
    "qualifications",
    "awards",
    "training",
    "excused",
    "updatedAt",
)


@dataclass(frozen=True)
class PublicRecord:
    """A record with the private fields structurally absent.

    Not a filtered dict - a different type, so a renderer that takes one of
    these cannot be handed a raw record by mistake.
    """

    uid: str
    data: dict[str, Any] = field(default_factory=dict)

    @classmethod
    def of(cls, uid: str, record: dict[str, Any]) -> "PublicRecord":
        return cls(uid, {k: record.get(k) for k in PUBLIC_FIELDS if k in record})

    # convenience readers -----------------------------------------------------
    def get(self, key: str, default: Any = None) -> Any:
        return self.data.get(key, default)

    @property
    def name(self) -> str:
        return str(self.data.get("name") or "")

    @property
    def operator_id(self) -> str:
        return str(self.data.get("operatorId") or "")

    @property
    def rank_id(self) -> str:
        return str(self.data.get("rankId") or "")

    @property
    def role_id(self) -> str:
        return str(self.data.get("roleId") or "")

    @property
    def group_id(self) -> str:
        return str(self.data.get("groupId") or "")

    @property
    def status_id(self) -> str:
        return str(self.data.get("statusId") or "")

    @property
    def discord_id(self) -> str:
        return str(self.data.get("discordId") or "")

    @property
    def skill_ids(self) -> list[str]:
        return [s for s in (self.data.get("skillIds") or []) if isinstance(s, str)]

    @property
    def awards(self) -> list[Award]:
        return [Award.of(r) for r in (self.data.get("awards") or []) if r]

    @property
    def training(self) -> list[Training]:
        return [Training.of(r) for r in (self.data.get("training") or []) if r]

    @property
    def qualifications(self) -> list[Qualification]:
        """Ever-granted skills, with the day.

        An old record has none, and the game synthesises them from the skills
        held now with no date rather than showing nothing - reproduce that, or
        the two screens disagree about an operator's history.
        """
        rows = self.data.get("qualifications") or []
        if rows:
            return [Qualification.of(r) for r in rows if r]
        return [Qualification(s, "", "") for s in self.skill_ids]


def notes_of(record: dict[str, Any]) -> list[Note]:
    """Staff only. Never call this from a public renderer."""
    return [Note.of(r) for r in (record.get("notes") or []) if r]


def admin_actions_of(record: dict[str, Any]) -> list[AdminAction]:
    """Staff only - these carry note text. Never call this from a public
    renderer."""
    return [AdminAction.of(r) for r in (record.get("adminActions") or []) if r]


# ------------------------------------------------------------------ lookups
def lookup(items: dict[str, Any], item_id: str, field_name: str = "name") -> str:
    """A structure item's name, or a marked-unknown id.

    An id the structure has lost is shown, marked, rather than rendered blank -
    the same idea as the admin page's orphan list. A blank would read as "this
    operator has no rank"; `sergent (unknown)` reads as the typo it is.
    """
    if not item_id:
        return ""
    item = items.get(item_id)
    if isinstance(item, dict):
        value = item.get(field_name)
        if isinstance(value, str) and value:
            return value
    return f"{item_id} (unknown)"


def platoon_of(orbat: dict[str, Any], group_id: str) -> str:
    """The platoon a squad belongs to.

    Matched case-insensitively on the squad name, the way fnc_operatorJson does
    it - `groupId` is free text typed by an admin, not an id.
    """
    if not group_id:
        return ""
    wanted = group_id.strip().upper()
    for row in orbat.get("platoons") or []:
        if len(row) < 5:
            continue
        _pid, name, callsign, _net, squads = (list(row) + [None] * 5)[:5]
        for squad in squads or []:
            if isinstance(squad, str) and squad.strip().upper() == wanted:
                return name or callsign or ""
    return ""


def rank_order(promotion: dict[str, Any], ranks: dict[str, Any]) -> dict[str, float]:
    """A sort key per rank id, best effort.

    THERE IS NO SORT FIELD ON A RANK. Items carry abbrev, payGrade, armaRank and
    insignia and nothing that says which outranks which. The promotion section's
    `rank_<id>` thresholds are a total order the unit already maintains, so use
    those; fall back to pay grade as text, then to the order the document
    happens to be in.
    """
    order: dict[str, float] = {}
    for index, rank_id in enumerate(ranks):
        item = promotion.get(f"rank_{rank_id}")
        value: float | None = None
        if isinstance(item, dict):
            raw = item.get("value")
            if isinstance(raw, (int, float)) and not isinstance(raw, bool):
                value = float(raw)
            elif isinstance(raw, str):
                try:
                    value = float(raw.strip())
                except ValueError:
                    value = None
        order[rank_id] = value if value is not None else float(index)
    return order
