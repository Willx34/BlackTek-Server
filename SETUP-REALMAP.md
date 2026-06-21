# Real Tibia 10.98 Map setup (multi-device)

This fork integrates the full **real Tibia 10.98 map** (`realmap1098`) plus ported NPCs.
Because GitHub public forks can't use Git LFS, the 133 MB `realmap1098.otbm` is **not in git** —
it's published as a **GitHub Release asset** and fetched with a script. Everything else
(spawns, houses, NPCs, config) is in the repo.

## Setting up on a new device

```bash
# 1. Clone your fork and switch to the integration branch
git clone https://github.com/Willx34/BlackTek-Server.git
cd BlackTek-Server
git checkout realmap-1098-integration

# 2. Fetch the large map file from the Release (needs `gh` authenticated)
#    Windows:
powershell -ExecutionPolicy Bypass -File scripts/fetch-map.ps1
#    Linux/macOS:
bash scripts/fetch-map.sh
```

That places `realmap1098.otbm` in `data/world/`. The server is configured
(`config/server.toml` → `map_name = "realmap1098"`) to load it.

## Database
Credentials are **not** committed. Copy the example and set your local password:
```bash
cp config/database.toml.example config/database.toml
# then edit config/database.toml -> [mysql] pass = "<your local password>"
```
It targets a local MariaDB (`forgottenserver` DB, user `forgottenserver`). Create the
DB + import `schema.sql`, then start the server. Account + character creation is handled
by the **BlackTek-AAC website** (the in-game account manager is disabled).

## Updating the map asset
If you change the map, re-upload it:
```bash
gh release upload realmap-1098-v1 data/world/realmap1098.otbm --clobber --repo Willx34/BlackTek-Server
```
