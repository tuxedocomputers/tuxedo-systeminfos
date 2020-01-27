#!/usr/bin/env python
import platform
import subprocess
import xml.etree.ElementTree as ET
from xml.dom import minidom
from xml.etree.ElementTree import tostring

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

    MotherBoard = {}
    with open('/sys/devices/virtual/dmi/id/board_vendor') as f:
        MotherBoard["vendor"] = f.readline().rstrip()

    with open('/sys/devices/virtual/dmi/id/board_name') as f:
        MotherBoard["name"] = f.readline().rstrip()

    with open('/sys/devices/virtual/dmi/id/bios_version') as f:
        MotherBoard["bios_version"] = f.readline().rstrip()

    with open('/sys/devices/virtual/dmi/id/bios_vendor') as f:
        MotherBoard["bios_vendor"] = f.readline().rstrip()


    LinuxDistro = distro.linux_distribution()[0]
    LinuxDistroVersion = distro.linux_distribution()[0]
    Kernel = platform.platform()
    pciDevs = getPCI()
    usbDevs = getUSB()
    installedPKG = {}

    #ToDo: need to be done for other distro
    if distro.linux_distribution(full_distribution_name=False)[0] == "arch":
        PacOut = subprocess.check_output(['pacman', '-Q', "-e"])
        PacOutEnc = chardet.detect(PacOut)["encoding"]
        PacOutStr = str(PacOut, PacOutEnc)
        for line in PacOutStr.splitlines():
            lineParts = line.split()
            installedPKG[lineParts[0]] = lineParts[1]

    # ToDo: Add a part for creating the Text to send
    TuxReport = ET.Element("TuxReport", TicketID=IMNr)

    xml_LinuxDist = ET.SubElement(TuxReport, "LinuxDistro", name=LinuxDistro, version=LinuxDistroVersion)
    xml_instSoftware = ET.SubElement(xml_LinuxDist, "InstalledSoftware")
    xml_LinuxKernel = ET.SubElement(xml_LinuxDist, "LinuxKernel", VersionString=Kernel)
    xml_System = ET.SubElement(TuxReport, "System")
    xml_pciBus = ET.SubElement(xml_System, "PCI")

    for pkg in installedPKG.items():
        ET.SubElement(xml_instSoftware, "pkg", version=pkg[1]).text = pkg[0]

    xml_MotherBoard = ET.SubElement(xml_System, "MotherBoard", MotherBoard)

    for dev in pciDevs:
        xml_pciDev = ET.SubElement(xml_pciBus, "dev", id=dev.device.name, slot=str(dev.slot), vendor=str(dev.vendor),
                                   driver=str(dev.driver), name=dev.device.name, revision=str(dev.revision))
        for km in dev.kernel_modules:
            ET.SubElement(xml_pciDev, "kernel_module").text = km

    tree = ET.ElementTree(TuxReport).getroot()
    xmlstr = minidom.parseString(tostring(tree, encoding='utf8')).toprettyxml()
    print(xmlstr)
    # ToDo: send Text to Tuxedo


if __name__ == '__main__':
    main()
