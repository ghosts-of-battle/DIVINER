# pacdb - TAC//PAC's config and store in MongoDB Atlas, from the game server itself

The Arma **server** talks to MongoDB directly. The `ghostd_pacdb` extension
carries the MongoDB driver, so a rented game server that can run nothing
beside Arma still reads its config from Atlas at boot and writes its store
there on every change. Nothing else has to run anywhere. An admin's PC can
also move whole documents by clipboard (`pac_sync.py`), and a unit that
prefers a middle service can still run one (`service/`).

```
Arma server  --callExtension-->  ghostd_pacdb_x64.dll / .so  --MongoDB driver-->  MongoDB Atlas
admin's PC   --clipboard-->  pac_sync.py / push_config.py  --HTTP-->  pacdb-service  --> (optional)
```

## Quick start (hosted Linux server, Atlas)

1. **Atlas, once.** Database Access: a user for this database only - role
   `readWrite` on database `ghostd` - with a password of its own. Network
   Access: add the game server's public IP (and only that; the string is
   then useless from anywhere else). Database > Connect > Drivers: copy the
   `mongodb+srv://user:password@cluster.../` string.
2. **The mod** on the server, from `.hemttout/release` - `ghostd_pacdb_x64.so`
   (Linux) and `ghostd_pacdb_x64.dll` (Windows) are in its root.
3. **The mission** with `sync = "service"` and the `unitId` the documents
   are filed under (`frameworkmongo.Stratis`: `framework`).
4. **In game**, logged in as admin: Options > Addon Options > Ghosts of
   Battle PAC > Service, **Server** tab: **Database** = the connection
   string; **Service key** empty. Restart the mission.
5. **Read the server `.rpt`**: `3/6 database address: the CBA server setting`,
   then `service: config ADOPTED` with the counts, then `5/6 ... store`.

Or the server's `cba_settings.sqf`: `force ghostD_pac_serviceUrl = "mongodb+srv://...";`

**Know what a CBA server setting is:** it is sent to every client, so the
connection string is on every player's machine. Step 1 is what makes that
harmless - a user that can touch nothing but `ghostd`, from the game
server's IP alone.

## The extension (`extension/`)

A native library the **server** calls - never a client - with the MongoDB
driver built in. Verbs: `configure address [key]` (the mod hands it the CBA
setting), `get key`, `list prefix`, `put.begin/chunk/end key`, `ping`. A
`mongodb+srv://` or `mongodb://` address is spoken to directly - database
`ghostd`, collection `pac`, one document per key with real BSON fields; an
`http://` address is the pacdb service. Every call but `configure` returns
`queued` at once and answers through `ExtensionCallback` on its own thread,
so a server frame never waits on the network. `ping` reports the address it
is using (password masked) and where it came from.

Built with NativeAOT from one C# file, once per platform, because NativeAOT
does not cross-compile:

| Server | File | Build |
|---|---|---|
| Windows | `ghostd_pacdb_x64.dll` (28 MB) | `dotnet publish -c Release -r win-x64` in `extension/`, from a shell with `C:\Program Files (x86)\Microsoft Visual Studio\Installer` on PATH (the native link calls `vswhere.exe`); rename `publish/ghostd_pacdb.dll` |
| Linux | `ghostd_pacdb_x64.so` (33 MB) | `sh extension/build-linux.sh` (Docker, bullseye image), or `--native` on a Linux box with the .NET 8 SDK, `clang` and `zlib1g-dev`. **Build on an old glibc**: the library binds to the glibc it was built against and will not load on an older one. Built on Ubuntu 20.04 (WSL on the dev PC) it needs glibc 2.29, so it runs on Debian 11 and 12 and Ubuntu 20.04 onward - most game servers. Check with `objdump -T ghostd_pacdb_x64.so \| grep -o GLIBC_[0-9.]* \| sort -uV \| tail -1`. |

The name is lower case on purpose: a Linux server looks the file up by
the exact name the script gives (`"ghostd_pacdb" callExtension ...`), and
Linux mod folders are commonly lower-cased in transit. HEMTT ships both
files in the mod root (`.hemtt/project.toml`). **BattlEye:** the dedicated
server process is not policed the way clients are, and no client ever loads
the file. Run with BattlEye on; only if the server `.rpt` says `Blocked
loading of file` is there anything to do, and then it is whitelisting, not
disabling.

**Where the address comes from**, in order: the CBA server setting
**Database** (handed over at boot); `GHOSTD_PACDB_URL` / `GHOSTD_PACDB_KEY`
in the server machine's environment; a `pacdb.json`
(`{"url": ..., "apiKey": ...}`) in the server's root.

## The service (`service/`) - optional

A small ASP.NET app that fronts the database over HTTP, for a unit that
would rather the game server never hold the Atlas string (the extension
speaks HTTP to it when given an `http://` address and a key), and for the
tools below. `run-service.cmd` (Windows,
secrets from `GHOSTD_MONGO` / `GHOSTD_PACDB_KEY` in the environment) or
`docker compose up -d` (Mongo and the service together; point the
extension at it). Build with `dotnet publish -c Release -o out` in
`service/` (.NET 8 SDK). `Store = "file"` swaps in a folder of JSON files
for testing without a database.

```
GET    /pac/{key}         -> 200 json | 404
PUT    /pac/{key}         <- json body, 204
DELETE /pac/{key}         -> 204
GET    /pac?prefix=x.     -> 200 [keys]
GET    /health            -> 200 "ok <store>"
```

## The documents

One per config file so people can edit them separately: `<unit>.settings`,
`.ranks`, `.skills`, `.awards`, `.statuses`, `.admins` (with a plain `ids`
list), `.nets`, `.radio`, `.orbat`, `.templates`, `.schemes`; one per role,
`<unit>.role.<class>` (`{section, id, role}`); one per order,
`<unit>.opord.<id>`; and the store, `<unit>`, the same JSON the admin page
exports. Real BSON fields, so the site shows and edits them as documents.
The mod lists the `role.` and `opord.` prefixes at boot; a document edited
on the site is read at the next mission start.

## The tools (an admin's PC)

| Tool | What |
|---|---|
| `push_config.py <mission>\config` | a mission's config files (config_pac, roles, groups, nets, radio, messaging, tacpad) -> the documents. How a database is seeded from `framework.Stratis`. |
| `pac_sync.py pull` | every document assembled into one `{structure, settings}` JSON on the clipboard; in game **STRUCTURE IN** adopts it at once and keeps it in the profile. For a server without the service, or to try a site edit without a restart. |
| `pac_sync.py push-store` / `push-structure` | the admin page's **EXPORT** / **STRUCTURE OUT** (on the clipboard) -> the documents. |

`STRUCTURE OUT` on one server and `STRUCTURE IN` on another needs no
database at all.
