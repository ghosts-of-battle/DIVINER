Steam Workshop change notes for DIVINER. Steam takes BBCode: paste the block
below into the update's change-note field as it is. The full engineering
record, file by file, is in [CHANGES.md](CHANGES.md) - this is the version
written for the people who run and play it.

Covers 2026-09-06 only.

---

[h1]Update - readable screens, and a way to find out why a database will not connect[/h1]

[i]Reminder: DIVINER is a two-part system. This mod is one half, a mission is the other. Mission templates: [url=https://github.com/ghosts-of-battle/2040]github.com/ghosts-of-battle/2040[/url][/i]

[h2]Server operators: update the extension files[/h2]
[b]ghostd_pacdb_x64.so[/b] (Linux) and [b]ghostd_pacdb_x64.dll[/b] (Windows) ship in the archive beside the PBOs and must be copied across with the mod. They are version 0.4.0 and carry the new network check below; an older copy simply will not have it.

[h2]New: find out why the database will not connect[/h2]
A server that cannot reach MongoDB gives you a wall of driver text and no answer. There is now a setting that asks the plain question instead.

[b]Addon Options > Ghosts of Battle PAC > Service > "Log this server's public IP at boot"[/b] - a server setting, [b]off by default[/b]. Turn it on and the next mission start writes one line to the server's .rpt:
[code][GHOSTD] (pac) INFO: network check: ip=203.0.113.7 | http ok, https ok[/code]

Two things in one line:
[list]
[*][b]The address MongoDB Atlas will see[/b], which is what its Network Access list needs. A rented server's own address is a private one and no use for this, and hosts do not always tell you the outbound one.
[*][b]Whether that machine can make an HTTPS connection at all.[/b] The lookup is done over plain HTTP as well as HTTPS, because the plain one still answers when TLS is the thing that is broken. So the line says which half is at fault: [i]http ok, https ok[/i] means allowlist the address; [i]http ok, https FAILED[/i] means the machine cannot complete a TLS handshake and allowlisting will not help until that is fixed; both failing means no outbound web access at all.
[/list]

It makes one request per mission start to an outside service, which is why it is off by default. Turn it off again once the database connects. Failures now report the underlying error rather than being cut off mid-sentence, and the extension no longer refers to a setting name that no longer exists - it is called [b]Database[/b].

Written up on the wiki: [url=https://github.com/ghosts-of-battle/DIVINER/wiki/Atlas-IP-Allowlist]allowing your server's IP in Atlas[/url]

[h2]Fixed: long text was being cut off[/h2]
Blocks of prose in the TAC//PAC app were sized by counting characters and guessing how many fit on a line. When the guess came out low the last line was clipped mid-sentence - operation orders lost the end of SITUATION, ENEMY, CIVIL/TERRAIN and EXECUTION. It now measures what the game actually laid out, so nothing is cut at any text size or interface scale.

[h2]Fixed: the record page is laid out to be read[/h2]
A label sat hard against the left edge of the panel and its value hard against the right, with a screen of empty space between the word and its answer. Labels now sit against the middle with their values just past them, so the eye does not have to cross the panel for every line. Skills and awards use the same two columns instead of each having a layout of its own.

[h2]Fixed: the boot screen drew over its own logo[/h2]
The mark stood nearly half the screen tall, and the title, the progress bar and the boot lines were all positioned inside it - white text over artwork, with the bar drawn straight across it. The logo now keeps the top third to itself with the title below it, and the boot log has room for the lines it prints instead of losing the last one.
