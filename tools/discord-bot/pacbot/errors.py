"""The bot's own exceptions.

Every one of these carries the words a person should read. The command error
handler turns them straight into a reply, so the message is written here, once,
rather than at each call site.
"""

from __future__ import annotations


class PacBotError(Exception):
    """Anything the bot can explain to the person who asked."""

    #: Set on subclasses that are the user's own doing rather than a fault.
    friendly = True


class ConfigError(PacBotError):
    """A required environment variable is missing or unusable.

    Raised before the Discord connection exists, so this one is printed to the
    console and the process exits non-zero - the panel console is the only
    diagnostic surface a Pelican server has.
    """


class DbDown(PacBotError):
    """The database did not answer."""

    def __init__(self, detail: str = "") -> None:
        self.detail = detail
        super().__init__(
            "The roster database is not reachable right now. "
            "It may be the network, or this server's address may not be on the "
            "Atlas access list."
        )


class NoStore(PacBotError):
    """There is no store document for the configured unit id."""

    def __init__(self, unit: str) -> None:
        self.unit = unit
        super().__init__(
            f"Unit `{unit}` has no store document yet. The game server writes "
            f"one when an admin presses SAVE or a player logs on. If that unit "
            f"id looks wrong, check PACBOT_UNIT_ID - `/pac status` lists the "
            f"documents that do exist."
        )


class LegacyStore(PacBotError):
    """The store is an old single-string document, which cannot be written to.

    A targeted $set against one of these would add a `players` field alongside
    the JSON string, where the game would never look at it.
    """

    def __init__(self, unit: str) -> None:
        self.unit = unit
        super().__init__(
            f"Unit `{unit}`'s store is still in the old single-string format, "
            f"which cannot be edited safely. Press SAVE once in game to rewrite "
            f"it as fields, then try again. Reading works meanwhile."
        )


class NoRecord(PacBotError):
    """No player record for that Steam id."""

    def __init__(self, uid: str) -> None:
        self.uid = uid
        super().__init__(
            f"No operator record for Steam id `{uid}`. A record is created the "
            f"first time that player joins the server; the bot never creates one, "
            f"because the game owns operator numbers and enlistment dates."
        )


class NotLinked(PacBotError):
    """No record carries the Discord id we were asked about."""

    def __init__(self, who: str = "you") -> None:
        self.who = who
        super().__init__(
            f"No operator record is linked to {who}. "
            f"Run `/claim` with your 17-digit Steam id and staff will approve it, "
            f"or ask staff to run `/operator link`."
        )


class UnknownId(PacBotError):
    """An id was given that the unit's structure does not contain."""

    def __init__(self, section: str, value: str) -> None:
        self.section = section
        self.value = value
        super().__init__(
            f"`{value}` is not a known {section[:-1] if section.endswith('s') else section}. "
            f"Pick one from the list the command offers."
        )


class WritesDisabled(PacBotError):
    """The kill switch is on."""

    def __init__(self) -> None:
        super().__init__(
            "Writing is switched off for this bot (PACBOT_WRITES_ENABLED=false). "
            "Nothing was changed."
        )


class RecordChanged(PacBotError):
    """Somebody else wrote the record between our read and our write."""

    def __init__(self) -> None:
        super().__init__(
            "That record changed while I was writing to it, so nothing was "
            "changed. Try again."
        )


class NotStaff(PacBotError):
    """The caller does not hold a staff role."""

    def __init__(self, reason: str = "You are not TAC//PAC staff.") -> None:
        super().__init__(reason)
