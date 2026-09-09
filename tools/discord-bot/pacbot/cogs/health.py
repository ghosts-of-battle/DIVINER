"""/pac status - what the bot can see, and whether anything is wrong.

This is the first thing to build and the thing to reach for when something does
not work, because almost every failure in this system looks the same from the
outside ("the bot says there is no roster") and has a different cause: a wrong
unit id, an unreachable database, a store that has never been written, or a
section document nobody seeded.

So it answers all of those at once, and in particular it LISTS THE DOCUMENT IDS
THAT DO EXIST when the store is missing - a mistyped unit id is by far the most
common cause and that one line makes it obvious.
"""

from __future__ import annotations

import logging

import discord
from discord import app_commands
from discord.ext import commands

from ..db import SECTIONS
from ..derive import liveness, parse_stamp
from ..errors import DbDown, NoStore

log = logging.getLogger(__name__)


class Health(commands.Cog):
    def __init__(self, bot: commands.Bot) -> None:
        self.bot = bot

    pac = app_commands.Group(name="pac", description="TAC//PAC bot")

    @pac.command(name="status", description="What the bot can see, and whether anything is wrong.")
    async def status(self, interaction: discord.Interaction) -> None:
        # Defer first, always. Any work before this risks the three-second
        # acknowledgement window and an "unknown interaction" the user cannot
        # be told about.
        await interaction.response.defer(ephemeral=True)

        cfg = self.bot.cfg
        store_ = self.bot.store

        embed = discord.Embed(
            title="TAC//PAC bot status",
            colour=cfg.embed_colour,
            description=f"unit `{cfg.unit_id}` in `{cfg.mongo_db}/{cfg.mongo_collection}`",
        )

        # The kill switch is worth shouting about: somebody debugging a refused
        # edit should not have to go and read the panel's variables.
        if not cfg.writes_enabled:
            embed.add_field(
                name="Writing",
                value="**OFF** - staff commands will refuse (PACBOT_WRITES_ENABLED)",
                inline=False,
            )

        try:
            store = await store_.store(cached=False)
        except NoStore as exc:
            embed.colour = discord.Colour.orange()
            embed.add_field(name="Store", value=f"missing\n{exc}", inline=False)
            try:
                ids = await store_.document_ids()
            except DbDown as db_exc:
                embed.add_field(name="Database", value=str(db_exc), inline=False)
            else:
                listing = "\n".join(f"`{i}`" for i in ids[:20]) or "_nothing at all_"
                more = f"\n_+{len(ids) - 20} more_" if len(ids) > 20 else ""
                embed.add_field(
                    name=f"Documents starting `{cfg.unit_id}`",
                    value=listing + more,
                    inline=False,
                )
            await interaction.followup.send(embed=embed, ephemeral=True)
            return
        except DbDown as exc:
            embed.colour = discord.Colour.red()
            embed.add_field(name="Database", value=str(exc), inline=False)
            embed.add_field(name="Detail", value=f"`{exc.detail or 'no detail'}`", inline=False)
            await interaction.followup.send(embed=embed, ephemeral=True)
            return

        players = store.get("players") or {}
        sessions = store.get("sessions") or []
        windows = store.get("windows") or []
        closed = [w for w in windows if len(w) > 3 and str(w[3]).strip()]

        written = parse_stamp(store.get("updatedAt")) or parse_stamp(store.get("exportedAt"))
        when = f"<t:{int(written.timestamp())}:R>" if written else "unknown"

        embed.add_field(
            name="Store",
            value=(
                f"{len(players)} operators\n"
                f"{len(sessions)} sessions\n"
                f"{len(windows)} op windows ({len(closed)} closed)\n"
                f"last written {when}"
            ),
            inline=True,
        )

        live = liveness(store, cfg.live_window_minutes)
        verdict = {
            "live": "a server looks **live**",
            "maybe": "a server **may** be running",
            "idle": "no server appears to be running",
        }[live["state"]]
        embed.add_field(
            name="Game server",
            value=f"{verdict}\n{live['open_sessions']} open session(s)",
            inline=True,
        )

        # Only closed windows count as operations, so a unit that never presses
        # START reads 0/0 attendance for everyone. Say so here rather than
        # letting it look like an absence record.
        if not closed:
            embed.add_field(
                name="Attendance",
                value=(
                    "No **closed** op windows, so every attendance figure will "
                    "read 0/0. Only windows started and stopped with the op "
                    "window buttons in game count as operations."
                ),
                inline=False,
            )

        lines = []
        for name in SECTIONS:
            try:
                items = await store_.section(name, cached=False)
            except DbDown:
                lines.append(f"`{name}` unreadable")
                continue
            mark = "" if items else "  ⚠ empty"
            lines.append(f"`{name}` {len(items)}{mark}")
        try:
            roles = await store_.roles(cached=False)
            opords = await store_.opords(cached=False)
            lines.append(f"`role.*` {len(roles)}")
            lines.append(f"`opord.*` {len(opords)}")
        except DbDown:
            pass
        embed.add_field(name="Structure", value="\n".join(lines) or "none", inline=False)

        # The promotion formula is the one section whose absence produces
        # confident nonsense rather than an obvious blank, so it is called out.
        promotion = await store_.section("promotion")
        if not promotion:
            embed.add_field(
                name="Promotion",
                value=(
                    f"`{cfg.unit_id}.promotion` is missing or empty, so every "
                    f"promotion figure would count zero. `/points` will say so "
                    f"rather than showing a total."
                ),
                inline=False,
            )

        embed.set_footer(text=f"pacbot · poll {cfg.poll_seconds}s · cache {cfg.cache_seconds}s")
        await interaction.followup.send(embed=embed, ephemeral=True)


async def setup(bot: commands.Bot) -> None:
    await bot.add_cog(Health(bot))
