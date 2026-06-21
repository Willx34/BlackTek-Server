#!/usr/bin/env bash
# Fetches the large realmap1098.otbm (133MB) from the GitHub Release into data/world/.
# The .otbm is too big for git on a public fork, so it lives as a Release asset.
# Requires the GitHub CLI (gh) authenticated.
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
echo "Downloading realmap1098.otbm from GitHub Release into $DIR/data/world ..."
gh release download realmap-1098-v1 --repo Willx34/BlackTek-Server --pattern "realmap1098.otbm" --dir "$DIR/data/world" --clobber
echo "Done. Map is at data/world/realmap1098.otbm"
