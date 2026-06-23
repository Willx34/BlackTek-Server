# Custom BlackTek Server — Dev Setup & Project Notes

Personal fork notes (GitHub: **Willx34**). Gets a fresh machine from zero to a running
**server + website + client**, and summarizes what's been built so I can keep contributing
from anywhere.

> **No secrets in this file** (public fork). Provision your own local DB password and a
> throwaway test account on each machine — the steps below show where.

---

## 1. What this project is
A custom MMORPG server built on **BlackTek-Server** (modern-C++ TFS 1.4.2 fork), real client
protocol **10.98**, with the real-Tibia **10.98 map** integrated (`realmap1098`) and classic
NPCs/quests/actions. Designed as a **Rookgaard newbie experience**: new characters start
**level 1, vocationless in Rookgaard**, and the **Oracle** promotes them at level 8 to a
chosen vocation + mainland town with starter gear.

**Stack:** game server (C++/Lua) · **BlackTek-AAC** website (Laravel 12 / Filament / React) ·
**mehah/otclient** "Redemption" client.

## 2. Repositories (all forked under Willx34)
| Repo | Purpose | Notes |
|---|---|---|
| `Willx34/BlackTek-Server` | game server | `master` holds all custom work. 133 MB map ships as a **GitHub Release asset**, not in git. |
| `Willx34/BlackTek-AAC` | website / account management | Laravel 12 |
| `Willx34/otclient` | game client | mehah/otclient Redemption |

```bash
git clone https://github.com/Willx34/BlackTek-Server
git clone https://github.com/Willx34/BlackTek-AAC
git clone https://github.com/Willx34/otclient
```
Set git identity once: `git config --global user.name Willx34 && git config --global user.email <you>`.

## 3. Prerequisites (Windows)
- **Visual Studio 2022** + the *Desktop development with C++* workload (MSVC 14.4x, C++23).
- **vcpkg** at `C:\vcpkg` → set `VCPKG_ROOT`, run `vcpkg integrate install`. Deps come from `vcpkg.json` (manifest) automatically on first build.
- **premake5 built from `master`** — the repo's pinned beta5 is too old (lacks `multiprocessorcompile`/`vsprops`). Build premake-core from master and drop `premake5.exe` in the repo root. *(A working `premake5.exe` is already committed in this repo.)*
- **MariaDB** (or MySQL) service running on port **3306**.
- **PHP 8.4 (NTS)** + **Composer** — for the AAC. Reference layout: `C:\php`.
- **Node.js 24 LTS** — for the AAC frontend build. Reference layout: `C:\nodejs`.
- **GitHub CLI (`gh`)**, authenticated — needed to fetch the map Release asset.
- **Git for Windows**. Add `C:\php` and `C:\nodejs` to PATH.

## 4. Build the server
```powershell
cd BlackTek-Server
# 1) fetch the 133 MB map from the GitHub Release (needs `gh` authenticated)
powershell -ExecutionPolicy Bypass -File scripts/fetch-map.ps1
#    (downloads release `realmap-1098-v1` -> data/world/realmap1098.otbm)

# 2) generate the solution + build
.\premake5.exe vs2022
msbuild Black-Tek-Server.sln /p:Configuration=Release /p:Platform=64 /p:LanguageStandard=stdcppLatest /m
```
First build compiles all vcpkg deps (~30–60 min, cached afterward). Output: **`Black-Tek-Server.exe`**.
Note: solution platforms are named `64` / `ARM` / `ARM64` (not `x64`).

## 5. Database
```sql
-- as root:
CREATE DATABASE forgottenserver;
CREATE USER 'forgottenserver'@'127.0.0.1' IDENTIFIED BY '<your-local-password>';
CREATE USER 'forgottenserver'@'localhost'  IDENTIFIED BY '<your-local-password>';
GRANT ALL ON forgottenserver.* TO 'forgottenserver'@'127.0.0.1', 'forgottenserver'@'localhost';
```
```bash
mysql -u forgottenserver -p forgottenserver < schema.sql
```
Then create the **git-ignored** local DB config from the template:
```bash
cp config/database.toml.example config/database.toml
# edit config/database.toml -> set pass = "<your-local-password>"
```
The server auto-applies its own schema migrations on boot.

## 6. Run the server
```powershell
.\Black-Tek-Server.exe      # run from the repo root (needs cwd = repo for config/ + data/)
```
Listens **login 7171 / game 7172**. Config is TOML under `config/`. Key settings already set:
`config/server.toml` → `map_name = "realmap1098"`, `[account_manager] enabled = false`;
`config/gameplay.toml` → `default_world_light = false` (permanent dev daylight, set in
`data/scripts/globalevents/startup.lua` via the global `setWorldLight(250, 215)`).

## 7. AAC website (BlackTek-AAC)
```bash
cd ../BlackTek-AAC
cp .env.example .env
#  edit .env: DB_* -> the same `forgottenserver` DB; BLACKTEK_SERVER_ROOT -> path to BlackTek-Server
composer install
php artisan key:generate
php artisan migrate
npm install && npm run build
php artisan serve --port=8000        # http://localhost:8000
```
`.env` (APP_KEY, DB password, OAuth) is git-ignored — never commit it.
**Create your test account by registering on the website** — it auto-creates the linked game
`accounts` row (sha1). New characters are tuned to spawn level-1/vocationless at the Rookgaard
temple (see `config/blacktek.php`). Gotcha: if `npm` can't find `node`, prepend `C:\nodejs;C:\php` to PATH.

## 8. Client (otclient)
- Use the prebuilt client (reference layout `C:\otclient-app`) or build from the `otclient` fork. Run `otclient.exe`.
- **CRITICAL:** copy the server's `data/items/assets.dat` → client `data/things/1098/Tibia.dat`
  (keep the vanilla 10.98 `Tibia.spr`). The server uses an extended item set (ids up to 55000+);
  without this swap the map renders as **black squares** (client error: invalid item id 55551).
  otclient only reads the `.dat` at startup — restart the client after swapping.
- Login screen: Server `127.0.0.1`, Port `7171`, Client version `1098`, **HTTP login OFF** (classic).

## 9. Critical gotchas (these cost real time)
- **`config/database.toml` is git-ignored** — and git-ignoring a *tracked* file then merging will
  **delete it from your working tree**. Always recreate it from `.example` after a fresh clone/merge.
- **Client must use the server's `assets.dat`** as `Tibia.dat` (see §8).
- **premake must be from `master`**, not the pinned beta5.
- **Lua 5.4/5.5:** `for`-loop control variables are `const` — reassigning one is a *compile* error
  that breaks the entire file. Watch for this when porting old datapack scripts.
- **Credentials policy:** keep the DB password, AAC `.env`, and all game accounts OUT of GitHub.
  Only `schema.sql` (no accounts) is committed. Use a throwaway test account until live.

## 10. What's already built on this fork
- **Real 10.98 map** (`realmap1098`) integrated; NPCs/quests/actions ported.
- **Permanent dev daylight** (`setWorldLight(250,215)` + `default_world_light=false`).
- **In-game account manager removed** — accounts via the AAC website only.
- **NPC system reconciled** (868 Lua errors → 0): swapped to the datapack's classic npcsystem lib,
  fixed Lua 5.5 incompatibilities, loaded the real Storage constants.
- **Quests + actions imported** (441 action scripts + movements + quest libs).
- **Collision reconciliation** (888 duplicate registrations → 0): the import had double-registered
  generic handlers over BlackTek's *native* `data/scripts` revscripts, shadowing them with broken
  versions (the cause of dead doors). Removed the redundant datapack registrations so native
  door/transform/window/taming/tool systems win; kept all quest hooks + equipment events.
- **Rookgaard newbie start** (AAC): level 1, vocationless, Rookgaard temple.
- **Leave-Rookgaard Oracle**: promotes level-8 vocationless Rooks to a chosen vocation + mainland
  town with full starter gear (`data/npc/Oracle.xml` → `data/npc/scripts/The Oracle3.lua`,
  spawned at boot in `startup.lua`).
- **Verification checklist** (`VERIFICATION_CHECKLIST.md`) + quest-object map (`_quest_checklist.txt`,
  365 objects with coords) + the parser (`_parse_otbm.py`).

## 11. Test characters (recreate locally per machine)
- **GM / god char:** set a player's `group_id = 6` (Administrator) and the account `type = 5`
  to unlock GM commands. SQL: `UPDATE accounts SET type=5 WHERE id=<acct>; UPDATE players SET group_id=6 WHERE id=<player>;`
- **Low-level test char:** level 8, vocation 0, town 6 (Rookgaard) — for gating tests (level doors, etc.).
- GM commands: `/pos x,y,z` (teleport), `/pos` (show position), `/i <id> [count|aid]` (create item;
  `/i <key> <aid>` makes a key with an action id), `/town <id>`, `/storage <key> <value>`.

## 12. Current state & next steps
- **Next flagged work:** wholesale **vocation retune** — rebalance the 4 base vocations + promotions
  (stats, spells, progression). The Rookgaard→Oracle→mainland arc feeds into this.
- **In-game QA:** run down `VERIFICATION_CHECKLIST.md` (door types → basic mechanics → 85 quests).
- **Known follow-ups:** 10 action-id + 23 unique-id quest scripts are registered but have no map
  object (those areas aren't in this map) — harmless; item `18004` (×289 action ids) is worth a glance.

## Quick reference
| Task | Command |
|---|---|
| Rebuild server (C++ change) | `msbuild Black-Tek-Server.sln /p:Configuration=Release /p:Platform=64 /m` |
| Apply Lua/XML change | just restart `Black-Tek-Server.exe` (no rebuild) |
| Run server | `.\Black-Tek-Server.exe` (from repo root) |
| Run website | `php artisan serve --port=8000` (in BlackTek-AAC) |
| Fetch map | `powershell -ExecutionPolicy Bypass -File scripts/fetch-map.ps1` |
| Regenerate quest-object map | `python _parse_otbm.py` |
