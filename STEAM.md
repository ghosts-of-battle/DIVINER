Steam Workshop description for DIVINER. Steam takes BBCode: paste the block
below into the Workshop item's description as it is.

---

[h1]DIVINER[/h1]
[i]Herding cats since 2034.[/i]

The mission framework of Ghosts of Battle: the role screen, the tablet suite, the messaging system, the arsenal and loadout system, the radio programmer, the motorpool, and the personnel system behind them. One rule runs through all of it: [b]the mission is configuration, the code is the mod.[/b] Add a squad, a role, a weapon or a net by editing a config file. Nothing needs a rebuild.

[h2]What you get[/h2]
[list]
[*][b]Role selection[/b] - platoon tabs, squads and slots from one config, rank and skill gates on the slots, slots that can be locked to named players.
[*][b]TAC//PAD[/b] - the tablet: squad panel, comms and the report reader, drones, jamming, the intrusion suite, fire support requests, weather, timers, radio.
[*][b]TAC//MSG[/b] - a messaging system with named nets, a report deck (CASEVAC, contact, SITREP, patrol and more), mailboxes per net, tags for squads and platoons.
[*][b]TAC//PAC[/b] - personnel: ranks, skills, awards, statuses, op windows and attendance, OPORDs with a METT-TC reply from the leaders, an operator file per player, a dated action log, an in-game structure and ORBAT editor, and an admin page for all of it.
[*][b]Arsenal and loadouts[/b] - a common arsenal, one per element, per-role whitelists, kept loadouts and auto-slotting.
[*][b]Comms plan[/b] - ACRE2 (or TFAR) radios programmed from one plan: SR team nets, MR platoon nets, LR racks; an optional radio mesh where manpacks and racks relay for each other.
[*][b]Motorpool[/b] - pools per element, paints and fittings, pylon presets, radar and datalink.
[*][b]Battlefield systems[/b] - jamming sites, hacking and intelligence, drone swarms, anti-ship, logistics, AI skill by difficulty and light.
[*][b]Admin console[/b] - kick, ban, role grants, the player window, and the TAC//PAC pages.
[/list]

[h2]Your unit's data, where you want it[/h2]
Everything TAC//PAC keeps - ranks, roles, the ORBAT, nets, the radio plan, the roster - lives in the server's profile, or in your own [b]MongoDB Atlas[/b] database so several servers share one unit and your staff edit it on the web. The server talks to the database itself; nothing else has to run, and a rented game server does it fine. Or stay file-based and move data between servers by clipboard. Your choice, one setting.

[h2]Requirements[/h2]
[list]
[*][b]CBA_A3[/b] - required
[*][b]ACE3[/b] - required
[*][b]DUI - Squad Radar[/b] - required
[/list]
[b]Optional:[/b] ACRE2 or Task Force Radio - the comms plan programs whichever is loaded; without a radio mod the mission runs on in-game radio. Simplex Support Services adds the fire-support tasking.
Works on Windows and Linux dedicated servers.

[h2]Getting started[/h2]
Take the [b]framework mission[/b], copy it, rename it, and edit its [i]config[/i] folder. The wiki has the smallest mission that boots, a page per config file, a quick start for the database, and an FAQ - "how do I add an op order" and the rest.

[url=https://github.com/ghosts-of-battle/DIVINER/wiki]Documentation[/url] · [url=https://github.com/ghosts-of-battle/DIVINER]Source[/url]

[h2]Credits[/h2]
Ghosts of Battle. Built on the shoulders of CBA, ACE3, ACRE2 and the YMF role framework. Licence in the repository.
