import re, collections

# ---- 1) actions.xml quest hooks: aid/uid -> scripts ----
aid_scripts = collections.defaultdict(list)
uid_scripts = collections.defaultdict(list)
for raw in open('data/actions/actions.xml', encoding='utf-8', errors='ignore'):
    s = raw.strip()
    if s.startswith('<!--') or '<action' not in s:
        continue
    sc = re.search(r'script="([^"]+)"', s)
    script = sc.group(1) if sc else '?'
    am = re.search(r'actionid="(\d+)"', s)
    um = re.search(r'uniqueid="(\d+)"', s)
    fa = re.search(r'fromaid="(\d+)"\s+toaid="(\d+)"', s)
    fu = re.search(r'fromuid="(\d+)"\s+touid="(\d+)"', s)
    if am: aid_scripts[int(am.group(1))].append(script)
    if um: uid_scripts[int(um.group(1))].append(script)
    if fa:
        for a in range(int(fa.group(1)), int(fa.group(2))+1): aid_scripts[a].append(script)
    if fu:
        for u in range(int(fu.group(1)), int(fu.group(2))+1): uid_scripts[u].append(script)
reg_aids = set(aid_scripts); reg_uids = set(uid_scripts)
print(f"actions.xml quest hooks: {len(reg_aids)} action ids, {len(reg_uids)} unique ids")

# ---- 2) parse the OTBM ----
data = open('data/world/realmap1098.otbm', 'rb').read()
n = len(data)
TILE_AREA, TILE, ITEM, HOUSETILE = 4, 5, 6, 14

def read_props(start):
    out = bytearray(); j = start
    while j < n:
        b = data[j]
        if b == 0xFD: out.append(data[j+1]); j += 2; continue
        if b == 0xFE or b == 0xFF: break
        out.append(b); j += 1
    return bytes(out), j

STR_ATTRS = {1, 2, 6, 7, 11, 13, 19}       # uint16 len + string
U16_ATTRS = {9, 10, 22}                      # uint16
U32_ATTRS = {3, 16, 18, 20, 21}              # uint32
U8_ATTRS  = {12, 14, 15, 17}                 # uint8

hits = []           # (kind, id, script, x, y, z, itemid)
unmatched_items = collections.Counter()    # itemid -> count, for aids not matched to a quest hook
unmatched_aidband = collections.Counter()  # aid//10000 band -> count

# ---- door-type id sets parsed from native door_lib.lua ----
dl = open('data/scripts/doors/door_lib.lua', encoding='utf-8', errors='ignore').read()
def _slice(a, b):
    i = dl.find(a); j = dl.find(b, i + 1) if b else len(dl)
    return dl[i:j] if i >= 0 else ''
def _pairs(s):  # closed ids from [closed] = open tables
    return set(int(x) for x in re.findall(r'\[(\d+)\]\s*=\s*\d+', s))
NORMAL = _pairs(_slice('normalDoors = {', 'houseDoors'))
HOUSE  = _pairs(_slice('houseDoors = {', 'levelDoors'))
LEVEL  = _pairs(_slice('levelDoors = {', 'doorKeys'))
QUEST  = _pairs(_slice('questDoors = {', None))
_lk = _slice('lockedDoors = {', 'questDoors'); _lk = _lk[:_lk.find('messages')]
LOCKED = set(int(x) for x in re.findall(r'\d+', _lk[_lk.find('ids'):]))
DOOR_SETS = [('normal', NORMAL), ('house', HOUSE), ('level', LEVEL), ('locked', LOCKED), ('quest', QUEST)]
door_examples = {t: [] for t, _ in DOOR_SETS}
TOWNS = [(32369, 32241), (32360, 31782), (32957, 32076), (32097, 32219)]  # Thais, Carlin, Venore, Rookgaard
def near_town(x, y, z):
    return z == 7 and any(abs(x - tx) < 70 and abs(y - ty) < 70 for tx, ty in TOWNS)
MOVE_IDS = {1387: 'teleport', 384: 'rope-spot', 386: 'rope-spot', 435: 'sewer-grate', 433: 'sewer-grate',
            468: 'hole', 469: 'hole', 482: 'hole', 483: 'hole', 593: 'dirt-hole', 1948: 'ladder',
            3678: 'ladder', 5543: 'ladder', 1968: 'rope-hole', 7762: 'rope-spot'}
move_examples = {}
all_aid_uid = 0
i = 4
stack = []
while i < n:
    b = data[i]
    if b == 0xFE:
        nt = data[i+1]
        props, j = read_props(i+2)
        parent = stack[-1] if stack else {}
        frame = {'t': nt, 'pos': parent.get('pos'), 'base': parent.get('base')}
        if nt == TILE_AREA and len(props) >= 5:
            frame['base'] = (props[0] | props[1] << 8, props[2] | props[3] << 8, props[4])
        elif nt in (TILE, HOUSETILE) and frame['base'] and len(props) >= 2:
            bx, by, bz = frame['base']
            frame['pos'] = (bx + props[0], by + props[1], bz)
        elif nt == ITEM and len(props) >= 2:
            itemid = props[0] | props[1] << 8
            aid = uid = 0; k = 2
            while k < len(props):
                at = props[k]; k += 1
                if at == 4: aid = props[k] | props[k+1] << 8; k += 2
                elif at == 5: uid = props[k] | props[k+1] << 8; k += 2
                elif at == 8: k += 5
                elif at in STR_ATTRS: k += 2 + (props[k] | props[k+1] << 8)
                elif at in U16_ATTRS: k += 2
                elif at in U32_ATTRS: k += 4
                elif at in U8_ATTRS: k += 1
                else: break
            pos = frame['pos']
            if pos:
                for dt, dset in DOOR_SETS:
                    if itemid in dset:
                        door_examples[dt].append((near_town(*pos), itemid, aid, pos[0], pos[1], pos[2]))
                        break
                mv = MOVE_IDS.get(itemid)
                if mv and near_town(pos[0], pos[1], 7):
                    move_examples.setdefault(mv, []).append((itemid, pos[0], pos[1], pos[2]))
            if pos and (aid or uid):
                all_aid_uid += 1
                matched = False
                if aid in reg_aids:
                    matched = True
                    for sc in set(aid_scripts[aid]): hits.append(('aid', aid, sc, pos[0], pos[1], pos[2], itemid))
                if uid in reg_uids:
                    matched = True
                    for sc in set(uid_scripts[uid]): hits.append(('uid', uid, sc, pos[0], pos[1], pos[2], itemid))
                if not matched and aid:
                    unmatched_items[itemid] += 1
                    unmatched_aidband[(aid // 10000) * 10000] += 1
        stack.append(frame)
        i = j
    elif b == 0xFF:
        if stack: stack.pop()
        i += 1
    else:
        i += 1

print(f"map items carrying an action/unique id: {all_aid_uid}")
print(f"of those, matched to a registered quest hook: {len(hits)}")

# de-dup by (kind,id,script) keeping first position
seen = {}
for kind, _id, sc, x, y, z, iid in hits:
    key = (kind, _id, sc)
    if key not in seen:
        seen[key] = (kind, _id, sc, x, y, z, iid)

with open('_quest_checklist.txt', 'w', encoding='utf-8') as f:
    f.write("kind\tid\tx,y,z\titemid\tscript\n")
    for kind, _id, sc, x, y, z, iid in sorted(seen.values(), key=lambda r: r[2]):
        f.write(f"{kind}\t{_id}\t{x},{y},{z}\t{iid}\t{sc}\n")
print(f"wrote _quest_checklist.txt with {len(seen)} distinct quest objects")

# coverage: which registered hooks have NO map object (orphan registrations)?
placed_aids = {h[1] for h in hits if h[0] == 'aid'}
placed_uids = {h[1] for h in hits if h[0] == 'uid'}
print(f"registered action ids placed in map: {len(placed_aids)}/{len(reg_aids)}  | unique ids: {len(placed_uids)}/{len(reg_uids)}")

print("\n=== DOOR examples by native type (town-accessible first) ===")
for dt, _ in DOOR_SETS:
    ex = sorted(door_examples[dt], key=lambda r: not r[0])
    print(f"  {dt:6s} ({len(door_examples[dt])} in map):")
    for near, iid, a, x, y, z in ex[:3]:
        print(f"       item {iid}  aid {a}  at {x},{y},{z}{'  [near town]' if near else ''}")
print("\n=== MOVEMENT interactions near a town ===")
for mv in sorted(set(MOVE_IDS.values())):
    lst = move_examples.get(mv)
    if lst:
        print(f"  {mv:11s}: {lst[0][1]},{lst[0][2]},{lst[0][3]} (item {lst[0][0]}, {len(lst)} found)")
    else:
        print(f"  {mv:11s}: (none found near a town)")

print(f"\n--- unmatched action-id items (aid not in actions.xml quest hooks): {sum(unmatched_items.values())} ---")
print("top itemids:")
for iid, c in unmatched_items.most_common(15):
    print(f"   item {iid}: {c}")
print("aid value bands:")
for band, c in sorted(unmatched_aidband.items()):
    print(f"   {band}-{band+9999}: {c}")
