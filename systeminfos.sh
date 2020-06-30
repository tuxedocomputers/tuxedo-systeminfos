#!/bin/sh
serverURI=https://www.tuxedocomputers.com/tuxedosysteminfos/systeminfo.php
infoFileName=/home/systeminfos.txt
lspciFileName=/home/lspcioutput.txt
udevFileName=/home/udevoutput.txt
logFileName=/home/logoutput.txt
packagesFileName=/home/packagesoutput.txt
audioFileName=/home/audiooutput.txt
networkFileName=/home/networkoutput.txt
boardFileName=/home/boardoutput.txt
started=$(date +"%d.%m.%y-%H:%Mh")
ticketnumber=$1

if [ "$(id -u)" -ne 0 ]; then
    echo -e "\033[31;1mYou aren't 'root', but '$(whoami)'. Aren't you?! / Sie sind nicht 'root', aber '$(whoami)'. Oder etwa nicht?! \033[0m"
    exec sudo su -c "bash '$(basename $0)' $1"
fi

if [ -z $ticketnumber ]; then
    printf "\n"
    printf "Wie lautet Ihre Ticketnummer? Mit [ENTER] bestätigen / What is your ticket number? Confirm with [ENTER]\n"
    printf "Bitte beachten Sie, dass wir ohne Ticketnummer, Ihr Anliegen nicht bearbeiten können. / We cannot proceed your inquire without ticket number!\n"
    printf "Um eine Ticketnummer zu erhalten, schreiben Sie uns eine Mail an tux[at]tuxedocomputer.com mit Ihrem Anliegen. / To get an ticket number you can contact us by mail to tux[at]tuxedocomputers.com\n"
    printf "\e[31mWenn sie keine Ticketnummer haben, beenden sie das Skript bitte JETZT mit Strg + C / If you do not have a ticket number, please exit the script NOW with Ctrl + C.\e[1m\n"
    printf "\e[31mDas Script sammelt keinerlei persönliche Daten und keine Zugangsdaten! / The script does not collect any personal data and no access data!\e[1m\n"
    printf "\e[31mEs werden lediglich Informationen über Ihre Hard- und Softwarekonfiguration gesammelt. / Only information about your hardware and software configuration is collected.\e[1m\n"
    printf "\n"
    read -p "Ticket#: " ticketnumber
    if [ -z $ticketnumber ]; then
        printf "\e[31mKeine Tickernummer angegeben. Beende. / No ticker number given. Quitting.\e[1m\n"
        exit 1
    fi
fi

apt -y install curl zip > /dev/null 2>&1
zypper in -y curl zip > /dev/null 2>&1

printf "\n"
printf "Ticketnummer: " $ticketnumber > $infoFileName
printf "systeminfos.sh started at" $started | tee -a $infoFileName $lspciFileName $udevFileName $logFileName $packagesFileName $audioFileName $networkFileName $boardFileName

printf "\n\n\n" >> $infoFileName

if [ -f /var/log/tuxedo-install.log ]; then
    head -n 1 /var/log/tuxedo-install.log >> $logFileName
    cat /var/log/tuxedo-install.log | grep "Starting FAI execution" >> $logFileName
fi


printf "\n\n\n">> $logFileName

printf "uname -a" >> $infoFileName
uname -a >> $infoFileName

printf "\n\n\n" >> $infoFileName
printf" lsb_release -a" >> $infoFileName
lsb_release -a >> $infoFileName

printf "\n\n\n" >> $infoFileName
printf "XDG_SESSION_TYPE" >> $infoFileName
printf $XDG_SESSION_TYPE >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "/sys/devices/virtual/dmi/id/board_vendor" >> $boardFileName
cat /sys/devices/virtual/dmi/id/board_vendor >> $boardFileName

printf "\n\n\n" >> $boardFileName
printf "/sys/devices/virtual/dmi/id/board_name" >> $boardFileName
cat /sys/devices/virtual/dmi/id/board_name >> $boardFileName

printf "\n\n\n" >> $boardFileName

echo '/sys/devices/virtual/dmi/id/board_serial
' >> $boardFileName
cat /sys/devices/virtual/dmi/id/board_serial >> $boardFileName

printf "\n\n\n" >> $boardFileName

echo '/sys/devices/virtual/dmi/id/bios_version
dmidecode | grep "Firmware Revision"
' >> $boardFileName
cat /sys/devices/virtual/dmi/id/bios_version >> $boardFileName
echo "" >> $boardFileName
echo "EC-Version" >> $boardFileName
dmidecode | grep "Firmware Revision" >> $boardFileName

printf "\n\n\n" >> $infoFileName

echo 'lsusb
' >> $infoFileName
lsusb >> $infoFileName

printf "\n\n\n" >> $infoFileName

echo 'lspci
' >> $lspciFileName
lspci >> $lspciFileName

printf "\n\n\n" >> $infoFileName

echo 'aplay -l
' >> $audioFileName
aplay -l >> $audioFileName

printf "\n\n\n" >> $audioFileName

echo 'cat /proc/asound/card*/codec*
' >> $audioFileName
cat /proc/asound/card*/codec* >> $audioFileName

printf "\n\n\n" >> $audioFileName

echo 'lspci -v | grep -A7 -i "audio"
' >> $audioFileName
lspci -v | grep -A7 -i "audio" >> $audioFileName

printf "\n\n\n" >> $audioFileName

echo 'pacmd list-sink-inputs
' >> $audioFileName
pacmd list-sink-inputs >> $audioFileName

printf "\n\n\n" >> $audioFileName

echo 'arecord -l
' >> $audioFileName
arecord -l >> $audioFileName

printf "\n\n\n" >> $audioFileName

echo 'fuser -v /dev/snd/*
' >> $audioFileName
fuser -v /dev/snd/* >> $audioFileName

printf "\n\n\n" >> $infoFileName

echo 'lspci -nnk | grep -E -A3 -i "Ethernet|Network"
' >> $networkFileName
lspci -nnk | grep -E -A3 -i "Ethernet|Network" >> $networkFileName

printf "\n\n\n" >> $lspciFileName

echo 'lspci -vv
' >> $lspciFileName
lspci -vv >> $lspciFileName

printf "\n\n\n" >> $infoFileName

echo 'Display Info (/sys/kernel/debug/dri/*/i1915_display_info)
' >> $infoFileName
grep -A 100 "^Connector info" /sys/kernel/debug/dri/*/i915_display_info >> $infoFileName

printf "\n\n\n" >> $infoFileName

echo 'xinput
' >> $infoFileName
xinput >> $infoFileName

printf "\n\n\n" >> $infoFileName

echo 'lsblk
' >> $infoFileName
lsblk >> $infoFileName

printf "\n\n\n" >> $infoFileName

echo '/etc/default/grub
' >> $infoFileName
cat /etc/default/grub >> $infoFileName

printf "\n\n\n" >> $infoFileName

echo 'free -h
' >> $infoFileName
free -h >> $infoFileName

printf "\n\n\n" >> $infoFileName

echo 'sources.list
' >> $packagesFileName
cat /etc/apt/sources.list >> $packagesFileName

printf "\n\n\n" >> $packagesFileName

echo '/etc/apt/sources.list.d
' >> $packagesFileName
ls /etc/apt/sources.list.d >> $packagesFileName

printf "\n\n\n" >> $packagesFileName
echo '/etc/apt/sources.list.d ppa
' >> $packagesFileName
cat /etc/apt/sources.list.d/* >> $packagesFileName

printf "\n\n\n" >> $packagesFileName

echo '/etc/zypp/repos.d
' >> $packagesFileName
ls -al /etc/zypp/repos.d/ >> $packagesFileName

printf "\n\n\n" >> $infoFileName

echo '/etc/udev/rules.d/
' >> $udevFileName
ls /etc/udev/rules.d/ >> $udevFileName

printf "\n\n\n" >> $udevFileName

echo '/etc/udev/rules.d/ files
' >> $udevFileName
cat /etc/udev/rules.d/* >> $udevFileName

printf "\n\n\n" >> $networkFileName

echo 'ifconfig
' >> $networkFileName
ifconfig >> $networkFileName

printf "\n\n\n" >> $networkFileName

echo 'ip addr show
' >> $networkFileName
ip addr show >> $networkFileName

printf "\n\n\n" >> $networkFileName

echo 'ip link show
' >> $networkFileName
ip link show >> $networkFileName

printf "\n\n\n" >> $networkFileName
echo 'ip route show
' >> $networkFileName
ip route show >> $networkFileName

printf "\n\n\n" >> $infoFileName

echo 'dmesg|grep firmware
' >> $infoFileName
dmesg|grep firmware >> $infoFileName

printf "\n\n\n" >> $infoFileName

echo 'systemctl status systemd-modules-load.service
' >> $logFileName
systemctl status systemd-modules-load.service >> $logFileName

printf "\n\n\n" >> $packagesFileName

echo 'dpkg -l | grep nvidia
' >> $packagesFileName
dpkg -l|grep nvidia >> $packagesFileName

printf "\n\n\n" >> $packagesFileName

echo 'dpkg -l | grep tuxedo
' >> $packagesFileName
dpkg -l|grep tuxedo >> $packagesFileName

printf "\n\n\n" >> $packagesFileName

echo 'rpm -qa | grep nvidia
' >> $packagesFileName
rpm -qa | grep nvidia >> $packagesFileName

printf "\n\n\n">> $packagesFileName

echo 'rpm -qa | grep tuxedo
' >> $packagesFileName
rpm -qa | grep tuxedo >> $packagesFileName

printf "\n\n\n" >> $infoFileName

echo 'glxinfo|grep vendor
' >> $infoFileName
glxinfo|grep vendor >> $infoFileName

printf "\n\n\n">> $infoFileName

echo 'Desktop
' >> $infoFileName
echo $XDG_CURRENT_DESKTOP >> $infoFileName

printf "\n\n\n" >> $infoFileName

echo 'Display-Manager
' >> $infoFileName
cat /etc/systemd/system/display-manager.service >> $infoFileName
cat /etc/alternatives/default-displaymanager | grep DISPLAYMANAGER >> $infoFileName

printf "\n\n\n" >> $networkFileName

echo 'iwconfig
' >> $networkFileName
iwconfig >> $networkFileName

printf "\n\n\n" >> $infoFileName

echo 'lsmod
' >> $infoFileName
lsmod >> $infoFileName

printf "\n\n\n" >> $networkFileName

echo 'rfkill list
' >> $networkFileName
rfkill list >> $networkFileName

printf "\n\n\n" >> $infoFileName

echo 'ls -l /lib/firmware
' >> $infoFileName
ls -l /lib/firmware >> $infoFileName

printf "\n\n\n" >> $logFileName

echo 'cat /var/log/boot.log
' >> $logFileName
cat /var/log/boot.log >> $logFileName

printf "\n\n\n" >> $infoFileName

echo 'upower -i $(upower -e | grep 'BAT')
' >> $infoFileName
upower -i $(upower -e | grep 'BAT') >> $infoFileName

printf "\n\n\n" >> $logFileName

echo 'dmesg
' >> $logFileName
dmesg >> $logFileName

printf "\n\n\n" >> $infoFileName

echo 'dkms status
' >> $infoFileName
dkms status >> $infoFileName

printf "\n\n\n" >> $infoFileName

echo 'lshw
' >> $infoFileName
lshw >> $infoFileName

printf "\n\n\n" >> $boardFileName

echo 'dmidecode
' >> $boardFileName
dmidecode >> $boardFileName

printf "\n\n\n" >> $logFileName

echo '/var/log/apt/history.log
' >> $logFileName
cat /var/log/apt/history.log >> $logFileName

printf "\n\n\n" >> $logFileName

echo '/var/log/zypp/history
' >> $logFileName
cat /var/log/zypp/history >> $logFileName

printf "\n\n\n" >> $packagesFileName

echo 'dpkg -l
' >> $packagesFileName
dpkg -l >> $packagesFileName
rpm -qa >> $packagesFileName

printf "\n\n\n" >> $logFileName

echo 'cat /var/log/syslog
' >> $logFileName
cat /var/log/syslog >> $logFileName
journalctl --system -e >> $logFileName

mv $infoFileName systeminfos-$ticketnumber.txt
mv $lspciFileName lspci-$ticketnumber.txt
mv $udevFileName udev-$ticketnumber.txt
mv $logFileName log-$ticketnumber.txt
mv $packagesFileName packages-$ticketnumber.txt
mv $audioFileName audio-$ticketnumber.txt
mv $networkFileName network-$ticketnumber.txt
mv $boardFileName boardinfo-$ticketnumber.txt

zip -9 systeminfos-$ticketnumber.zip *-$ticketnumber.txt

curl -F "file=@systeminfos-$ticketnumber.zip" $serverURI?ticketnumber=$ticketnumber

rm systeminfos-$ticketnumber.zip *-$ticketnumber.txt

exit 0;
