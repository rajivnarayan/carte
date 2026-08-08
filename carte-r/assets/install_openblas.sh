#!/bin/bash
set -euo pipefail

# Script to download the latest OpenBLAS x64 binary release from GitHub

REPO="OpenMathLib/OpenBLAS"
API_URL="https://api.github.com/repos/${REPO}/releases/latest"
DOWNLOAD_DIR="${1:-.}"
INSTALL_DIR="${2:-.}"

echo "Fetching latest OpenBLAS release information..."

# Get release information from GitHub API
RELEASE_JSON=$(curl -sL "${API_URL}")

# Extract version tag
VERSION=$(echo "${RELEASE_JSON}" | grep -o '"tag_name": *"[^"]*"' | head -1 | cut -d'"' -f4)
echo "Latest version: ${VERSION}"

# Find x64 zip file URLs
# Looking for patterns like: *x64.zip or *x86_64.zip
ASSET_URL=$(echo "${RELEASE_JSON}" | \
    grep -o '"browser_download_url": *"[^"]*"' | \
    cut -d'"' -f4 | \
    grep -iE '(x64|x86_64)\.zip$' | \
    head -1)

if [ -z "${ASSET_URL}" ]; then
    echo "Error: No x64 zip file found in latest release"
    exit 1
fi

FILENAME=$(basename "${ASSET_URL}")
echo "Found asset: ${FILENAME}"
echo "Download URL: ${ASSET_URL}"

# Create download directory if it doesn't exist
mkdir -p "${DOWNLOAD_DIR}"

# Download the file
echo "Downloading to ${DOWNLOAD_DIR}/${FILENAME}..."
curl -L -o "${DOWNLOAD_DIR}/${FILENAME}" "${ASSET_URL}"

echo "Download complete: ${DOWNLOAD_DIR}/${FILENAME}"

# Install library
unzip ${DOWNLOAD_DIR}/${FILENAME} -d ${INSTALL_DIR}
echo "Install complete: ${INSTALL_DIR}"

# cleanup
rm ${DOWNLOAD_DIR}/${FILENAME}

echo "Completed install"
