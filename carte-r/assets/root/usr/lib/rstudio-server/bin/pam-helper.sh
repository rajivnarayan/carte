#!/usr/bin/env sh

## Enforces the custom password specified in the PASSWORD environment variable
## Accepts login from any valid system user with the matching PASSWORD.

set -o nounset

IFS='' read -r password

# Only check the password - the username just needs to exist as a system user
getent passwd "${1}" > /dev/null 2>&1 && [ "${PASSWORD}" = "${password}" ]

