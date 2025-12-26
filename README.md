# Dracut Cryptsetup Duress Module

## Project Overview

This project is a Linux kernel `initramfs` module designed to enhance **Full Disk Encryption (FDE)** security. It implements a plausible deniability and emergency data protection protocol using the `dracut` infrastructure.

In high-security environments, standard encryption (data-at-rest protection) protects against theft but may be insufficient if physical security is compromised and the user is coerced into decrypting the device. This module allows the registration of specific "duress" signals. When a duress signal is detected during the early boot stage, the system executes a cryptographic erasure of the LUKS headers. This renders the data permanently inaccessible before any decryption keys can be extracted.

This project serves as a research implementation of **defensive asset protection mechanisms** within the Linux boot process, utilizing `systemd`, kernel keyrings, and LUKS management tools.

## Technical Context & Related Works

The concept of "Emergency Data Protection" is established in mobile security research (e.g., **GrapheneOS**, which supports duress PINs for profile wiping) and desktop privacy tools.
* **Hidden Volumes:** Tools like **VeraCrypt** and **Shufflecake** (Linux) use nested containers to hide data existence.
* **Destructive Wiping:** This project focuses on the *Cryptographic Erasure* approach. By destroying the encryption header, the data remains on the disk but becomes statistically indistinguishable from random noise, effectively preventing recovery even if the correct master key is later obtained.

## Implementation Details

This solution is delivered as a custom **Dracut module**. It integrates into the `initramfs` (initial RAM filesystem) to intercept user input before the root file system is mounted.

### Architecture

1.  **User-Space Utility (`duressctl`):** A management tool to register duress signal hashes and configure the boot prompt mode (Passphrase vs. TPM).
2.  **Kernel Keyring Hook:** A script that intercepts input using `systemd-ask-password`. It pushes input to the kernel keyring to allow seamless handover to the actual `systemd-cryptsetup` process if the standard password is used.
3.  **Boot Integration:** A systemd service ensures the hook runs prior to the standard decryption target.

### Installation

The project includes a `Makefile` for automated installation of the module and utilities.

```shell
sudo make install
```

### Usage & Configuration

#### 1. Registering Signals

Use the control utility to hash and store emergency signals. These are stored in the system configuration.

```shell
sudo duressctl add
```

#### 2. Mode Configuration

To maintain operational security (OpSec), the emergency prompt must be indistinguishable from the standard login prompt. You can configure the module to mimic a standard passphrase prompt or a TPM PIN prompt.

```shell
sudo duressctl mode passphrase     # passphrase mode
sudo duressctl mode tpm            # tpm mode
```

#### 3. System Integration

Once configured, the `initramfs` image must be regenerated to include the new module and configurations.

```shell
sudo dracut -f -v
```

## Security Analysis & Limitations

### 1. Threat Model: Pre-Imaging
This protocol defends against *immediate* physical compromise. It does not protect against attacks where an unauthorized actor has already cloned (imaged) the encrypted drive prior to the coercion event. In such cases, the erased header could be restored from the backup image.

### 2. Hardware Limitations (SSD Wear Leveling)
On NAND-based storage (SSDs), issuing a header wipe command does not guarantee immediate physical overwriting of the data cells due to wear-leveling algorithms. The controller may mark the old header block as "invalid" and write zeros to a new block. Sophisticated forensic analysis at the controller level could potentially recover the old header before the drive's Garbage Collection (GC) cycle completes.
* *Mitigation Research:* Future work involves binding the LUKS master key to the **TPM NVRAM**. Since TPM storage can be reset instantly and reliably, this would bypass SSD wear-leveling concerns.

### 3. Operational Risks
This tool is destructive by design. There is no recovery mechanism once the LUKS header is wiped. Users are advised to maintain secure, off-site backups if data recovery is required after a false-positive trigger.

### 4. Behavioral Assumptions (Rational Actor Model)
This protocol implements a technical data protection mechanism. It assumes a "rational actor" threat model, where the unauthorized actor's primary goal is data acquisition. The premise is that demonstrating the irretrievable loss of data removes the incentive for continued coercion. However, this tool is strictly a technical control; it cannot mitigate physical safety risks if the unauthorized actor behaves irrationally or punitively following the data loss.

### 5. System Hardening Recommendation (Emergency Shell)
If the erasure protocol is triggered, the boot process will fail (as the encrypted volume is no longer accessible), and the system may drop into a `dracut` emergency shell. To prevent unauthorized actors from utilizing this shell to probe the remaining hardware state, it is critical to **lock the root account**.
* *Implementation:* Ensure the root is locked in the `/etc/shadow` file included in the initramfs generation.

## Project Roadmap

The primary focus for future development addresses the hardware limitations of modern SSDs.

* **TPM 2.0 Integration & Key Binding:**
    To bypass SSD wear-leveling issues, future versions aim to bind the LUKS master key to the platform's TPM (Trusted Platform Module). In this configuration, the duress signal would trigger a reset of the TPM's NVRAM or specific PCR banks. Since the TPM state can be instantaneously and reliably cleared, this would render the decryption key mathematically unrecoverable, regardless of the physical state of the SSD's memory cells.

    *Community contributions and Pull Requests regarding TPM 2.0 integration are highly encouraged.*

## Legal Disclaimer

### 1. Educational and Defensive Purpose
This software is developed for **educational and research purposes** in the fields of computer security, operating system architecture, and privacy engineering. It is intended to demonstrate methods for asset protection in high-security environments. The author does not condone the use of this software for concealing evidence of illegal activity or obstructing justice.

### 2. No Warranty (GPLv3)
This program is free software: you can redistribute it and/or modify it under the terms of the **GNU General Public License (GPLv3)**. This program is distributed in the hope that it will be useful, but **WITHOUT ANY WARRANTY**; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

### 3. Liability for Data Loss
**WARNING:** The primary function of this software is the **permanent and irretrievable destruction of data access**. The author is not responsible for any data loss, system damage, or operational failures resulting from the use, misuse, or malfunction of this software. Users deploy this tool at their own risk.

### 4. Compliance
Users are responsible for ensuring that their use of this software complies with all applicable local, state, and federal laws, including data retention regulations and export control laws.