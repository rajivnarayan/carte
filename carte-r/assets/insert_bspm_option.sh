#!/bin/bash
# Insert options(bspm.sudo = TRUE) before bspm::enable() in Rprofile.site

FILE="/etc/R/Rprofile.site"

# Check if file exists
if [[ ! -f "$FILE" ]]; then
    echo "Error: $FILE not found"
    exit 1
fi

# Check if bspm::enable() exists
if ! grep -q "bspm::enable()" "$FILE"; then
    echo "Error: bspm::enable() not found in $FILE"
    exit 1
fi

# Check if the option is already present
if grep -q "options(bspm.sudo = TRUE)" "$FILE"; then
    echo "options(bspm.sudo = TRUE) already exists in $FILE"
    exit 0
fi

# Insert the line before bspm::enable()
sed -i '/bspm::enable()/i options(bspm.sudo = TRUE)' "$FILE"

echo "Successfully inserted options(bspm.sudo = TRUE) before bspm::enable() in $FILE"
