#!/usr/bin/env python
import platform
import subprocess

import chardet
import distro
import usb.core
from pylspci.parsers import VerboseParser


def getPCI():
    lspci = VerboseParser()
    pciData = lspci.run()
    return pciData


def getUSB():
    usbDevsList = {}
    usbDevs = usb.core.find(find_all=True)
    for dev in usbDevs:
        usbDevsList[hex(dev.idVendor) + ":" + hex(dev.idProduct)] = {}
        usbDevsList[hex(dev.idVendor) + ":" + hex(dev.idProduct)]["Bus"] = dev.bus
        usbDevsList[hex(dev.idVendor) + ":" + hex(dev.idProduct)]["AddrOnBus"] = dev.address
        usbDevsList[hex(dev.idVendor) + ":" + hex(dev.idProduct)]["serial_number"] = dev.serial_number
        usbDevsList[hex(dev.idVendor) + ":" + hex(dev.idProduct)]["product"] = dev.product
        usbDevsList[hex(dev.idVendor) + ":" + hex(dev.idProduct)]["manufacturer"] = dev.manufacturer
    return usbDevsList

def main():
    getUSB()
    print(
        "Bitte beachten Sie, dass wir ohne Ticketnummer, Ihr Anliegen nicht bearbeiten können. / We cannot proceed your inquire without ticket number!")
    print(
        "Um eine Ticketnummer zu erhalten, schreiben Sie uns eine Mail an tux@tuxedocomputer.com mit Ihrem Anliegen. / To get an ticket number you can contact us by mail to tux@tuxedocomputers.com")
    IMNr = input("Wie lautet Ihre Ticketnummer? Mit [ENTER] bestätigen / What is your ticket number?: ")
    print("")
    print("Okay, we are working with ticket %s!" % IMNr)

    LinuxDistro = distro.linux_distribution()[0]
    LinuxDistroVersion = distro.linux_distribution()[0]
    Kernel = platform.platform()
    pciDevs = getPCI()
    usbDevs = getUSB()
    installedPKG = {}

    if distro.linux_distribution(full_distribution_name=False)[0] == "arch":
        PacOut = subprocess.check_output(['pacman', '-Q', "-e"])
        PacOutEnc = chardet.detect(PacOut)["encoding"]
        PacOutStr = str(PacOut, PacOutEnc)
        for line in PacOutStr.splitlines():
            lineParts = line.split()
            installedPKG[lineParts[0]] = lineParts[1]

    # ToDo: Add a part for creating the Text to send

    # ToDo: send Text to Tuxedo


if __name__ == '__main__':
    main()
