#!/usr/bin/env python3
"""pac_sync.py - the unit's database and the game, joined by the clipboard.

The game loads no extension and no third-party mod (2026-09-05), so nothing
on a server can reach MongoDB. This runs on an admin's PC instead and moves
whole documents both ways through the clipboard, which the game can read
(STRUCTURE IN, IMPORT, RESTORE on the admin page) and write (STRUCTURE OUT,
EXPORT).

    python pac_sync.py pull                    every config document -> ONE {structure, settings}
                                              JSON on the clipboard; in game: STRUCTURE IN
    python pac_sync.py pull --out cfg.json     ... to a file instead (or as well)
    python pac_sync.py push-store              the game's EXPORT (on the clipboard) -> the <unit>
                                              store document, and its in-game structure edits
                                              (structureEdited) -> the config documents
    python pac_sync.py push-store --in x.json  ... from a file
    python pac_sync.py push-structure          a STRUCTURE OUT export (clipboard, or --in) ->
                                              every config document (one per role, one per
                                              order, one per section)

The service (tools/pacdb/service, run-service.cmd or docker) fronts the
database over HTTP; its URL and key come from GHOSTD_PACDB_URL /
GHOSTD_PACDB_KEY (or --url / --key). push_config.py is the third tool: a
mission's config files -> the documents.
"""
import argparse, datetime, json, os, subprocess, sys, urllib.error, urllib.request

SECTIONS = ["admins", "settings", "ranks", "skills", "awards", "statuses", "nets", "radio", "templates", "schemes"]
BOOT = ("unitId", "serverId", "sync")

# ---------------------------------------------------------------- service --
class Svc:
    def __init__(self, url, key):
        self.url = url.rstrip('/'); self.key = key
    def _req(self, method, path, body=None):
        req = urllib.request.Request(self.url + path, data=body, method=method,
                                     headers={'X-Api-Key': self.key, 'Content-Type': 'application/json'})
        try:
            with urllib.request.urlopen(req, timeout=40) as r:
                return r.status, r.read().decode('utf-8')
        except urllib.error.HTTPError as e:
            return e.code, ''
    def get(self, key):
        code, text = self._req('GET', '/pac/' + key)
        return json.loads(text) if code == 200 and text else None
    def list(self, prefix):
        code, text = self._req('GET', '/pac?prefix=' + prefix)
        return json.loads(text) if code == 200 and text else []
    def put(self, key, doc):
        code, _ = self._req('PUT', '/pac/' + key, json.dumps(doc, separators=(',', ':')).encode())
        return code
    def delete(self, key):
        code, _ = self._req('DELETE', '/pac/' + key)
        return code

# -------------------------------------------------------------- clipboard --
def clip_get():
    if sys.platform == 'win32':
        return subprocess.run(['powershell', '-NoProfile', '-Command', 'Get-Clipboard -Raw'], capture_output=True, text=True, encoding='utf-8').stdout
    try:
        import pyperclip; return pyperclip.paste()
    except ImportError:
        sys.exit('no clipboard access here - pass --in <file> (pip install pyperclip for a clipboard)')

def clip_set(text):
    if sys.platform == 'win32':
        subprocess.run(['clip'], input=text.encode('utf-8'), check=True); return
    try:
        import pyperclip; pyperclip.copy(text)
    except ImportError:
        sys.exit('no clipboard access here - pass --out <file> (pip install pyperclip for a clipboard)')

def stamp():
    return datetime.datetime.now(datetime.timezone.utc).strftime('%Y-%m-%d %H:%M:%S')

# ------------------------------------------------------------- assembling --
def assemble(svc, unit):
    """Every config document -> the one {structure, settings} the mod's structureAdopt takes."""
    structure, settings = {}, {}
    for s in SECTIONS:
        doc = svc.get(f'{unit}.{s}') or {}
        items = doc.get('items') if isinstance(doc.get('items'), dict) else {}
        if s == 'admins':
            for uid in doc.get('ids') or []:
                uid = str(uid)
                if uid and uid not in items: items[uid] = {'id': uid, 'name': ''}
        if s == 'settings': settings = items
        else: structure[s] = items
    orbat = svc.get(f'{unit}.orbat')
    if isinstance(orbat, dict):
        structure['orbat'] = {'groups': orbat.get('groups') or [], 'platoons': orbat.get('platoons') or [],
                              'radioNets': orbat.get('radioNets') or [], 'faction': orbat.get('faction') or ''}
    roles = {}
    prefix = f'{unit}.role.'
    for key in svc.list(prefix):
        d = svc.get(key) or {}
        if d.get('deleted') is True or not isinstance(d.get('role'), dict): continue
        rid = d.get('id') or key[len(prefix):]
        r = dict(d['role']); r['id'] = rid; roles[rid] = r
    if not roles:
        legacy = svc.get(f'{unit}.roles') or {}
        if isinstance(legacy.get('items'), dict): roles = legacy['items']
    structure['roles'] = roles
    opords = {}
    for key in svc.list(f'{unit}.opord.'):
        d = svc.get(key) or {}
        if not isinstance(d.get('order'), dict): continue
        oid = d.get('id') or d['order'].get('id')
        if not oid: continue
        o = dict(d['order']); o['id'] = oid; opords[oid] = o
    structure['opords'] = opords
    return {'structure': structure, 'settings': settings, 'exportedAt': stamp(), 'from': f'pac_sync.py pull {unit}'}

def orbat_doc(o):
    return {'section': 'orbat', 'faction': o.get('faction', ''), 'groups': o.get('groups', []),
            'platoons': o.get('platoons', []), 'radioNets': o.get('radioNets', [])}

def push_structure(svc, unit, structure, settings, origin):
    """The reverse of assemble: one document per section, per role, per order."""
    now = stamp(); n = 0
    def put(key, doc):
        nonlocal n
        doc['exportedAt'] = now; doc['from'] = origin
        code = svc.put(key, doc); n += 1
        print(f'PUT {key:40} -> {code}')
    if settings is not None:
        put(f'{unit}.settings', {'section': 'settings', 'items': {k: v for k, v in settings.items() if k not in BOOT}})
    for s in ('ranks', 'skills', 'awards', 'statuses', 'nets', 'radio', 'templates', 'schemes'):
        if s in structure: put(f'{unit}.{s}', {'section': s, 'items': structure.get(s) or {}})
    for rid, role in (structure.get('roles') or {}).items():
        put(f'{unit}.role.{rid}', {'section': 'role', 'id': rid, 'role': role})
    if 'orbat' in structure: put(f'{unit}.orbat', orbat_doc(structure['orbat'] or {}))
    if 'admins' in structure:
        admins = structure.get('admins') or {}
        put(f'{unit}.admins', {'section': 'admins', 'ids': sorted(admins), 'items': admins})
    for oid, order in (structure.get('opords') or {}).items():
        put(f'{unit}.opord.{oid}', {'section': 'opord', 'id': oid, 'order': order})
    return n

# ------------------------------------------------------------------- main --
def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('command', choices=['pull', 'push-store', 'push-structure'])
    ap.add_argument('--unit', default=os.environ.get('GHOSTD_UNIT', 'framework'))
    ap.add_argument('--url', default=os.environ.get('GHOSTD_PACDB_URL', 'http://127.0.0.1:8085'))
    ap.add_argument('--key', default=os.environ.get('GHOSTD_PACDB_KEY', ''))
    ap.add_argument('--out', help='pull: also write the JSON here')
    ap.add_argument('--in', dest='inp', help='push-*: read the JSON from this file instead of the clipboard')
    ap.add_argument('--no-clip', action='store_true', help='pull: do not touch the clipboard')
    a = ap.parse_args()
    svc = Svc(a.url, a.key)

    if a.command == 'pull':
        doc = assemble(svc, a.unit)
        text = json.dumps(doc, separators=(',', ':'))
        s = doc['structure']
        print(f"{a.unit}: {len(s.get('ranks', {}))} rank(s), {len(s.get('skills', {}))} skill(s), {len(s.get('roles', {}))} role(s), "
              f"{len((s.get('orbat') or {}).get('groups', []))} squad(s), {len(s.get('nets', {}))} net(s), {len(s.get('radio', {}))} radio key(s), "
              f"{len(s.get('templates', {}))} template(s), {len(s.get('opords', {}))} order(s) - {len(text)} chars")
        if a.out:
            open(a.out, 'w', encoding='utf-8').write(text); print('written to', a.out)
        if not a.no_clip:
            clip_set(text); print('on the clipboard - in game: admin page > STRUCTURE IN')
        return

    text = open(a.inp, encoding='utf-8').read() if a.inp else clip_get()
    text = text.strip()
    if not text: sys.exit('nothing to push - the clipboard is empty')
    try:
        doc = json.loads(text)
    except ValueError as e:
        sys.exit(f'not JSON: {e}')
    origin = f'pac_sync.py {a.command}'

    if a.command == 'push-store':
        if not isinstance(doc.get('players'), dict): sys.exit('this is not a store export (no "players") - EXPORT on the admin page writes one')
        code = svc.put(a.unit, doc)
        print(f'PUT {a.unit:40} -> {code}  ({len(doc["players"])} player(s), {len(doc.get("sessions", []))} session(s), {len(doc.get("log", []))} log row(s))')
        edits = doc.get('structureEdited') or {}
        if not isinstance(edits, dict) or not edits: print('no in-game structure edits in it'); return
        settings = edits.pop('_settings', None)
        for k in list(edits):
            if k.startswith('_'): edits.pop(k)
        n = push_structure(svc, a.unit, edits, settings, origin + ' (in-game edits)')
        print(f'{n} config document(s) from the in-game edits')
        return

    if a.command == 'push-structure':
        structure = doc.get('structure')
        if not isinstance(structure, dict): sys.exit('this is not a structure export (no "structure") - STRUCTURE OUT on the admin page writes one')
        n = push_structure(svc, a.unit, structure, doc.get('settings') if isinstance(doc.get('settings'), dict) else None, origin)
        print(f'{n} config document(s) written')

if __name__ == '__main__':
    main()
