#!/bin/bash

check() {
    return 0
}

depends() {
    echo bash systemd systemd-ask-password systemd-cryptsetup crypt
}

install() {
    inst /etc/dracut-cryptsetup-duress-signals /etc/dracut-cryptsetup-duress-signals
    inst "$moddir/cryptsetup-duress-hook.sh" /usr/bin/cryptsetup-duress-hook.sh
    
    inst_multiple openssl cut sleep cryptsetup udevadm keyctl head readlink

    # 3. Install Systemd Service
    inst_simple "$moddir/cryptsetup-duress.service" \
        /usr/lib/systemd/system/cryptsetup-duress.service

    # 4. Enable the Service
    # We manually create the symlink to start it during early boot (sysinit)
    mkdir -p "$initdir/usr/lib/systemd/system/sysinit.target.wants"
    ln_r "/usr/lib/systemd/system/cryptsetup-duress.service" \
         "/usr/lib/systemd/system/sysinit.target.wants/cryptsetup-duress.service"
}
