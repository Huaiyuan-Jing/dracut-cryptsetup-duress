#!/bin/bash

set -eu

USER_INPUT="$(systemd-ask-password)"
if [ "$(echo "$USER_INPUT" | check-cryptsetup-erase-signal)" -eq 0 ]
then
    DEV="$(blkid -t TYPE="crypto_LUKS" -o device)"
    echo "$DEV" | while read -r dev
    do
        cryptsetup erase -q "$dev"
    done
    poweroff
else
    echo -n "$USER_INPUT" | keyctl padd user cryptsetup_key @u
fi

