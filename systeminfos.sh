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
    printf "Bitte beachten sie dass sie nur für Ubuntu und openSUSE Support von TUXEDO Computers erhalten. / Please note that you only get support for Ubuntu and openSUSE from TUXEDO Computers."
    printf "\n"
    read -p "Ticket#: " ticketnumber
    if [ -z $ticketnumber ]; then
        printf "\e[31mKeine Tickernummer angegeben. Beende. / No ticker number given. Quitting.\e[1m\n"
        exit 1
    fi
fi

if [  -n "$(lsb_release -a | grep Ubuntu)" ]; then
    apt -y install curl zip > /dev/null 2>&1
fi

if [  -n "$(lsb_release -a | grep openSUSE)" ]; then
    zypper in -y curl zip > /dev/null 2>&1
else
    printf "Unsupported Distribution! Skip\n"
fi
printf "\n"
echo 'Ticketnummer: ' $ticketnumber | tee -a $infoFileName $lspciFileName $udevFileName $logFileName $packagesFileName $audioFileName $networkFileName $boardFileName
echo 'systeminfos.sh started at' $started | tee -a $infoFileName $lspciFileName $udevFileName $logFileName $packagesFileName $audioFileName $networkFileName $boardFileName

printf "\n\n\n" >> $infoFileName

### $infoFileName Section

printf 'uname -a\n' >> $infoFileName
uname -a >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "lsb_release -a\n" >> $infoFileName
lsb_release -a >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "XDG_SESSION_TYPE\n" >> $infoFileName
printf $XDG_SESSION_TYPE >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "lsusb\n" >> $infoFileName
lsusb >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "Display Info (/sys/kernel/debug/dri/*/i1915_display_info)\n" >> $infoFileName
grep -A 100 "^Connector info" /sys/kernel/debug/dri/*/i915_display_info >> $infoFileName


printf "\n\n\n" >> $infoFileName

printf "xinput\n" >> $infoFileName
xinput >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "lsblk\n" >> $infoFileName
lsblk >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "/etc/default/grub\n" >> $infoFileName
cat /etc/default/grub >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "free -h\n" >> $infoFileName
free -h >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "dmesg|grep firmware\n" >> $infoFileName
dmesg|grep firmware >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "dkms status\n" >> $infoFileName
dkms status >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "lshw\n" >> $infoFileName
lshw >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "upower -i $(upower -e | grep 'BAT')\n" >> $infoFileName
upower -i $(upower -e | grep 'BAT') >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "lsmod\n" >> $infoFileName
lsmod >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "ls -l /lib/firmware\n" >> $infoFileName
ls -l /lib/firmware >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "glxinfo|grep vendor\n" >> $infoFileName
glxinfo|grep vendor >> $infoFileName

printf "\n\n\n">> $infoFileName

printf "Desktop\n" >> $infoFileName
echo $XDG_CURRENT_DESKTOP >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "Display-Manager\n" >> $infoFileName
cat /etc/systemd/system/display-manager.service >> $infoFileName
cat /etc/alternatives/default-displaymanager | grep DISPLAYMANAGER >> $infoFileName

### $logFileName Section

if [ -f /var/log/tuxedo-install.log ]; then
    head -n 1 /var/log/tuxedo-install.log >> $logFileName
    cat /var/log/tuxedo-install.log | grep "Starting FAI execution" >> $logFileName
fi

printf "\n\n\n">> $logFileName

if [ -n "$(lsb_release -a | grep Ubuntu)" ]; then
    printf "/var/log/apt/history.log\n" >> $logFileName
    cat /var/log/apt/history.log >> $logFileName
    printf "\n\n\n" >> $logFileName
fi

if [ -n "$(lsb_release -a | grep openSUSE)" ]; then
    printf "/var/log/zypp/history\n" >> $logFileName
    cat /var/log/zypp/history >> $logFileName
    printf "\n\n\n" >> $logFileName
else
    printf "Unsupported Distribution! Skip"
fi

"cat /var/log/syslog\n" >> $logFileName
cat /var/log/syslog >> $logFileName
journalctl --system -e >> $logFileName

printf "\n\n\n" >> $logFileName

printf "cat /var/log/boot.log\n" >> $logFileName
cat /var/log/boot.log >> $logFileName

printf "\n\n\n" >> $logFileName

printf "dmesg\n" >> $logFileName
dmesg >> $logFileName

printf "systemctl status systemd-modules-load.service\n" >> $logFileName
systemctl status systemd-modules-load.service >> $logFileName

printf "\n\n\n" >> $packagesFileName

### $boardFileName Section

printf "/sys/devices/virtual/dmi/id/board_vendor\n" >> $boardFileName
cat /sys/devices/virtual/dmi/id/board_vendor >> $boardFileName

printf "\n\n\n" >> $boardFileName

printf "/sys/devices/virtual/dmi/id/board_name\n" >> $boardFileName
cat /sys/devices/virtual/dmi/id/board_name >> $boardFileName

printf "\n\n\n" >> $boardFileName

printf "/sys/devices/virtual/dmi/id/board_serial\n" >> $boardFileName
cat /sys/devices/virtual/dmi/id/board_serial >> $boardFileName

printf "\n\n\n" >> $boardFileName

printf "/sys/devices/virtual/dmi/id/bios_version\n" >> $boardFileName
cat /sys/devices/virtual/dmi/id/bios_version >> $boardFileName
printf "\n\n"
printf "EC-Version\n" >> $boardFileName
dmidecode | grep "Firmware Revision\n" >> $boardFileName

printf "\n\n\n" >> $boardFileName

printf "dmidecode\n" >> $boardFileName
dmidecode >> $boardFileName

### $lspciFileName Section

printf "lspci\n" >> $lspciFileName
lspci >> $lspciFileName

printf "\n\n\n" >> $infoFileName

printf "lspci -vv\n" >> $lspciFileName
lspci -vv >> $lspciFileName

printf "\n\n\n" >> $lspciFileName

### $audioFileName Section

printf "aplay -l\n" >> $audioFileName
aplay -l >> $audioFileName

printf "\n\n\n" >> $audioFileName

printf "cat /proc/asound/card*/codec*\n" >> $audioFileName
cat /proc/asound/card*/codec* >> $audioFileName

printf "\n\n\n" >> $audioFileName

printf "lspci -v | grep -A7 -i "audio"\n" >> $audioFileName
lspci -v | grep -A7 -i "audio" >> $audioFileName

printf "\n\n\n" >> $audioFileName

printf "pacmd list-sink-inputs\n" >> $audioFileName
pacmd list-sink-inputs >> $audioFileName

printf "\n\n\n" >> $audioFileName

printf "arecord -l\n" >> $audioFileName
arecord -l >> $audioFileName

printf "\n\n\n" >> $audioFileName

printf "fuser -v /dev/snd/*\n" >> $audioFileName
fuser -v /dev/snd/* >> $audioFileName

### $networkFileName Section

printf "\n\n\n" >> $networkFileName

printf "lspci -nnk | grep -E -A3 -i "Ethernet|Network"" >> $networkFileName
printf "\n"
lspci -nnk | grep -E -A3 -i "Ethernet|Network" >> $networkFileName

printf "\n\n\n" >> $networkFileName

printf "ifconfig\n" >> $networkFileName
ifconfig >> $networkFileName

printf "\n\n\n" >> $networkFileName

printf "ip addr show\n" >> $networkFileName
ip addr show >> $networkFileName

printf "\n\n\n" >> $networkFileName

printf "ip link show\n" >> $networkFileName
ip link show >> $networkFileName

printf "\n\n\n" >> $networkFileName

printf "ip route show\n" >> $networkFileName
ip route show >> $networkFileName

printf "\n\n\n" >> $networkFileName

printf "rfkill list\n" >> $networkFileName
rfkill list >> $networkFileName

printf "\n\n\n" >> $networkFileName

printf "iwconfig\n" >> $networkFileName
iwconfig >> $networkFileName

### $packagesFileName Section

printf "\n\n\n" >> $packagesFileName

# Ubuntu
if [  -n "$(lsb_release -a | grep Ubuntu)" ]; then
    printf "sources.list\n" >> $packagesFileName
    cat /etc/apt/sources.list >> $packagesFileName

    printf "\n\n\n" >> $packagesFileName

    printf "/etc/apt/sources.list.d\n" >> $packagesFileName
    ls /etc/apt/sources.list.d >> $packagesFileName

    printf "\n\n\n" >> $packagesFileName

    printf "/etc/apt/sources.list.d ppa\n" >> $packagesFileName
    cat /etc/apt/sources.list.d/* >> $packagesFileName

    printf "\n\n\n" >> $packagesFileName

    printf "dpkg -l\n" >> $packagesFileName
    dpkg -l >> $packagesFileName

    printf "\n\n\n" >> $packagesFileName

    printf "dpkg -l | grep nvidia\n" >> $packagesFileName
    dpkg -l|grep nvidia >> $packagesFileName

    printf "\n\n\n" >> $packagesFileName

    printf "dpkg -l | grep tuxedo\n" >> $packagesFileName
    dpkg -l|grep tuxedo >> $packagesFileName

fi

# openSUSE
if [  -n "$(lsb_release -a | grep openSUSE)" ]; then

    printf "/etc/zypp/repos.d\n" >> $packagesFileName
    ls -al /etc/zypp/repos.d/ >> $packagesFileName

    printf "\n\n\n" >> $packagesFileName

    printf "rpm -qa\n" >> $packagesFileName
    rpm -qa >> $packagesFileName

    printf "\n\n\n" >> $packagesFileName

    printf "rpm -qa | grep nvidia\n" >> $packagesFileName
    rpm -qa | grep nvidia >> $packagesFileName

    printf "\n\n\n">> $packagesFileName

    printf "rpm -qa | grep tuxedo\n" >> $packagesFileName
    rpm -qa | grep tuxedo >> $packagesFileName
else
    printf "Unsupported Distribution! Skip\n"
fi

### $udevFileName Section

printf "/etc/udev/rules.d/\n" >> $udevFileName
ls /etc/udev/rules.d/ >> $udevFileName

printf "\n\n\n" >> $udevFileName

printf "/etc/udev/rules.d/ files\n" >> $udevFileName
cat /etc/udev/rules.d/* >> $udevFileName



# Rename files
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
