#!/usr/bin/env bash
# Print the download URL for the latest stable RStudio Server .deb.
# Source: Posit's published downloads manifest.
# Usage: rstudio_latest_url.sh [os]   # os default: jammy (covers Ubuntu 22/24)

set -euo pipefail

MANIFEST_URL="https://www.rstudio.com/wp-content/downloads.json"
OS="${1:-jammy}"

curl -fsSL "$MANIFEST_URL" \
  | jq -er ".rstudio.open_source.stable.server.installer.\"${OS}\".url"
