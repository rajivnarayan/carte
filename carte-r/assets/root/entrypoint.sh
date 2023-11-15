#!/bin/bash
set -eo pipefail
shopt -s nullglob

USER=${USER:=carte}
PASSWORD=${PASSWORD:=carte:)}
#USERID=${USERID:=1000}
#GROUPID=${GROUPID:=1000}
#ROOT=${ROOT:=FALSE}
#UMASK=${UMASK:=022}


# check to see if this file is being run or sourced from another script
_is_sourced() {
	# https://unix.stackexchange.com/a/215279
	[ "${#FUNCNAME[@]}" -ge 2 ] \
		&& [ "${FUNCNAME[0]}" = '_is_sourced' ] \
		&& [ "${FUNCNAME[1]}" = 'source' ]
}

change_password() {
if [[ "$PASSWORD" == "carte:)" ]]; then
    printf "\n\n"
    tput bold
    printf "\e[31mERROR\e[39m: You must change the PASSWORD first! e.g. run with:\n"
    printf "docker run -e PASSWORD=\e[92m<YOUR_PASS>\e[39m ...\n"
    tput sgr0
    printf "\n\n"
    exit 1
fi
echo "$USER:$PASSWORD" | chpasswd
}


_main() {

  # enforce changing the user password on entry
  change_password
  
  # If container is started as root user, restart as dedicated mysql user
  if [ "$(id -u)" = "0" ]; then
	echo "Running container as root!"
  fi
  
  exec "$@"
}


# If we are sourced from elsewhere, don't perform any further actions
if ! _is_sourced; then
	_main "$@"
fi
