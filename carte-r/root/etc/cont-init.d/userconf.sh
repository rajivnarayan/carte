#!/usr/bin/with-contenv bash

## Set defaults for environmental variables in case they are undefined
USER=${USER:=carte}
PASSWORD=${PASSWORD:=carte:)}
USERID=${USERID:=1000}
GROUPID=${GROUPID:=1000}
SUDO=${SUDO:=FALSE}
UMASK=${UMASK:=022}

bold=$(tput bold)
normal=$(tput sgr0)

# Enforce changing password at run time
if [[ "$PASSWORD" == "carte:)" ]]; then
    printf "\n\n"
    tput bold
    printf "\e[31mERROR\e[39m: You must change the PASSWORD first! e.g. run with:\n"
    printf "docker run -e PASSWORD=\e[92m<YOUR_PASS>\e[39m ...\n"
    tput sgr0
    printf "\n\n"
    exit 1
fi

if [ "$USERID" -ne 1000 ]
## Configure user with a different USERID if requested.
  then
    echo "deleting user carte"
    userdel carte
    echo "creating new $USER with UID $USERID"
    useradd --create-home --shell /bin/bash --uid $USERID $USER
    chown -R $USER /home/$USER
    usermod -a -G staff $USER
elif [ "$USER" != "carte" ]
  then
    ## cannot move home folder when it's a shared volume, have to copy and change permissions instead
    cp -r /home/carte /home/$USER
    ## RENAME the user
    usermod -l $USER -d /home/$USER carte
    groupmod -n $USER carte
    usermod -a -G staff $USER
    chown -R $USER:$USER /home/$USER
    echo "USER is now $USER"
fi

if [ "$GROUPID" -ne 1000 ]
## Configure the primary GID of $USER with a different GROUPID if requested.
  then
    echo "Modifying primary group $(id $USER -g -n)"
    groupmod -g $GROUPID $(id $USER -g -n)
    echo "Primary group ID is now custom_group $GROUPID"
fi

## Add a password to user
echo "$USER:$PASSWORD" | sudo chpasswd

# Use Env flag to know if user should be added to sudoers
if [[ ${SUDO,,} == "true" ]]
  then
    adduser $USER sudo && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
    echo "$USER added to sudoers"
fi

## Change Umask value if desired
if [ "$UMASK" -ne 022 ]
  then
    #echo "server-set-umask=false" >> /etc/rstudio/rserver.conf
    echo "Sys.umask(mode=$UMASK)" >> /home/$USER/.Rprofile
fi

## add these to the global environment so they are avialable to the RStudio user
echo "HTTR_LOCALHOST=$HTTR_LOCALHOST" >> /etc/R/Renviron.site
echo "HTTR_PORT=$HTTR_PORT" >> /etc/R/Renviron.site
