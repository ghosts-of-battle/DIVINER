Steam Workshop description for DIVINER. Steam takes BBCode: paste the block
below into the Workshop item's description as it is.

---

[h1]DIVINER[/h1]
[i]Herding cats since 2034.[/i]

[b]THIS IS A TWO-PART SYSTEM.[/b] Part one is this mod. Part two is a mission built on it. The mod does nothing on its own. The mission templates are here: [url=https://github.com/ghosts-of-battle/2040]github.com/ghosts-of-battle/2040[/url]. Subscribe to the mod, then download a mission from that repository. Two parts. Both needed.

The mission framework of Ghosts of Battle: the role screen, the tablet suite, the messaging system, the arsenal and loadout system, the radio programmer, the motorpool, and the personnel system behind them. One rule runs through all of it: [b]the mission is configuration, the code is the mod.[/b] That is the two-part system: this mod is the code, the mission from the 2040 repository is the configuration. Add a squad, a role, a weapon or a net by editing a config file in the mission. Nothing needs a rebuild.

[h2]What you get[/h2]
[list]
[*][b]Role selection[/b] - platoon tabs, squads and slots from one config, rank and skill gates on the slots, slots that can be locked to named players.
[*][b]TAC//PAD[/b] - the tablet: squad panel, comms and the report reader, drones, jamming, the intrusion suite, fire support requests, weather, timers, radio.
[*][b]TAC//MSG[/b] - a [b]threaded messaging system[/b]: every report opens a thread, replies and acknowledgements stay under it, a thread carries its state (open, claimed, closed) and can be followed or muted. Named nets, a report deck (CASEVAC, contact, SITREP, patrol and more), mailboxes per net, tags for squads and platoons, and a reader on the map.
[*][b]TAC//PAC[/b] - personnel: ranks, skills, awards, statuses, op windows and attendance, OPORDs with a METT-TC reply from the leaders, an operator file per player, a dated action log, an in-game structure and ORBAT editor, and an admin page for all of it.
[*][b]Arsenal and loadouts[/b] - a common arsenal, one per element, per-role whitelists, kept loadouts and auto-slotting.
[*][b]Comms plan[/b] - ACRE2 (or TFAR) radios programmed from one plan: SR team nets, MR platoon nets, LR racks; an optional radio mesh where manpacks and racks relay for each other.
[*][b]Motorpool[/b] - pools per element, paints and fittings, pylon presets, radar and datalink.
[*][b]Battlefield systems[/b] - jamming sites, hacking and intelligence, drone swarms, anti-ship, logistics, AI skill by difficulty and light.
[*][b]Admin console[/b] - kick, ban, role grants, the player window, and the TAC//PAC pages.
[/list]

[h2]Your unit's data, where you want it[/h2]
Everything TAC//PAC keeps - ranks, roles, the ORBAT, nets, the radio plan, the roster, play time - is stored one of two ways, and you pick with one setting.

[b]MongoDB.[/b] Point the mod at a MongoDB database and every server you run shares one unit, and your staff edit the roster and the structure on the web. The [b]free hosted tier[/b] at [url=https://www.mongodb.com/]mongodb.com[/url] (Atlas) is more than enough for a unit: it costs nothing and needs no machine of your own. The game server talks to the database itself, so nothing else has to run, and a rented game server does it fine. The database quick start on the [url=https://github.com/ghosts-of-battle/DIVINER/wiki]wiki[/url] walks through it in a few minutes.

[b]Or the server's own profileNamespace.[/b] No database at all: the unit lives in the game server's mission profile, the way Arma has always kept things. Move data between servers by clipboard export and import. Works everywhere, sets up nothing.

Either way the mod does the same job. Start on the profile and move to MongoDB when you want more than one server, or never.

[h2]Requirements[/h2]
[list]
[*][b]A framework mission[/b] - required. Two-part system: this mod is one half, the mission is the other. Get one from [url=https://github.com/ghosts-of-battle/2040]github.com/ghosts-of-battle/2040[/url].
[*][b]CBA_A3[/b] - required
[*][b]ACE3[/b] - required
[*][b]DUI - Squad Radar[/b] - required
[/list]
[b]Optional:[/b] ACRE2 or Task Force Radio - the comms plan programs whichever is loaded; without a radio mod the mission runs on in-game radio. Simplex Support Services adds the fire-support tasking.
Works on Windows and Linux dedicated servers.

[h2]Getting started[/h2]
Remember the two-part system: the mod is what you subscribed to here, the mission is what you download. Go to [url=https://github.com/ghosts-of-battle/2040]github.com/ghosts-of-battle/2040[/url], take a [b]framework mission[/b], copy it, rename it, and edit its [i]config[/i] folder. Load this mod, load that mission, and it runs. The wiki is at [url=https://github.com/ghosts-of-battle/DIVINER/wiki]github.com/ghosts-of-battle/DIVINER/wiki[/url]: the smallest mission that boots, a page per config file, a quick start for the database, and an FAQ - "how do I add an op order" and the rest.

[url=https://github.com/ghosts-of-battle/2040]Mission templates (part two)[/url] · [url=https://github.com/ghosts-of-battle/DIVINER/wiki]Documentation[/url] · [url=https://github.com/ghosts-of-battle/DIVINER]Mod source (part one)[/url]

[h2]Credits[/h2]
Ghosts of Battle. Built on the shoulders of CBA, ACE3, ACRE2 and the YMF role framework. Licence in the repository.

[b]Based on & inspired by[/b]
Source projects are on GitHub — search the owner/repo path.
[list]
[*]ArmaForces/Mods — GPL
[*]AXEmod/AXE — GPLv3
[*]Theseus-Aegis/Mods — GPLv2
[*]last-resort-gaming/LRG-Fundamentals — MIT
[*]Theseus-Aegis/TheseusServices — APL-SA
[*]BourbonWarfare/POTATO — GPLv2
[/list]
