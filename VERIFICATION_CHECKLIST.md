# BlackTek — In-Game Verification Checklist

Built from `realmap1098.otbm` (parsed via `_parse_otbm.py`), the native door system
(`data/scripts/doors/`), and the 365-object quest map (`_quest_checklist.txt`).
Work **top-down**: Section A (basic mechanic types) first, then Section B (specific quests).

## Setup
- **Login:** `dummy` / `dummy123`
- **GM char:** `Rookie` — god (group 6), level 200. Use for almost everything.
- **Low-level char:** `RookNewbie` — level 8, no vocation. Use only for *gating* tests (level doors).
- **Commands:** `/pos x,y,z` teleport · `/pos` show current pos · `/i <id> [count|aid]` create item · `/storage <key> <value>` set storage (for gated objects)
- **Interact:** right-click → **Use** (or **Ctrl+click**). Read text: right-click → **Look**. Open a door, then walk through it.
- Note: GM door-bypass is **off** (`doorConfig.allowGamemasterBypass = false`), so a GM opens doors *normally* — good for testing.

---

## Section A — Basic interactions (do first)

### A1. Doors — one of each native type
- [ ] **Normal door** — `/pos 32358,31771,7` → Use the wooden door (item 10272) → it **opens**; walk through; Use again → closes.
- [ ] **House door** — `/pos 32325,31724,7` → Use (item 1219). As a GM with access → opens. (A non-owner sees an "owned by …" message — that's correct.)
- [ ] **Locked door** — `/pos 32354,31797,7` → Use the door (item 6252) → **"The door is locked."** Then `/i 2087 1001` (makes a key with action id 1001) → use the key on the door → **"You unlocked the door."** → it opens.
- [ ] **Level door** — `/pos 32134,31095,6` → as **Rookie (lvl 200)** Use the door (item 7038) → opens (meets the level requirement).
- [ ] **Level door — gating** — log in **RookNewbie (lvl 8)**, same door `32134,31095,6` → **"Only the worthy may pass."** (blocked) ✅ confirms the level check.
- [ ] **Quest door** — `/pos 32226,31049,7` → Use the door (item 5123) → **"The door seems to be sealed against unwanted intruders."** To actually open: `/storage 1001 1` then Use again → opens.

### A2. Windows
- [ ] **Window** — `/pos 32284,32256,7` (Sorcerer's Avenue house) → Use a window (item 6439) → toggles open/closed.

### A3. Levers & switches
- [ ] **Elevator lever (teleport)** — `/pos 32636,31881,2` → pull the lever 1 tile **east** → you're teleported **down to floor 7** (whole view changes).
- [ ] **Bridge lever** — `/pos 32794,33062,9` → pull the lever → a stone **bridge appears just NW** (water→bridge at 32792,33059–61); lever flips.
- [ ] **Exhibition lever (NPC speech)** — `/pos 32430,32191,9` → pull the **gold lever** (item 1945, in the aisle — not the display behind glass) → an exhibit **speaks a line in chat**.

### A4. Movement tiles
- [ ] **Ladder (up)** — `/pos 32418,32212,15` → Use the ladder (item 1948) → climb up one floor.
- [ ] **Rope spot (up)** — `/pos 32397,31714,11` → `/i 2120` (rope) → use the rope on the spot (item 386) → pulled up one floor.
- [ ] **Sewer grate (down)** — `/pos 32299,31828,6` → Use the grate (item 435) → drop into the sewer below.
- [ ] **Teleport tile** — `/pos 32360,31784,8` → step onto the teleport (item 1387) → instantly relocated.
- [ ] **Shovel hole** — `/i 2554` (shovel), stand on a dirt pile / sandy hole anywhere → use the shovel on the ground → it opens a hole to descend.

### A5. Pick-up / use objects (Lion's Rock cluster — clear chat feedback)
- [ ] **Pick flower** — `/pos 33133,32359,6` → Use → *"You have picked a beautiful lion's mane."* + you receive the flower.
- [ ] **Holy water well** — `/pos 33137,32351,6` → Use → *"You took some holy water from the sacred well."* + item.
- [ ] **Amphora** — `/pos 33119,32247,9` → Use → *"…the ancient amphora crumbles to shards … you discover an old scroll."* + scroll.
- [ ] **Skeleton (always responds)** — `/pos 33146,32341,8` → Use → *"You missed the skeleton, you can get the scroll from the Amphora."* (repeatable — good smoke-test)

### A6. Containers & readables
- [ ] **Quest chest** — `/pos 31987,31223,7` → Use the chest (item 1738) → you receive the reward (or *"already taken"* on re-use).
- [ ] **Readable** — right-click → **Look** at any sign / tombstone / book → shows its text.

---

## Section B — Specific quests

**Legend:** ✅ = testable now as GM (lever/sign/local effect) · 🔑 = gated by storage/key (set with `/storage` or `/i` key, then test) · ⚔️ = needs combat / party / boss (do later)

### B1. Notable quests (detailed)
- [ ] ⚔️ **Annihilator** — start `/pos 33226,31671,13` (the 4 levers). Door at `31621,32056,8` (aid 2214). Classic 4-player + demons reward room.
- [ ] ⚔️ **Pits of Inferno** — start `/pos 32821,32346,13` (41 objects: 16 main levers + wrong-levers + walls). Deep among demons; pull levers, watch walls open.
- [ ] ⚔️ **Inquisition** — start `/pos 33224,31722,11` (16 objects: brother levers, reward door `uid 9021`, rewards `uid 1304 @ 32314,32245,9`). Boss-gated.
- [ ] ⚔️ **Demon Oak** — chests `uid 9008–9011 @ 32710–32716,32393,8`. Requires felling the oak (combat) before chests open.
- [ ] ⚔️ **The Queen of the Banshees** — start `/pos 32246,31861,14` (15 objects: first/third/sixth seals). Long seal chain.
- [ ] ⚔️ **In Service of Yalahar** — start `/pos 32869,31316,10` (23 objects: the mechanism, 14 parts). Multi-mission.
- [ ] ⚔️ **Wrath of the Emperor** — start `/pos 33351,31069,9` (8 objects: Mission01 lights).
- [ ] ⚔️ **Elemental Spheres** — start `/pos 33262,31831,12` (5 objects: OAE lever + spheres).
- [ ] ⚔️ **Dreamer Challenge** — start `/pos 32837,32221,14` (13 objects: walls).
- [ ] ⚔️ **The Hidden City of Beregar** — start `/pos 32560,31406,15` (15 objects: ore wagons).
- [ ] 🔑 **Svargrond Arena** — arena doors at `32227,31052,7` (aids 13100/26100/27100/28100). Combat waves; doors gate by arena progress.
- [ ] ⚔️ **The New Frontier** — start `/pos 33079,31014,2` (6 objects).
- [ ] 🔑 **Bigfoot Burden** — rewards `/pos 32776,31804,10` (9 objects: rewards + music). Quest-gated chests.
- [ ] ⚔️ **Gravedigger** — start `/pos 32969,32421,9` (10 objects).
- [ ] ✅ **Lion's Rock** — see A5 (flower/holy water/amphora/skeleton). Reward at `33119,32247,9`.

### B2. Full quest index (all 85 groups)

| Quest | Start coord | #objs | Cat |
|---|---|---|---|
| other (daramrat/exhibition/wagons) | 32794,33062,9 | 37 | ✅ |
| kazordoon (elevators/ore wagons) | 32637,31881,2 | 32 | ✅/🔑 |
| inquisition | 33224,31722,11 | 16 | ⚔️ |
| the queen of the banshees | 32246,31861,14 | 15 | ⚔️ |
| the hidden city of beregar | 32560,31406,15 | 15 | ⚔️ |
| Novos | 33593,32643,14 | 14 | ⚔️ |
| dreamer challenge | 32837,32221,14 | 13 | ⚔️ |
| gravedigger | 32969,32421,9 | 10 | ⚔️ |
| in service of yalahar | 32869,31316,10 | 23 | ⚔️ |
| pits of inferno | 32821,32346,13 | 41 | ⚔️ |
| system.lua (quest chests) | 31987,31223,7 | 9 | 🔑 |
| bigfoot burden | 32776,31804,10 | 9 | 🔑 |
| wrath of the emperor | 33351,31069,9 | 8 | ⚔️ |
| rookgaard | 32098,32204,8 | 6 | ✅ |
| farmine | 32992,31539,1 | 6 | ✅ |
| the new frontier | 33079,31014,2 | 6 | ⚔️ |
| theancienttombs | 33188,32660,15 | 5 | ⚔️ |
| rottin wood quest | 32644,32183,6 | 5 | ✅ |
| demon oak | 32710,32393,8 | 5 | ⚔️ |
| elemental spheres | 33262,31831,12 | 5 | ⚔️ |
| oramond | 33639,31903,5 | 4 | ✅ |
| lionrock | 33119,32247,9 | 4 | ✅ |
| svargrond arena | 32227,31052,7 | 4 | 🔑 |
| the thieves guild | 32337,31814,6 | 3 | 🔑 |
| the outlaw camp | 32614,32173,9 | 3 | ⚔️ |
| gray island | 33579,31297,11 | 3 | ⚔️ |
| theapecity | 32756,32494,11 | 2 | ⚔️ |
| thaislighthouselever | 32227,32278,8 | 2 | ✅ |
| draconia | 32792,31579,7 | 2 | ⚔️ |
| annihilator | 31621,32056,8 | 2 | ⚔️ |
| chayenne realm quest | 33080,32582,3 | 2 | 🔑 |
| triangletowerlever | 32573,32121,7 | 1 | ✅ |
| serpentineTowerLever | 33152,32866,8 | 1 | ✅ |
| serpentineTowerTorch | 33151,32861,7 | 1 | ✅ |
| senjaCastleLever | 32180,31633,8 | 1 | ✅ |
| hellgatelever | 32625,31698,11 | 1 | ✅ |
| liferinglever | 32413,32230,10 | 1 | ✅ |
| nibelor / nibelor1 | 32303,31081,7 | 1+1 | ✅ |
| inukaya / inukaya2 | 32367,31058,7 | 1+1 | ✅ |
| ora / ora1 | 33487,32070,8 | 1+1 | ✅ |
| vagao / vagao1 | 32571,31508,9 | 1+1 | ✅ |
| vagaohouse1–10 | 32559,31851,7 … | 10 | ✅ |
| placa (sign) | 33487,32090,9 | 1 | ✅ |
| flor (flower) | 32024,32830,4 | 1 | ✅ |
| espelho (mirror) | 32965,31457,2 | 1 | ✅ |
| escada (stairs) | 32680,31509,12 | 1 | ✅ |
| pared (wall) | 32679,31609,8 | 1 | ✅ |
| dwarven | 32584,31401,8 | 1 | ✅ |
| orcedron | 33172,31896,8 | 1 | ✅ |
| rahemos | 33118,32790,14 | 1 | ✅ |
| krailos | 33657,31657,7 | 1 | ✅ |
| sea of light | 32011,31709,7 | 1 | ✅ |
| daramsystem1 | 30676,32662,7 | 1 | ✅ |
| daram quest | 31418,31971,8 | 1 | ✅ |
| system2 | 32258,31098,10 | 1 | 🔑 |
| iron_helmet | 32778,32232,8 | 1 | 🔑 |
| demon helmet | 33330,31574,15 | 1 | ⚔️ |
| koshei amulet | 33281,32447,8 | 1 | ⚔️ |
| green djinn | 33109,32530,3 | 1 | ⚔️ |
| behemoth | 33290,31715,12 | 1 | ⚔️ |
| barbarian test | 32201,31154,7 | 1 | 🔑 |
| children of the revolution | 33318,31410,8 | 1 | 🔑 |
| tinder box | 32081,31028,2 | 1 | 🔑 |
| unnatural selection | 32982,31431,1 | 1 | 🔑 |
| secret service | 32576,31862,14 | 1 | 🔑 |
| sam old backpack | 32455,31967,14 | 1 | 🔑 |
| desertdungeonquest | 32673,32086,8 | 1 | 🔑 |
| bkquest | 32800,31959,7 | 1 | 🔑 |
| explorer society | 32321,31455,9 | 1 | 🔑 |
| hunter outfit | 32406,32794,9 | 1 | 🔑 |
| outfit | 33053,31020,7 | 1 | 🔑 |
| postman | 32514,32248,8 | 1 | 🔑 |
| rookgaard barbarian/misc | 32098,32204,8 | — | ✅ |

*(Two more single-object scripts — `flor`, `liferinglever` etc. — are listed above; the exhaustive per-object coordinate list is in `_quest_checklist.txt`.)*

---

## Notes & follow-ups
- **Gated objects (🔑):** the door/chest's **action id IS the storage key**. Set it as GM (`/storage <aid> 1`) then re-use the object, or just complete the quest normally.
- **Level doors:** required level is encoded in the action id (`getRequiredLevel` in `door_lib.lua`). Rookie (lvl 200) passes; RookNewbie (lvl 8) is blocked.
- **Orphan registrations:** 10 action ids + 23 unique ids have scripts registered but **no object placed** in this map (those quest areas aren't in realmap1098) — nothing to test there.
- **Coverage already proven:** 193/203 action-id hooks and 172/195 unique-id hooks have matching map objects → action-id ↔ script mapping is correct for quest content.
- **Raw data:** `_quest_checklist.txt` (365 objects, exact coords + script). Re-generate with `python _parse_otbm.py`.
