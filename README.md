# TUXEDO Systeminfos

Script from TUXEDO Computers to get necessary information of the system for technical support purposes. \
For more information see [here](https://www.tuxedocomputers.com/en/Information-on-system-diagnostics.tuxedo).

**Note:** We do not collect any personal data and no credentials! We only collect information about your hard- and software configuration.

## Compatibility
The script uses some distribution specific commands. distribution specific commands are used for the following distributions:
- TUXEDO OS
- Ubuntu LTS
- openSUSE Leap 15.x
- elementary OS
- KDE neon
- Arch Linux (including distributions based on Arch Linux like e.g. CachyOS, EndeavourOS and Manjaro)
- Fedora

You will only receive official support for TUXEDO OS and Ubuntu from TUXEDO Computers

## Before you running the script
- Check if you got a ticketnumber. If you don't have a ticket number: contact us by e-mail to `tux[at]tuxedocomputers.com` first.
- Submitted system information **without** valid ticket number can't be processed

## What does the script do before collecting?
It checks, if there is an internet connection. Without an internet connection, the system information can't be submitted. \
If there is no Internet connection, the script will be aborted. Please make sure, that you have an internet connection.

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
- Battery information/health

## What does the script do after collecting?
- Sends the collected system information to TUXEDO
- Removes temporary files
