# Quick start: the unit's database on MongoDB Atlas

The mod keeps TAC//PAC's config and roster in MongoDB when you tell it to.
The game server talks to the database itself - the `ghostd_pacdb`
extension in the mod root carries the MongoDB driver - so a rented game
server that can run nothing beside Arma still reads its config from the
cloud at every mission start and writes its roster back on every change.
Nothing else has to run anywhere.

Four pieces: an Atlas cluster, one setting in the mission, one CBA server
setting with the connection string, and a first boot to seed the database.
About twenty minutes.

---

## 1. Make the database on the Atlas site

1. Go to [mongodb.com/cloud/atlas](https://www.mongodb.com/cloud/atlas), sign
   up or sign in, and **Build a Database** (or **Create** on the Clusters
   page). Choose the **M0 Free** tier, a provider and region near your game
   server, keep the name `Cluster0`, and create it. It takes a couple of
   minutes to come up.
2. **Security > Database Access > Add New Database User.** Authentication
   *Password*; a username for the game server, e.g. `ghostd_server`; let
   Atlas generate the password and **copy it now** - it is not shown again.
   Under *Database User Privileges* pick **Specific Privileges** and add
   `readWrite` on database `ghostd` (leave collection empty). Add the user.
   This user can touch nothing but the unit's own database, which is what
   makes the next step safe.
3. **Security > Network Access > Add IP Address.** Enter the game server's
   public IP address and confirm. Atlas refuses every connection that is not
   on this list, so the connection string is useless from anywhere else. Full
   walkthrough, and how to find the address: [Atlas IP allowlist](Atlas-IP-Allowlist).
   (While testing from your own PC, add your PC's IP too; **Allow access from
   anywhere** exists but leaves the string usable by anyone who has it.)
4. **Database > Connect > Drivers.** Copy the connection string. It looks
   like this, with your user and cluster in it:

   ```
   mongodb+srv://ghostd_server:<password>@cluster0.abcde.mongodb.net/
   ```

   Replace `<password>` with the password from step 2. If the password has
   characters like `@`, `:` or `/`, URL-encode them, or generate one that
   does not.

That is the whole Atlas side. The database `ghostd` and its collection
`pac` are created by the first write.

## 2. Tell the mission to use it

In the mission's `config\config_pac.hpp`, the `settings` class needs three
values:

```cpp
class CfgGFA_PAC {
    class settings {
        unitId   = "framework";     // the unit - every document is filed under this
        serverId = "main";          // this server, stamped on every edit
        sync     = "service";       // the database is on
    };
};
```

`unitId` is the unit's name in the database; keep it short and permanent.
Two missions with the same `unitId` share one roster and one config.

A mission may carry its full config beside those three lines (ranks,
skills, roles, the ORBAT, nets, the radio plan - see
[config_pac](config_pac)). That is the **seed**: the first boot pushes it
into an empty database. Or it may carry nothing but the three lines, the
way `frameworkmongo.Stratis` does, and take everything from the database.

## 3. Give the server the connection string

The mod on the server must be a release with `ghostd_pacdb_x64.so` (Linux)
and `ghostd_pacdb_x64.dll` (Windows) in its root - every release since
0.1.0.1008 has both.

Then, in game, as a logged-in admin (`#login`): **Options > Addon Options >
Ghosts of Battle PAC > Service**, switch to the **Server** tab, and
put the connection string from step 1 into **Database**. Leave **Service
key** empty. Save, and restart the mission - the setting is read once, at
mission start.

If your host lets you edit the server's `cba_settings.sqf`, this line does
the same:

```
force ghostD_pac_serviceUrl = "mongodb+srv://ghostd_server:...@cluster0.abcde.mongodb.net/";
```

A CBA server setting is sent to every client, which is why step 1 gave the
database a user that can reach nothing else and an IP list holding only
the game server. Never put an Atlas admin user in it.

## 4. Seed it, and check

Start the mission that carries the full config. The server `.rpt` (live on
the dedicated console) narrates the boot:

```
[TAC//PAC BOOT 1/6] structure from mission config: 7 rank(s), 9 skill(s), ... 25 role(s), ...
[TAC//PAC BOOT 3/6] database address: the CBA server setting 'Database' ...
[TAC//PAC BOOT 3/6] service: no config documents yet - this server's config PUSHED UP as the first, 38 document(s)
[TAC//PAC BOOT 5/6] service: no store document yet - the save in 6/6 creates it from the profile copy
[TAC//PAC BOOT 6/6] READY - profile written + service; ...
```

From the next start on, step 3 reads `service: config ADOPTED` with the
counts, and the database wins over whatever the mission carries. That is
the moment the mission can drop its config files (roles, groups, nets,
radio, ranks, messaging, tacpad) and keep the three lines - and the
arsenal, motorpool and modset files, which stay with the mission.

If step 3 says `NOT ANSWERING`, the string, the IP list or the user's
privileges are wrong; the `.rpt` line just above it from the extension
says which. `Blocked loading of file` from BattlEye on the line before
would mean the extension itself was refused - it never has been, and the
fix would be whitelisting, not switching BattlEye off.

## 5. Editing from then on

- **In game**: the admin page, EDIT STRUCTURE and MANAGE - every edit
  goes to the database at once.
- **On the Atlas site**: Database > Browse Collections > `ghostd` > `pac`.
  One document per config file - `framework.ranks`, `framework.nets`,
  `framework.radio`, `framework.orbat`, one `framework.role.<class>` per
  role, one `framework.opord.<id>` per order - and `framework`, the roster.
  Edit a document and it is read at the next mission start. The shapes are
  in [config_pac](config_pac#config-in-the-database-instead).
- **Without a restart**: run the small HTTP service on your own PC
  (`tools/pacdb/run-service.cmd`, pointed at the same cluster), then
  `pac_sync.py pull` puts the whole config on your clipboard and
  **STRUCTURE IN** on the admin page takes it. Not needed for normal use.

## Without a database

Leave `sync` at `"off"` (or out). The roster lives in the server's profile,
the config in the mission files, and the clipboard buttons on the admin
page - EXPORT STORE, IMPORT, STRUCTURE OUT, STRUCTURE IN - move data between
servers by hand. Everything on this page except the database itself works
the same.

See also: [TAC//PAC](TAC-PAC), [config_pac](config_pac), [FAQ](FAQ).
