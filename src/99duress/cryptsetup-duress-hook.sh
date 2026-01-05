#!/bin/bash

set -eu

. /etc/dracut-cryptsetup-duress-mode

check_duress() {
    key_name="$1"
    key_id="$(keyctl search @u user "$key_name")"
    passwd="$(keyctl print "$key_id")"

    while read -r line
    do
        salt="$(echo "$line" | cut -d'$' -f3)"
        hashed_in_tab="$(echo "$line" | cut -d'$' -f4)"
        hashed_user="$(echo "$passwd" | openssl passwd -6 -salt "$salt" -stdin | cut -d'$' -f4)"
        if [ "$hashed_in_tab" = "$hashed_user" ]
        then
            echo 0
            exit
        fi
    done < /etc/dracut-cryptsetup-duress-signals

    echo 1
}

# get uuid and disk model name to mimic real cryptsetup prompt
MAPPER_NAME="$(cat /etc/dracut-cryptsetup-duress-rootfs-info | cut -d" " -f1)"
MODEL_NAME="$(cat /etc/dracut-cryptsetup-duress-rootfs-info | cut -d" " -f2)"

if [ "$PASSPHRASE" = "yes" ]
then
    if [ -z "$MODEL_NAME" ]
    then
        BANNER="Please enter passphrase for disk $MAPPER_NAME"
    else
        BANNER="Please enter passphrase for disk $MODEL_NAME ($MAPPER_NAME)"
    fi
    KEYNAME="cryptsetup"
fi

if [ "$TPM" = "yes" ]
then
    BANNER="Please enter LUKS2 token PIN"
    KEYNAME="luks2-pin"
fi

systemd-ask-password --keyname="$KEYNAME" --no-output "$BANNER"

if [ "$(check_duress $KEYNAME)" -eq 0 ]
then
    if [ "$PASSPHRASE" = "yes" ]
    then
        DEV="$(blkid -t TYPE="crypto_LUKS" -o device)"
        for dev in $DEV
        do
            cryptsetup erase -q "$dev"
        done
    fi

    if [ "$TPM" = "yes" ]
    then
        tpm2_evictcontrol -C o -c "$TPM_KEY_HANDLE"
    fi

    sleep 5  # mimic latency from calc
fi
