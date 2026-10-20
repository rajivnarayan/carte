#!/usr/bin/env bash
# Print the download URL for the latest RStudio Server .deb.
# Source: Posit's published downloads manifest (stable, amd64) or the
# dailies index (arm64, for which Posit publishes no stable build).
# Usage: rstudio_latest_url.sh [os] [arch]
#   os default: jammy (covers Ubuntu 22/24)
#   arch default: amd64

set -euo pipefail

MANIFEST_URL="https://www.rstudio.com/wp-content/downloads.json"
DAILIES_URL="https://dailies.rstudio.com/rstudio/latest/index.json"
OS="${1:-jammy}"
ARCH="${2:-amd64}"

if [[ "$ARCH" == "amd64" ]]; then
  curl -fsSL "$MANIFEST_URL" \
    | jq -er ".rstudio.open_source.stable.server.installer.\"${OS}\".url"
else
  curl -fsSL "$DAILIES_URL" \
    | jq -er ".products.server.platforms.\"${OS}-${ARCH}\".link"
fi
