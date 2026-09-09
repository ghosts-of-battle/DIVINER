"""pacbot entry point.

Run as a Pelican server: `python -u bot.py`. The -u matters - without unbuffered
output the panel console stays empty until a buffer happens to flush, which for
a long-running bot is effectively never, and the console is the only place an
operator can see what this thing is doing.

THE STARTUP CONTRACT WITH THE PANEL. The egg watches stdout for the line in
config.READY_LINE and marks the server "running" when it appears. That line is
printed after the command tree is synced, so "running" in the panel means the
slash commands actually work, not merely that a process exists.

FAILING PROPERLY. A missing or malformed setting prints one sentence naming the
variable and exits non-zero. It does not raise a traceback and it does not
retry: a panel set to restart on crash would scroll the reason away, and an
operator would be left watching a loop with no cause.
"""

from __future__ import annotations

import asyncio
import logging
import sys
import traceback

import discord
from discord import app_commands
from discord.ext import commands

from pacbot.config import READY_LINE, Config
from pacbot.db import Store
from pacbot.errors import ConfigError, NotStaff, PacBotError

COGS = (
    "pacbot.cogs.health",
)

log = logging.getLogger("pacbot")


class PacBot(commands.Bot):
    def __init__(self, cfg: Config) -> None:
        # No privileged intents: everything is slash commands, so the bot never
        # needs to read message content. Asking for less is one fewer approval
        # to chase and one fewer thing to get wrong.
        super().__init__(command_prefix="!pacbot ", intents=discord.Intents.default())
        self.cfg = cfg
        self.store = Store(cfg)

    async def setup_hook(self) -> None:
        for name in COGS:
            try:
                await self.load_extension(name)
            except Exception:
                log.exception("could not load %s", name)

        # Guild-scoped, so a change appears at once. A global sync takes about
        # an hour to propagate, which makes every iteration painful and, worse,
        # leaves two versions of a command live in the meantime.
        guild = discord.Object(id=self.cfg.guild_id)
        self.tree.copy_global_to(guild=guild)
        synced = await self.tree.sync(guild=guild)
        log.info("synced %d command(s) to guild %s", len(synced), self.cfg.guild_id)

    async def on_ready(self) -> None:
        who = f"{self.user} ({self.user.id})" if self.user else "?"
        log.info("connected as %s", who)
        # The panel's done-string. Printed last, and flushed explicitly.
        print(READY_LINE, flush=True)

    async def close(self) -> None:
        await self.store.close()
        await super().close()


async def _on_app_command_error(
    interaction: discord.Interaction, error: app_commands.AppCommandError
) -> None:
    """One place that turns an exception into something a person can act on.

    Everything the bot raises on purpose carries its own wording, so the
    handler's job is to deliver it rather than to invent a message. Anything
    else is a real fault: the user gets an apology and the console gets the
    traceback.
    """
    original = getattr(error, "original", error)

    if isinstance(original, (PacBotError, NotStaff)):
        message = str(original)
    else:
        log.error("unhandled error in /%s", getattr(interaction.command, "name", "?"))
        traceback.print_exception(type(original), original, original.__traceback__)
        message = (
            "Something went wrong running that. The failure is in the bot's log."
        )

    try:
        if interaction.response.is_done():
            await interaction.followup.send(message, ephemeral=True)
        else:
            await interaction.response.send_message(message, ephemeral=True)
    except discord.HTTPException:
        pass  # the interaction expired; the log already has the cause


async def amain() -> int:
    try:
        cfg = Config.from_env()
    except ConfigError as exc:
        print(f"pacbot: {exc}", file=sys.stderr, flush=True)
        return 2

    logging.basicConfig(
        level=getattr(logging, cfg.log_level, logging.INFO),
        format="%(asctime)s %(levelname)-7s %(name)s: %(message)s",
        datefmt="%H:%M:%S",
        stream=sys.stdout,
    )
    log.info("pacbot starting - %s", cfg.summary())

    bot = PacBot(cfg)
    bot.tree.on_error = _on_app_command_error

    # Say whether the database answers BEFORE connecting to Discord, and say it
    # either way. The bot still starts on a failure: a bot that is up and can
    # explain itself is far more use than one that exited, and /pac status can
    # then show the operator what is wrong.
    log.info("%s", await bot.store.ping())

    try:
        await bot.start(cfg.token)
    except discord.LoginFailure:
        print(
            "pacbot: Discord rejected the token. Check PACBOT_DISCORD_TOKEN.",
            file=sys.stderr,
            flush=True,
        )
        return 2
    finally:
        if not bot.is_closed():
            await bot.close()
    return 0


def main() -> int:
    try:
        return asyncio.run(amain())
    except KeyboardInterrupt:
        # The egg stops the server with ^C, so this is the ordinary way out.
        log.info("stopping")
        return 0


if __name__ == "__main__":
    raise SystemExit(main())
