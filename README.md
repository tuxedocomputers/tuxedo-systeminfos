# TUXEDO Systeminfos

Script from TUXEDO Computers to get necessary information of the system for technical support purposes. \
For more information see [here](https://www.tuxedocomputers.com/en/Notebooks-PCs-systeminfossh.tuxedo).

**Note:** We do not collect any personal data and no credentials! We only collect information about your hard- and software configuration.

## Compatibility
The script uses some distribution specific commands. distribution specific commands are used for the following distributions:
- TUXEDO OS
- Ubuntu
- openSUSE Leap
- elementary OS
- KDE neon
- Manjaro

You will only receive official support for TUXEDO OS, Ubuntu and openSUSE from TUXEDO Computers

## Before you running the script
- Check if you got a ticketnumber. If you don't have a ticket number: contact us by e-mail to `tux[at]tuxedocomputers.com`
- Submitted system information **without** valid ticket number can't be processed

## What does the script do before collecting?
- Checks if there is an internet connection
- Installs needed extra packages for the listed distributions above

## What exactly does the script collect?

- Kernel version
- USB devices
- PCI devices
- Partitioning
- Network configuration
- Installed drivers/firmware
- Loaded drivers/firmware/modules
- Blocked wireless devices
- Grub bootloader configuration
- Logfile of the boot process
- System messages (dmesg)
- Mainboard functions
- System log file
- Audio devices
- Tomte configuration

## What does the script do after collecting?
- Sends the collected syteminformations to TUXEDO
- Removes temporary files
