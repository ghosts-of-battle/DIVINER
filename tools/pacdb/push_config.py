#!/usr/bin/env python3
"""push_config.py - put a mission's config into the service, one document per
config file (one per role, one per order), exactly the way the mod would on a
first boot.

    python push_config.py <mission>\\config [--unit framework] [--sections skills,roles,orbat,...]

Sections and the files they come from:
    settings ranks skills awards statuses admins   config_pac.hpp (CfgGFA_PAC)
    roles      config_groups.hpp -> config_roles.hpp (Dynamic_Roles, the WHOLE role)
               merged with CfgGFA_PAC >> roles (the gates); ONE DOCUMENT PER ROLE,
               <unit>.role.<class> = {section: "role", id, role: {...}}
    orbat      config_groups.hpp (faction_name, group_setup, Platoons, RadioNets)
    nets       config_nets.hpp (GHOSTFR_Nets)
    radio      config_radio.hpp (the ghostFR_radio_* assignments - SQF, read as JSON)
    templates  config_messaging.hpp (GHOSTFR_Templates, the report deck)
    schemes    config_tacpad.hpp (GHOSTFR_TacpadSchemes)

A PUT replaces the document; the database wins at the next boot. A section
whose file the mission no longer has is skipped with a note. Nothing secret is
in this file: the service URL and key come from GHOSTD_PACDB_URL /
GHOSTD_PACDB_KEY (or --url / --key).
"""
import argparse, datetime, json, os, re, sys, urllib.request, urllib.error

# ----------------------------------------------------------- config parser --
def load(path):
    out = []
    for line in open(path, encoding='utf-8'):
        m = re.match(r'\s*#include\s+"([^"]+)"', line)
        if m:
            out.append(load(os.path.join(os.path.dirname(path), m.group(1).replace('\\', os.sep)))); continue
        if line.strip().startswith('#'): continue
        out.append(line)
    return ''.join(out)

def strip_comments(s):
    o = []; i = 0; inq = False
    while i < len(s):
        c = s[i]
        if inq: o.append(c); inq = c != '"'
        elif c == '"': o.append(c); inq = True
        elif s.startswith('//', i):
            i = s.find('\n', i); i = len(s) if i < 0 else i; continue
        elif s.startswith('/*', i): i = s.find('*/', i) + 2; continue
        else: o.append(c)
        i += 1
    return ''.join(o)

TOK = re.compile(r'\s*(?:(class)\s+(\w+)\s*(?::\s*\w+)?\s*\{|(\})\s*;?|(\w+)\s*(\[\])?\s*(\+?=)\s*)')
def parse(s):
    pos = 0; stack = [{}]
    def num(t): return float(t) if '.' in t else int(t)
    def value():
        nonlocal pos
        m = re.match(r'\s*"((?:[^"]|"")*)"\s*;', s[pos:])
        if m: pos += m.end(); return m.group(1).replace('""', '"')
        m = re.match(r'\s*(-?\d+(?:\.\d+)?)\s*;', s[pos:])
        if m: pos += m.end(); return num(m.group(1))
        raise ValueError('value at ' + s[pos:pos+40])
    def array(top):
        nonlocal pos
        m = re.match(r'\s*\{', s[pos:]); pos += m.end(); items = []
        while True:
            m = re.match(r'\s*\}\s*;' if top else r'\s*\}', s[pos:])
            if m: pos += m.end(); return items
            m = re.match(r'\s*,', s[pos:])
            if m: pos += m.end(); continue
            m = re.match(r'\s*"((?:[^"]|"")*)"', s[pos:])
            if m: pos += m.end(); items.append(m.group(1).replace('""', '"')); continue
            m = re.match(r'\s*(-?\d+(?:\.\d+)?)', s[pos:])
            if m: pos += m.end(); items.append(num(m.group(1))); continue
            m = re.match(r'\s*\{', s[pos:])
            if m: items.append(array(False)); continue
            raise ValueError('array at ' + s[pos:pos+40])
    while pos < len(s):
        m = TOK.match(s, pos)
        if not m:
            if s[pos:].strip() == '': break
            raise ValueError('syntax at ' + s[pos:pos+60])
        pos = m.end()
        if m.group(1): d = {}; stack[-1][m.group(2)] = d; stack.append(d)
        elif m.group(3): stack.pop()
        else: stack[-1][m.group(4)] = array(True) if m.group(5) else value()
    return stack[0]

def config(path):
    return parse(strip_comments(load(path)))

# ------------------------------------------------------------- documents ---
FIELDS = {   # (field, kind) per section - mirrors ghostD_pac_fnc_structFields + name
    'ranks':    [('name','t'),('abbrev','t'),('insignia','t'),('armaRank','t')],
    'skills':   [('name','t'),('abbrev','t'),('effects','a')],
    'awards':   [('name','t'),('type','t'),('image','t'),('campaign','t')],
    'statuses': [('name','t')],
    'admins':   [('name','t')],
}
# The whole role: the mission contract (ghostD_groups_fnc_roleFields) ...
ROLE_MISSION = [('name','t'),('description','t'),('icon','t'),('nets','a'),('tiles','a'),('traits','a'),
                ('customVariables','a'),('defaultLoadout','a'),('groupArsenal','t'),('arsenalWeapons','a'),
                ('arsenalMagazines','a'),('arsenalItems','a'),('arsenalBackpacks','a')]
# ... plus TAC//PAC's own
ROLE_PAC = [('minRank','t'),('requiredSkills','a'),('uids','a'),('arsenalWhitelist','a'),('defaultSkills','a'),('slotTag','t')]
BOOT = ('unitId', 'serverId', 'sync')

def empty(kind): return [] if kind == 'a' else ''

def section_doc(cfg, name):
    if name == 'settings':
        return {'section': 'settings', 'items': {k: v for k, v in (cfg.get('settings') or {}).items() if k not in BOOT}}
    items = {}
    for cid, c in (cfg.get(name) or {}).items():
        if not isinstance(c, dict): continue
        rec = {'id': cid}
        for f, kind in FIELDS[name]:
            rec[f] = c.get(f, empty(kind))
        items[cid] = rec
    doc = {'section': name, 'items': items}
    if name == 'admins': doc['ids'] = sorted(items)
    return doc

def role_docs(groups_cfg, pac):
    """One record per role: Dynamic_Roles' properties, then CfgGFA_PAC >> roles' gates on top."""
    classes = groups_cfg.get('Dynamic_Roles') or {}
    declared = pac.get('roles') or {}
    out = {}
    for rid in list(classes) + [r for r in declared if r not in classes]:
        c = classes.get(rid) if isinstance(classes.get(rid), dict) else {}
        d = declared.get(rid) if isinstance(declared.get(rid), dict) else {}
        rec = {'id': rid}
        for f, kind in ROLE_MISSION:
            rec[f] = c.get(f, d.get(f, empty(kind)))
        for f, kind in ROLE_PAC:
            rec[f] = d.get(f, empty(kind))
        if not rec['name']: rec['name'] = rid
        if not rec['slotTag']: rec['slotTag'] = rid
        out[rid] = {'section': 'role', 'id': rid, 'role': rec}
    return out

TEMPLATE_OPT_T = ["kind", "priority", "subject", "transitionsTo", "senderMustBe", "reportable", "broadcast", "routing", "anchor"]
TEMPLATE_OPT_A = ["replyableWith", "allowedFrom"]
def templates_doc(msg_cfg):
    """GHOSTFR_Templates -> {id: {title, short, lines, options}} in registerTemplate's shape."""
    items = {}
    for tid, t in (msg_cfg.get('GHOSTFR_Templates') or {}).items():
        if not isinstance(t, dict): continue
        options = [[k, t[k]] for k in TEMPLATE_OPT_T if isinstance(t.get(k), str)] + [[k, t[k]] for k in TEMPLATE_OPT_A if isinstance(t.get(k), list)]
        lines = []
        for lid in t.get('lineOrder', []):
            l = (t.get('Lines') or {}).get(lid)
            if not isinstance(l, dict): continue
            fields = []
            for fid, f in (l.get('Fields') or {}).items():
                if not isinstance(f, dict): continue
                fo = [[k, bool(f[k])] for k in ('required', 'noCur') if isinstance(f.get(k), (int, float))]
                fo += [[k, f[k]] for k in ('min', 'max') if isinstance(f.get(k), (int, float))]
                fo += [[k, f[k]] for k in ('exclusive', 'autoFill', 'source') if isinstance(f.get(k), str)]
                if isinstance(f.get('choices'), list): fo.append(['choices', f['choices']])
                fields.append([f.get('prefix', ''), f.get('hint', ''), f.get('type', ''), fo])
            lines.append([l.get('name', ''), l.get('label', ''), fields])
        items[tid] = {'id': tid, 'title': t.get('title', ''), 'short': t.get('short', ''), 'lines': lines, 'options': options}
    return {'section': 'templates', 'items': items}

def schemes_doc(tac_cfg):
    items = {}
    for sid, c in (tac_cfg.get('GHOSTFR_TacpadSchemes') or {}).items():
        if isinstance(c, dict): items[sid] = {'id': sid, 'name': c.get('name', ''), 'ground': c.get('ground', ''), 'ink': c.get('ink', ''), 'accent': c.get('accent', '')}
    return {'section': 'schemes', 'items': items}

def orbat_doc(groups_cfg):
    dg = groups_cfg.get('Dynamic_Groups') or {}
    groups = [[r[0], r[1], r[2] if len(r) > 2 else 'true'] for r in dg.get('group_setup', []) if isinstance(r, list) and len(r) >= 2]
    platoons = [[pid, p.get('name', ''), p.get('callsign', ''), p.get('net', ''), p.get('squads', [])]
                for pid, p in (dg.get('Platoons') or {}).items() if isinstance(p, dict)]
    radio_nets = [[rid, r.get('net', ''), r.get('squads', [])]
                  for rid, r in (dg.get('RadioNets') or {}).items() if isinstance(r, dict)]
    return {'section': 'orbat', 'faction': dg.get('faction_name', ''), 'groups': groups, 'platoons': platoons, 'radioNets': radio_nets}

def nets_doc(nets_cfg):
    """GHOSTFR_Nets >> nets[] = {{name, description}, ...} -> {id: {id, name, order}}."""
    items = {}
    for i, n in enumerate((nets_cfg.get('GHOSTFR_Nets') or {}).get('nets', [])):
        nid = n[0] if isinstance(n, list) and n else n
        desc = n[1] if isinstance(n, list) and len(n) > 1 else ''
        if isinstance(nid, str) and nid:
            items[nid] = {'id': nid, 'name': desc if isinstance(desc, str) else '', 'order': i}
    return {'section': 'nets', 'items': items}

def radio_doc(path):
    """config_radio.hpp is SQF: `ghostFR_radio_x = <literal>;` per line, and every literal
    the plan uses (arrays of numbers and strings, numbers, strings) is also JSON."""
    s = strip_comments(open(path, encoding='utf-8').read())
    items = {}
    for m in re.finditer(r'ghostFR_radio_(\w+)\s*=\s*(.*?);', s, re.S):
        key, val = m.group(1), m.group(2).strip()
        try:
            items[key] = json.loads(val)
        except ValueError:
            sys.exit(f'radio: cannot read ghostFR_radio_{key} = {val[:80]}')
    return {'section': 'radio', 'items': items}

# ------------------------------------------------------------------- main --
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('config_dir', help=r'the mission\config folder')
    ap.add_argument('--unit', help='unitId (default: settings.unitId of config_pac.hpp)')
    ap.add_argument('--sections', default='ranks,skills,awards,statuses,roles,orbat,nets,radio,templates,schemes', help='comma list; also settings, admins')
    ap.add_argument('--url', default=os.environ.get('GHOSTD_PACDB_URL', 'http://127.0.0.1:8085'))
    ap.add_argument('--key', default=os.environ.get('GHOSTD_PACDB_KEY', ''))
    ap.add_argument('--dry', action='store_true', help='print, do not PUT')
    a = ap.parse_args()

    def path(name):
        p = os.path.join(a.config_dir, name)
        return p if os.path.exists(p) else None

    pac = config(path('config_pac.hpp')).get('CfgGFA_PAC', {})
    unit = a.unit or (pac.get('settings') or {}).get('unitId') or sys.exit('no unitId')
    now = datetime.datetime.now(datetime.timezone.utc).strftime('%Y-%m-%d %H:%M:%S')
    groups_cfg = config(path('config_groups.hpp')) if path('config_groups.hpp') else None

    docs = []   # (key, doc, count)
    for sec in [s.strip() for s in a.sections.split(',') if s.strip()]:
        if sec in ('orbat', 'roles') and groups_cfg is None:
            print(f'{sec}: no config_groups.hpp here - skipped'); continue
        if sec == 'orbat':
            d = orbat_doc(groups_cfg); docs.append((f'{unit}.orbat', d, len(d['groups'])))
        elif sec == 'roles':
            for rid, d in role_docs(groups_cfg, pac).items():
                docs.append((f'{unit}.role.{rid}', d, 1))
        elif sec in ('templates', 'schemes', 'nets', 'radio'):
            f = {'templates': 'config_messaging.hpp', 'schemes': 'config_tacpad.hpp', 'nets': 'config_nets.hpp', 'radio': 'config_radio.hpp'}[sec]
            if not path(f):
                print(f'{sec}: no {f} here - skipped'); continue
            d = {'templates': lambda: templates_doc(config(path(f))),
                 'schemes': lambda: schemes_doc(config(path(f))),
                 'nets': lambda: nets_doc(config(path(f))),
                 'radio': lambda: radio_doc(path(f))}[sec]()
            docs.append((f'{unit}.{sec}', d, len(d['items'])))
        else:
            d = section_doc(pac, sec); docs.append((f'{unit}.{sec}', d, len(d['items'])))

    origin = 'push_config.py ' + os.path.basename(os.path.dirname(a.config_dir.rstrip('\\/')))
    for key, doc, n in docs:
        doc['exportedAt'] = now; doc['from'] = origin
        if a.dry:
            print(f'{key}: {n} item(s), {len(json.dumps(doc))} bytes'); continue
        req = urllib.request.Request(f'{a.url}/pac/{key}', data=json.dumps(doc, separators=(',', ':')).encode(), method='PUT',
                                     headers={'X-Api-Key': a.key, 'Content-Type': 'application/json'})
        try:
            code = urllib.request.urlopen(req, timeout=40).status
        except urllib.error.HTTPError as e:
            code = e.code
        print(f'PUT {key:36} {n:3} item(s) -> {code}')

if __name__ == '__main__':
    main()
