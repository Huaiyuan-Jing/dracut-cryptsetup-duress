#!/bin/bash

set -eu

read -r PASSWD

while read -r line
do
    salt="$(echo "$line" | cut -d'$' -f3)"
    hashed_in_tab="$(echo "$line" | cut -d'$' -f4)"
    hashed_user="$(echo "$PASSWD" | openssl passwd -6 -salt "$salt" -stdin | cut -d'$' -f4)"
    if [ "$hashed_in_tab" = "$hashed_user" ]
    then
        exit 0
    fi
done < /etc/dracut-cryptsetup-erase-signals

exit 1
