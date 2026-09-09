# MongoDB Atlas: allowing your server's IP

Atlas refuses every connection whose source IP is not on the cluster's
**Network Access** list. This is the one thing that makes it safe to put the
connection string in a CBA setting: the string reaches every player's client,
but from any address but the ones you list it connects to nothing. So the
list holds the game server, and nothing else.

Part of the [database quick start](Quick-Start-Database); here in full.

---

## Add the game server's address

1. In the Atlas site, open your project and go to **Security > Network
   Access**.
2. **Add IP Address.**
3. Enter the **game server's public IP address** in *Access List Entry*, add
   a comment like `game server`, and confirm. A single address is entered as
   `203.0.113.7` (Atlas appends `/32` for you).
4. The entry shows *Active* after a moment. That is all - the next connection
   from that address is allowed.

## Finding the server's IP

**Ask the server itself.** Turn on **Log this server's public IP at boot**
(Addon Options > Ghosts of Battle PAC > Service, a server setting, off by
default). At the next mission start the server writes a line to its `.rpt`:

```
[GHOSTD] (pac) INFO: network check: ip=203.0.113.7 | http ok, https ok - this server's network and TLS are both fine
```

That address is the one Atlas sees, which is what the access list needs. It
is asked over plain HTTP as well as HTTPS, so the same line also says whether
the machine can make an HTTPS connection at all:

| The line says | What it means |
|---|---|
| `http ok, https ok` | Network and TLS are both fine. Allowlist the address. |
| `http ok, https FAILED (…)` | The machine cannot complete a TLS handshake - usually no CA certificate store in the container. Allowlisting will not help until that is fixed. |
| both `FAILED` | No outbound web access at all. Ask the host. |

It makes one request per mission start to an outside service
(`api.ipify.org`), which is why it is off by default. Turn it off again once
the database connects.

Other ways:

- **A rented game server:** the host's control panel shows the server's IP,
  usually on the server's overview or connection page. It is the same address
  players use to connect, without the game port. If in doubt, ask the host
  for the server's *outbound* or *public* IP - a few hosts route outbound
  traffic through a different address than the one players connect to.
- **Your own box:** run `curl ifconfig.me` (Linux) or open
  [whatismyip.com](https://www.whatismyip.com) on it. Use the IPv4 address.
- **Testing from your own PC** as well as the server: add your PC's current
  IP the same way, so `pac_sync.py` and the admin tools reach the cluster
  from your desk.

## If the IP changes

Most dedicated hosts give a server a fixed IP, but some do not, and a home
box's IP can change when the router reconnects. Two ways to cope:

- **Update the entry** when it changes. Network Access > the entry > *Edit* >
  new address. `NOT ANSWERING` in the boot log after a working setup is the
  usual sign the address moved.
- **Allow a range** if the host tells you the server sits in a known block -
  enter it in CIDR form, e.g. `203.0.113.0/24`. Narrower is better; a range
  is still far safer than the whole internet.

## Allow access from anywhere - and why not to

Atlas offers **ALLOW ACCESS FROM ANYWHERE** (`0.0.0.0/0`), which switches the
IP check off. It gets a database working in one click, and it is the wrong
setting for this: the connection string is on every player's machine, so with
no IP list anyone who reads it out of their own game files can connect to your
database and read or wipe it. Use it only for a throwaway test cluster with
nothing in it, and take it off before the cluster holds a roster. The
database user's `readWrite`-on-`ghostd`-only privileges limit the damage, but
the IP list is what stops the connection in the first place.

## Checking it worked

From the server (or a machine on an allowed IP):

```
curl -H "X-Api-Key: <key>" http://127.0.0.1:8085/health      # only if you run the service
```

For the direct connection the game makes, the proof is the server `.rpt` at
the next mission start: `[TAC//PAC BOOT 3/6] service: config ADOPTED ...`
means the address was allowed and the user could read. A timeout, or
`service: NOT ANSWERING`, with a working string and user, points back here -
the source IP is not on the list, or it changed.

See also: [Quick start: the database](Quick-Start-Database),
[TAC//PAC](TAC-PAC), [FAQ](FAQ).
