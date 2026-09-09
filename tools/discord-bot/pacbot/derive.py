"""The numbers the game computes and never stores.

Attendance and promotion points exist nowhere in the database: TAC//PAC works
them out from the sessions and the windows every time it draws a screen. So the
bot has to do the same arithmetic, and if it does it even slightly differently
the two disagree in front of the unit and nobody knows which to believe.

Everything here mirrors a named SQF function, and the mirrors are exact on
purpose:

    attendance_of    <- addons/pac/functions/fnc_attendanceOf.sqf
    promotion_points <- addons/pac/functions/fnc_promotionPoints.sqf
    session_minutes  <- the [leftAt or lastSeenAt] - joinedAt convention used in
                        fnc_publish, fnc_promotionPoints and fnc_attendanceReport

NOTHING HERE IMPORTS DISCORD. It is plain functions over plain dicts and lists,
so it can be tested against a snapshot of the real store with no Discord
connection and no database - which is the only way to keep it honest as the SQF
moves.

TWO ROUNDING TRAPS, both of which silently produce numbers a player will argue
about:

  * SQF's `round` is half-away-from-zero. Python's built-in `round` is
    half-to-even, so round(2.5) is 2 in Python and 3 in SQF. Use sqf_round().
  * The quantities stay fractional and only the TOTAL is rounded, exactly as
    fnc_promotionPoints does. Rounding each term first drifts by whole points.
"""

from __future__ import annotations

import math
import re
from datetime import datetime, timezone
from typing import Any, Iterable, Sequence

#: The one timestamp format the whole system uses, always UTC, never with a
#: zone marker on it - see fnc_stamp.sqf.
STAMP = "%Y-%m-%d %H:%M:%S"
_STAMP_RE = re.compile(r"^\d{4}-\d{2}-\d{2}[ T]\d{2}:\d{2}(:\d{2})?")


# --------------------------------------------------------------------- clocks
def utcnow() -> datetime:
    return datetime.now(timezone.utc)


def stamp_now() -> str:
    """A full stamp, the way fnc_stamp writes one."""
    return utcnow().strftime(STAMP)


def today() -> str:
    """A date-only stamp, the way the mod truncates one: the first 10 chars."""
    return utcnow().strftime("%Y-%m-%d")


def parse_stamp(value: Any) -> datetime | None:
    """A stored stamp as an aware UTC datetime, or None if it is not one.

    Accepts the full "YYYY-MM-DD HH:MM:SS", the "YYYY-MM-DD HH:MM" that
    settings.opWindows entries use, and a bare "YYYY-MM-DD" date - a back-dated
    training row carries one of those, and so does every date-only field.

    PARSED AS UTC EXPLICITLY. The stamps carry no zone, and the container's
    local time must never be allowed to change what a date means.
    """
    if isinstance(value, datetime):
        return value if value.tzinfo else value.replace(tzinfo=timezone.utc)
    if not isinstance(value, str):
        return None
    text = value.strip()
    if not text:
        return None
    if not _STAMP_RE.match(text):
        # A bare date is the other legal shape.
        try:
            return datetime.strptime(text[:10], "%Y-%m-%d").replace(tzinfo=timezone.utc)
        except ValueError:
            return None
    text = text.replace("T", " ")
    for fmt in (STAMP, "%Y-%m-%d %H:%M"):
        try:
            return datetime.strptime(text[: len(fmt) + 2], fmt).replace(tzinfo=timezone.utc)
        except ValueError:
            continue
    try:
        return datetime.strptime(text[:10], "%Y-%m-%d").replace(tzinfo=timezone.utc)
    except ValueError:
        return None


def _minutes(value: Any) -> int | None:
    """A stamp as whole minutes, seconds discarded.

    fnc_stampMinutes works in minutes, so two stamps a few seconds apart are the
    same minute to the game. Truncating each stamp before subtracting - rather
    than subtracting and then truncating - is what reproduces that.
    """
    at = parse_stamp(value)
    if at is None:
        return None
    return int(at.timestamp() // 60)


def _midnight_minutes(value: Any) -> int | None:
    """The start of the day a stamp falls on, in minutes.

    The mod writes `(_from select [0, 10]) + " 00:00"`, i.e. it takes the date
    part and pins it to midnight, which is what makes "days since" whole days
    rather than a fraction of the current one.
    """
    at = parse_stamp(value)
    if at is None:
        return None
    return int(at.replace(hour=0, minute=0, second=0, microsecond=0).timestamp() // 60)


def sqf_round(value: float) -> int:
    """SQF's round: half away from zero, not Python's half to even."""
    return int(math.floor(value + 0.5)) if value >= 0 else -int(math.floor(-value + 0.5))


def days_since(value: Any, *, now: datetime | None = None) -> int:
    """Whole days from a date to today, floored at zero.

    Mirrors _fnc_days inside fnc_promotionPoints: floor((now - midnight) / 1440),
    max 0. A missing or unparsable date is 0, not an error - an old record may
    have no enlistment date at all.
    """
    if not isinstance(value, str) or len(value.strip()) < 10:
        return 0
    start = _midnight_minutes(value)
    if start is None:
        return 0
    end = int((now or utcnow()).timestamp() // 60)
    return max(math.floor((end - start) / 1440), 0)


# ------------------------------------------------------------------- sessions
def session_minutes(row: Sequence[Any]) -> int:
    """One session row's length in minutes, floored at zero.

    `end = leftAt or lastSeenAt`. An open row (empty leftAt) is counted to its
    last heartbeat, which is what every reader in the mod does - and note that
    fnc_sessionTick writes nothing to the database, so lastSeenAt on a live
    session is only as fresh as the last logon, logoff or SAVE.
    """
    joined = _minutes(row[2] if len(row) > 2 else None)
    if joined is None:
        return 0
    left = row[4] if len(row) > 4 else ""
    seen = row[3] if len(row) > 3 else ""
    end = _minutes(left if isinstance(left, str) and left.strip() else seen)
    if end is None:
        return 0
    return max(end - joined, 0)


def total_minutes(sessions: Iterable[Sequence[Any]], uid: str) -> int:
    """All time on the server for one operator, every session, all time."""
    return sum(session_minutes(row) for row in sessions if _row_uid(row) == uid)


def session_joins(sessions: Iterable[Sequence[Any]], uid: str) -> int:
    return sum(1 for row in sessions if _row_uid(row) == uid)


def _row_uid(row: Sequence[Any]) -> str:
    return row[0] if row and isinstance(row[0], str) else ""


def _row_window(row: Sequence[Any]) -> str:
    return row[5] if len(row) > 5 and isinstance(row[5], str) else ""


# ----------------------------------------------------------------- attendance
def scheduled_windows(windows: Iterable[Sequence[Any]], since: Any) -> list[str]:
    """The window ids that count as scheduled for somebody enlisted on `since`.

    A window counts when it is CLOSED (it has an endedAt) and it started on or
    after the enlistment date. An empty enlistment date means every closed
    window counts, which is what a zero floor gives us in the SQF too.
    """
    floor_min = _midnight_minutes(since) if isinstance(since, str) and since.strip() else 0
    if floor_min is None:
        floor_min = 0
    out: list[str] = []
    for row in windows:
        if len(row) < 4:
            continue
        wid, started, ended = row[0], row[2], row[3]
        if not isinstance(ended, str) or not ended.strip():
            continue  # still open, so not yet an operation anybody missed
        started_min = _minutes(started)
        if started_min is None or started_min < floor_min:
            continue
        if isinstance(wid, str) and wid:
            out.append(wid)
    return out


def attendance_of(
    record: dict[str, Any],
    sessions: Sequence[Sequence[Any]],
    windows: Sequence[Sequence[Any]],
    uid: str,
) -> dict[str, Any]:
    """One operator's attendance. Mirrors fnc_attendanceOf.sqf.

    ONLY MANUAL WINDOWS EVER COUNT, and that is a property of the data rather
    than a choice made here: only the START/STOP button writes a row to
    `windows`. A session stamped `cfg:...` or `opord:...` carries a window id
    that is not a row, so it can be neither attended nor scheduled. A unit that
    never presses START reads 0/0 for everybody, so the caller is told whether
    that is what happened - see `unscheduled`.
    """
    ids = scheduled_windows(windows, record.get("enlistedAt", ""))
    id_set = set(ids)

    attended: list[str] = []
    for row in sessions:
        if _row_uid(row) != uid:
            continue
        wid = _row_window(row)
        if wid in id_set and wid not in attended:
            attended.append(wid)

    excused_raw = record.get("excused") or []
    excused = [w for w in excused_raw if w in id_set and w not in attended]

    scheduled = len(ids)
    on = len(attended)
    loa = len(excused)
    awol = max(scheduled - on - loa, 0)
    pct = (sqf_round(on / scheduled * 1000) / 10) if scheduled > 0 else 0.0

    # Did this operator turn up to things the unit never recorded as windows?
    # If so, 0/0 is a bookkeeping artefact and not an absence record.
    tagged_but_unscheduled = sum(
        1
        for row in sessions
        if _row_uid(row) == uid and _row_window(row) and _row_window(row) not in id_set
    )

    return {
        "scheduled": scheduled,
        "attended": on,
        "excused": loa,
        "unexcused": awol,
        "percentage": pct,
        "attended_ids": attended,
        "excused_ids": excused,
        "scheduled_ids": ids,
        "unscheduled": tagged_but_unscheduled,
    }


# ------------------------------------------------------------------ promotion
#: The six weights, in the order fnc_promotionPoints lists them in its
#: breakdown. The labels are the SQF's own, so a breakdown printed here and one
#: printed in game read the same.
WEIGHT_KEYS: tuple[tuple[str, str], ...] = (
    ("hours", "hour"),
    ("ops", "op"),
    ("service months", "serviceMonth"),
    ("grade months", "gradeMonth"),
    ("training", "training"),
    ("awards", "award"),
)


def weight_of(promotion: dict[str, Any], key: str) -> float:
    """One weight out of the promotion section.

    Every item is {name, value}; the item's id says what the value means. A
    string value is parsed, anything else unusable is zero - the same
    forgiveness _fnc_weight shows, because these are typed by hand in game.
    """
    item = promotion.get(key)
    if not isinstance(item, dict):
        return 0.0
    value = item.get("value", 0)
    if isinstance(value, bool):
        return 0.0
    if isinstance(value, (int, float)):
        return float(value)
    if isinstance(value, str):
        try:
            return float(value.strip())
        except ValueError:
            return 0.0
    return 0.0


def promotion_points(
    record: dict[str, Any],
    sessions: Sequence[Sequence[Any]],
    windows: Sequence[Sequence[Any]],
    promotion: dict[str, Any],
    uid: str,
) -> dict[str, Any]:
    """Promotion points and the next rung. Mirrors fnc_promotionPoints.sqf.

        points = round(hours*hour + ops*op + serviceMonths*serviceMonth
                     + gradeMonths*gradeMonth + training*training
                     + awards*award)

    The quantities are fractional (hours = minutes/60, months = days/30) and
    only the sum is rounded.
    """
    minutes = total_minutes(sessions, uid)
    hours = minutes / 60
    ops = attendance_of(record, sessions, windows, uid)["attended"]

    enlisted = record.get("enlistedAt", "")
    promoted = record.get("promotedAt", "")
    if not isinstance(promoted, str) or len(promoted) < 10:
        promoted = enlisted

    quantities = {
        "hour": hours,
        "op": float(ops),
        "serviceMonth": days_since(enlisted) / 30,
        "gradeMonth": days_since(promoted) / 30,
        "training": float(len(record.get("training") or [])),
        "award": float(len(record.get("awards") or [])),
    }

    breakdown: list[dict[str, Any]] = []
    total = 0.0
    for label, key in WEIGHT_KEYS:
        qty = quantities[key]
        weight = weight_of(promotion, key)
        earned = qty * weight
        total += earned
        breakdown.append(
            {"factor": label, "quantity": qty, "points_each": weight, "points": earned}
        )
    points = sqf_round(total)

    # The ladder: rungs are items keyed rank_<rankId>.
    current = weight_of(promotion, "rank_" + str(record.get("rankId", "")))
    next_id, next_at = "", -1.0
    for key in promotion:
        if not isinstance(key, str) or not key.startswith("rank_"):
            continue
        threshold = weight_of(promotion, key)
        if threshold > current and (next_at < 0 or threshold < next_at):
            next_at, next_id = threshold, key[5:]
    needed = max(next_at - points, 0) if next_at >= 0 else 0

    return {
        "points": points,
        "breakdown": breakdown,
        "next_rank_id": next_id,
        "points_to_next": int(needed),
        "next_rank_at": int(next_at) if next_at >= 0 else None,
        "current_threshold": current,
        "minutes": minutes,
        # True when no formula is configured at all, so a caller can say so
        # rather than presenting a confident zero.
        "no_formula": not any(
            weight_of(promotion, key) for _label, key in WEIGHT_KEYS
        ),
    }


# ------------------------------------------------------------------- liveness
def liveness(store: dict[str, Any], live_window_minutes: int = 20) -> dict[str, Any]:
    """Is a game server holding this roster right now?

    This is the warning that stands between a staff member and a silently
    erased edit, because the game replaces the whole store document from its own
    memory on every save.

    ONLY THE TAIL OF `sessions` IS INSPECTED, deliberately. A server that
    crashed leaves a row open forever, and that row sits early in an
    append-only array; scanning everything would make the bot claim a server was
    live for the rest of the unit's existence.

    Because fnc_sessionTick writes nothing, an open row plus a stale document is
    genuinely ambiguous, so it gets its own answer - "maybe" - rather than being
    forced into yes or no.
    """
    sessions = store.get("sessions") or []
    tail = sessions[-40:] if len(sessions) > 40 else sessions
    open_rows = [r for r in tail if len(r) > 4 and isinstance(r[4], str) and not r[4].strip()]

    written = parse_stamp(store.get("updatedAt")) or parse_stamp(store.get("exportedAt"))
    age_minutes = None
    if written is not None:
        age_minutes = max((utcnow() - written).total_seconds() / 60, 0)

    if open_rows and age_minutes is not None and age_minutes < live_window_minutes:
        state = "live"
    elif open_rows:
        state = "maybe"
    else:
        state = "idle"

    return {
        "state": state,
        "open_sessions": len(open_rows),
        "age_minutes": age_minutes,
        "names": [r[1] for r in open_rows if len(r) > 1 and isinstance(r[1], str)],
    }


def liveness_warning(live: dict[str, Any]) -> str:
    """The sentence to append to a write reply, or empty when all is well."""
    if live["state"] == "live":
        age = live["age_minutes"]
        when = f"{int(age)} minutes ago" if age is not None else "recently"
        return (
            f"**A server looks live** ({live['open_sessions']} open "
            f"session(s), roster written {when}). This edit will be erased when "
            f"it next saves. Press SAVE in game, or restart the mission, to make "
            f"the server pick it up."
        )
    if live["state"] == "maybe":
        age = live["age_minutes"]
        when = f"{int(age / 60)} h ago" if age and age >= 120 else "a while ago"
        return (
            f"A server **may** be running ({live['open_sessions']} session(s) "
            f"still open, but nothing written since {when} - those rows may be "
            f"left over from a crash). If it is up, this edit may be erased at "
            f"its next save."
        )
    return ""
