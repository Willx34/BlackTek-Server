# Fetches the large realmap1098.otbm (133MB) from the GitHub Release into data/world/.
# The .otbm is too big for git on a public fork, so it lives as a Release asset.
# Requires the GitHub CLI (gh) authenticated.
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$dest = Join-Path $root "data\world"
Write-Host "Downloading realmap1098.otbm from GitHub Release into $dest ..."
gh release download realmap-1098-v1 --repo Willx34/BlackTek-Server --pattern "realmap1098.otbm" --dir $dest --clobber
Write-Host "Done. Map is at data/world/realmap1098.otbm"
