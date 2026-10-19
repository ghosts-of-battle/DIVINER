Steam Workshop description for DIVINER. Steam takes BBCode and cuts the
description at 8000 characters - the block below is measured to fit; paste it
as it is. No "tablet": it is TAC//PAD, or the PAC tile.

---

[i]Herding cats since 2034.[/i]

[b]TWO PARTS.[/b] This mod is one; a mission built on it is the other. The mod does nothing alone. Missions: [url=https://github.com/ghosts-of-battle/2040]github.com/ghosts-of-battle/2040[/url]. Subscribe here, download a mission there.

[h2]What you get[/h2]
[list]
[*][b]Role selection[/b] - platoon tabs, squads and slots from one config, rank and skill gates, slots locked to named players.
[*][b]TAC//PAD[/b] - squad panel, comms and the report reader, drones, jamming, the intrusion suite, fire support, weather, timers, radio.
[*][b]TAC//MSG[/b] - threaded messaging: every report opens a thread with a state (open, claimed, closed), followed or muted. Named nets, a report deck (CASEVAC, contact, SITREP, patrol and more), a reader on the map.
[*][b]TAC//PAC[/b] - the personnel system, below.
[*][b]Arsenal and loadouts[/b] - a common arsenal, one per element, per-role whitelists, kept loadouts, auto-slotting.
[*][b]Comms plan[/b] - ACRE2 or TFAR programmed from one plan: SR team nets, MR platoon nets, LR racks, an optional relay mesh.
[*][b]Motorpool[/b] - pools per element, paints and fittings, pylon presets, radar and datalink.
[*][b]Battlefield systems[/b] - jamming sites, hacking and intelligence, drone swarms, anti-ship, logistics, AI skill by difficulty and light.
[*][b]Admin console[/b] - kick, ban, role grants, the player window, the door into TAC//PAC.
[/list]

[h2]TAC//PAC[/h2]
The unit's personnel system, the same pages in three places: [b]in game[/b] (one dialog from the admin console - dashboard, roster, applications, PAC actions, orders, configs, templates, ORBAT, Mongo docs, backup), [b]on the web[/b] ([url=https://github.com/ghosts-of-battle/DIVINER_Web]DIVINER_Web[/url], a small PHP site on the same database, Steam sign-in) and [b]on TAC//PAD[/b] (every player's PAC tile: their record, the roster, the OPORD, their requests, the application form).
[list]
[*][b]Roster[/b] - an operator file per player: rank, role, squad, status, skills and qualifications, awards, training, admin notes, Discord, time in service and in grade, attendance.
[*][b]Ranks, skills, awards, statuses, trainings[/b] - edited on either side; ranks and skills go on the player at spawn and the moment an admin changes them.
[*][b]Promotion points[/b] - per hour, op, month in service and in grade, course and award, weighted as the unit decides; the dashboard lists who is due, or promote automatically.
[*][b]Op windows and attendance[/b] - scheduled, attended, excused, a percentage per man, a report on demand.
[*][b]Applications[/b] - new players added on first connect, or made to apply with the unit's own questions and accepted by an admin.
[*][b]PAC requests[/b] - leave, recommendations, problems: raised by a member, worked by admins, a thread each with private notes.
[*][b]Operation orders[/b] - written by section, one current, posted to the C2 net with a METT-TC reply from the leaders.
[*][b]ORBAT and comms[/b] - platoons, squads, slots, each squad's kind for the tracker, messaging nets, the ACRE and TFAR plans; named versions of the ORBAT, arsenal and motorpool per mission.
[*][b]Templates[/b] - welcome screen, common arsenal, motorpool, cosmetics, logistics crates, pylon presets, the report deck, versioned per mission.
[*][b]Action log and backup[/b] - every admin action signed and timed; the store and the structure out and in as JSON.
[/list]
[list]
[*][url=https://github.com/ghosts-of-battle/DIVINER/wiki/TAC-PAC]TAC//PAC on the wiki[/url]
[*][url=https://github.com/ghosts-of-battle/DIVINER_Web]Website source[/url]
[/list]

[h2]Where the data lives[/h2]
[b]MongoDB[/b] - every server you run shares one unit and your staff edit it on the web. The free Atlas tier at [url=https://www.mongodb.com/]mongodb.com[/url] is enough; the game server talks to it itself, so nothing else runs. [url=https://github.com/ghosts-of-battle/DIVINER/wiki/Quick-Start-Database]Quick start[/url].
[b]Or the server's profileNamespace[/b] - no database; move data by clipboard export and import. One setting picks. Start on the profile, move to MongoDB when you want more than one server, or never.

[h2]Requirements[/h2]
A framework mission from [url=https://github.com/ghosts-of-battle/2040]github.com/ghosts-of-battle/2040[/url]. The mods it needs are the required items on the right. Optional: ACRE2 or Task Force Radio (the plan programs whichever is loaded), Simplex Support Services for fire-support tasking. Windows and Linux servers.

[h2]Getting started[/h2]
Take a framework mission from the 2040 repository, copy it, rename it, edit its [i]config[/i] folder. Load this mod, load that mission. The [url=https://github.com/ghosts-of-battle/DIVINER/wiki]wiki[/url] has the smallest mission that boots, a page per config file, the database quick start, TAC//PAC end to end, and an FAQ.

[h2]Links[/h2]
[list]
[*][url=https://github.com/ghosts-of-battle/2040]Missions[/url]
[*][url=https://github.com/ghosts-of-battle/DIVINER/wiki]Wiki[/url]
[*][url=https://github.com/ghosts-of-battle/DIVINER/wiki/Quick-Start-Database]Database quick start[/url]
[*][url=https://github.com/ghosts-of-battle/DIVINER]Mod source[/url]
[*][url=https://github.com/ghosts-of-battle/DIVINER_Web]Website source[/url]
[/list]

[h2]Credits[/h2]
Ghosts of Battle. Built on CBA, ACE3, ACRE2 and the YMF role framework. Licence in the repository.
Based on and inspired by, on GitHub by owner/repo:
[list]
[*]ArmaForces/Mods - GPL
[*]AXEmod/AXE - GPLv3
[*]Theseus-Aegis/Mods - GPLv2
[*]last-resort-gaming/LRG-Fundamentals - MIT
[*]Theseus-Aegis/TheseusServices - APL-SA
[*]BourbonWarfare/POTATO - GPLv2
[/list]

---

Change notes for the Workshop update (BBCode, paste into the update's change
notes). Written 2026-09-10 for 0.1.0.1104.

---

[h1]TAC//PAC rebuilt, in game and on TAC//PAD[/h1]
[list]
[*][b]One dialog, laid out like the website.[/b] TAC//PAC in game is now the website's pages, page for page: DASHBOARD, ROSTER, APPLICATIONS, PAC ACTIONS, ORDERS, CONFIGS, TEMPLATES, ORBAT, MONGO DOCS, BACKUP across the top. Tables whose rows open the thing, forms that save from the foot, every delete asks first. The old personnel panel, structure editor and manage window are gone.
[*][b]The PAC tile on TAC//PAD.[/b] REQUESTS: your own PAC requests, open one and read the thread, reply, raise one with dropdowns for the kind and who it is about. APPLICATION in place of MY RECORD when the unit makes new players apply - the unit's own questions, sent from the tile.
[*][b]New players, your way.[/b] The setting [i]newPlayers[/i]: [i]auto[/i] seeds a record the moment somebody first connects; [i]apply[/i] makes them apply, on the tile or the website, and an admin accepts them. Settings (autoSlot, slotMatch, savedLoadouts, autoPromote, newPlayers) are one page, the same on both sides.
[*][b]The boot screen.[/b] A checklist of the six steps with coloured boxes, every database document ticked as it lands in a grid, what is being read and how many have landed, a clock, and a bar that moves.
[*][b]A squad's kind[/b] (inf, motor_inf, mech_inf, air, armor ...) set on the website or in game now reaches the blue force tracker's icon.
[*][b]Rank insignia[/b] - 26 images shipped in the mod and on the website.
[*][b]Orders, the report deck, logistics crates and pylon presets[/b] can be written in game as well as on the website; the ORBAT's squads, platoons, roles, nets, ACRE and TFAR plans too.
[*][b]No database?[/b] Everything a config file feeds is shown and marked read only in game; export and import stay on Backup.
[*][b]The admin console's[/b] TAC//PAC button moved beside WAKE UP and HEAL FULL.
[*][b]Fixes:[/b] the ORBAT page would not open; the dashboard threw on the promotion switch; config_logistics and config_pylons kept in the database failed to read when they carried comments; the "waiting for the unit's roles" hint stayed after READY.
[/list]
