#!/usr/bin/env python
import os
import platform
import subprocess
import xml.etree.ElementTree as ET
from xml.dom import minidom
from xml.etree.ElementTree import tostring
import re
import chardet
import distro
import usb.core
from pylspci.parsers import VerboseParser
import psutil

def getNetBasics():
    NetworkInfo = {}
    NetIf = psutil.net_if_addrs()
    statsIf = psutil.net_if_stats()
    for Interface in NetIf.keys():
        NetworkInfo[Interface] = {}
        # Up is not the same as connected (have to learn it the hard way)
        NetworkInfo[Interface]["Up"] = str(statsIf[Interface].isup)
        NetworkInfo[Interface]["duplex"] = str(statsIf[Interface].duplex)
        NetworkInfo[Interface]["mtu"] = str(statsIf[Interface].mtu)
        NetworkInfo[Interface]["speed"] = str(statsIf[Interface].speed)
    return NetworkInfo

def getPCI():
    lspci = VerboseParser()
    pciData = lspci.run()
    return pciData


def getUSB():
    usbDevsList = {}
    usbDevs = usb.core.find(find_all=True)
    for dev in usbDevs:
        usbDevsList[hex(dev.idVendor) + ":" + hex(dev.idProduct)] = {}
        usbDevsList[hex(dev.idVendor) + ":" + hex(dev.idProduct)]["Bus"] = str(dev.bus)
        usbDevsList[hex(dev.idVendor) + ":" + hex(dev.idProduct)]["AddrOnBus"] = str(dev.address)
        usbDevsList[hex(dev.idVendor) + ":" + hex(dev.idProduct)]["serial_number"] = str(dev.serial_number)
        usbDevsList[hex(dev.idVendor) + ":" + hex(dev.idProduct)]["product"] = str(dev.product)
        usbDevsList[hex(dev.idVendor) + ":" + hex(dev.idProduct)]["manufacturer"] = str(dev.manufacturer)
    return usbDevsList
def getDKMS():
    DKMSstats = {}
    dmksout = subprocess.check_output(['dkms', 'status'])
    dmksoutEnc = chardet.detect(dmksout)["encoding"]
    dmksout = str(dmksout, dmksoutEnc)
    for line in dmksout.splitlines():
        line = line.strip()
        infos = line.split(",")
        DKMSstats[infos[0]] = {}
        DKMSstats[infos[0]]["Version"] = infos[1].strip()
        DKMSstats[infos[0]]["KernelVersion"] = infos[2].strip()
        DKMSstats[infos[0]]["architecture"] = infos[3].split(":")[0].strip()
        DKMSstats[infos[0]]["status"] = infos[3].split(":")[1].strip()
    return DKMSstats

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
    PKGMgrCfg = {}
    #ToDo: need to be done for other distro
    if distro.linux_distribution(full_distribution_name=False)[0] == "arch":
        PacOut = subprocess.check_output(['pacman', '-Q', "-e"])
        PacOutEnc = chardet.detect(PacOut)["encoding"]
        PacOutStr = str(PacOut, PacOutEnc)
        for line in PacOutStr.splitlines():
            lineParts = line.split()
            installedPKG[lineParts[0]] = lineParts[1]
        with open("/etc/pacman.conf", "r") as pacmanCFG:
            readConfig = ""
            for line in pacmanCFG.readlines():
                if not line.startswith("#"):
                    readConfig = readConfig + line

            readConfig = re.sub(' +', ' ',readConfig)
            readConfig = os.linesep.join([s for s in readConfig.splitlines() if s])
            PKGMgrCfg["pacman.conf"] = readConfig
            IncludeList = []
            for line in readConfig.splitlines():
                if line.startswith("Include"):
                    IncludeList.append(line[line.index("/"):])
            IncludeList = list(dict.fromkeys(IncludeList))

            for file in IncludeList:
                with open(file, "r") as cfgFile:
                    readConfig = ""
                    for line in cfgFile.readlines():
                        if not line.startswith("#"):
                            readConfig = readConfig + line
                    readConfig = re.sub(' +', ' ', readConfig)
                    readConfig = os.linesep.join([s for s in readConfig.splitlines() if s])
                    PKGMgrCfg[file] = readConfig


    # ToDo: Add a part for creating the Text to send
    TuxReport = ET.Element("TuxReport", TicketID=IMNr)

    xml_LinuxDist = ET.SubElement(TuxReport, "LinuxDistro", name=LinuxDistro, version=LinuxDistroVersion)
    xml_instSoftware = ET.SubElement(xml_LinuxDist, "InstalledSoftware")
    xml_LinuxKernel = ET.SubElement(xml_LinuxDist, "LinuxKernel", VersionString=Kernel)
    xml_DKMS = ET.SubElement(xml_LinuxKernel, "DKMS")
    xml_System = ET.SubElement(TuxReport, "System")
    xml_Network = ET.SubElement(xml_System, "Network")
    xmlc_NetworkUp = ET.Comment("for a network interface the status Up does not mean that it is connected to anything. It just means it would accept connections.")
    xmlc_NetworkSpeed = ET.Comment("the NIC speed expressed in megabits, if it cannot be determined it will be set to 0.")
    xml_Network.insert(0,xmlc_NetworkUp)
    xml_Network.insert(1, xmlc_NetworkSpeed)
    xml_pciBus = ET.SubElement(xml_System, "PCI")
    xml_usbBus = ET.SubElement(xml_System, "USB")
    xml_PKGMgr = ET.SubElement(xml_LinuxDist, "PKGManager")
    for filename, cont in PKGMgrCfg.items():
        xml_PKFcfgFile = ET.SubElement(xml_PKGMgr, "cfg-file", filename=filename)
        xml_PKFcfgFile.text = cont
    for modName, info in getDKMS().items():
        xml_DKMSMod = ET.SubElement(xml_DKMS, modName, info)
    for CardName, info in getNetBasics().items():
        xml_Networkcard = ET.SubElement(xml_Network, CardName, info)

    for pkg in installedPKG.items():
        ET.SubElement(xml_instSoftware, "pkg", version=pkg[1]).text = pkg[0]

    xml_MotherBoard = ET.SubElement(xml_System, "MotherBoard", MotherBoard)

    for dev in pciDevs:
        xml_pciDev = ET.SubElement(xml_pciBus, "dev", id=dev.device.name, slot=str(dev.slot), vendor=str(dev.vendor),
                                   driver=str(dev.driver), name=dev.device.name, revision=str(dev.revision))
        for km in dev.kernel_modules:
            ET.SubElement(xml_pciDev, "kernel_module").text = km

    for devID, dev in usbDevs.items():
        localDict = dev
        localDict["id"] = devID
        xml_usbDev = ET.SubElement(xml_usbBus, "dev", localDict)


    tree = ET.ElementTree(TuxReport).getroot()
    xmlstr = minidom.parseString(tostring(tree, encoding='utf8')).toprettyxml()
    print(xmlstr)
    # ToDo: send Text to Tuxedo


if __name__ == '__main__':
    main()
