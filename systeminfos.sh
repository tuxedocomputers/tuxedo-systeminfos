#!/bin/sh
serverURI=https://systeminfo.tuxedo.de/systeminfo.php
infoFileName=systeminfos.txt
lspciFileName=lspcioutput.txt
udevFileName=udevoutput.txt
logFileName=logoutput.txt
packagesFileName=packagesoutput.txt
audioFileName=audiooutput.txt
networkFileName=networkoutput.txt
boardFileName=boardoutput.txt
firmwareFileName=firmwareoutput.txt
started=$(date +"%d.%m.%y-%H:%Mh")
ticketnumber=$1

if [ "$(id -u)" -ne 0 ]; then
    printf "\e[31msysteminfos.sh muss mit root Rechten ausgeführt werden! / systeminfos.sh must be executed with root privileges! \e[1m\n"
    printf "\e[37m\e[0m\n"
    exec sudo --preserve-env="XDG_SESSION_TYPE,XDG_CURRENT_DESKTOP" su -c "sh '$(basename $0)' $1"
fi

# Check Internet connection
printf "Überprüfe Internetverbindung... / Checking Internet connection... \n"
wget -q --spider https://www.tuxedocomputers.com
if [ $? -eq 0 ]; then
    printf "\e[32mOnline\e[0m\n"
    printf "\e[37m\e[0m\n"
else
    printf "\e[31mOffline! Um das Skript ausführen zu können ist eine Internetverbindung erforderlich! / Offline! An internet connection is required to run the script! \e[1m\n"
    printf "\e[37m\e[0m\n"
    exit 1
fi


if [ -z $ticketnumber ]; then
    printf "\n"
    printf "Wie lautet Ihre Ticketnummer? Mit [ENTER] bestätigen / What is your ticket number? Confirm with [ENTER] \n"
    printf "Die Ticketnummer beginnt mit 990 / The ticket number starts with 990 \n"
    printf "Bitte beachten Sie, dass wir ohne Ticketnummer, Ihr Anliegen nicht bearbeiten können. / We cannot proceed your inquire without ticket number! \n"
    printf "Um eine Ticketnummer zu erhalten, schreiben Sie uns eine Mail an tux[at]tuxedocomputer.com mit Ihrem Anliegen. / To get an ticket number you can contact us by mail to tux[at]tuxedocomputers.com \n"
    printf "\e[31mWenn sie keine Ticketnummer haben, beenden sie das Skript bitte JETZT mit Strg + C / If you do not have a ticket number, please exit the script NOW with Ctrl + C. \e[1m\n"
    printf "\e[31mDas Skript sammelt keinerlei persönliche Daten und keine Zugangsdaten! / The script does not collect any personal data and no access data! \e[1m\n"
    printf "\e[31mEs werden lediglich Informationen über Ihre Hard- und Softwarekonfiguration gesammelt. / Only information about your hardware and software configuration is collected. \e[1m\n"
    printf "\n"
    printf "Bitte beachten sie dass sie nur für Ubuntu und openSUSE Support von TUXEDO Computers erhalten. / Please note that you only get support for Ubuntu and openSUSE from TUXEDO Computers."
    printf "Eventuell auftauchende Fehlermeldungen können sie ignorieren. / You can ignore any error messages that may appear"
    printf "\e[37m\e[0m\n"
    read -p "Ticket#: " ticketnumber
    if [ -z $ticketnumber ]; then
        printf "\e[31mKeine Tickernummer angegeben. Beende. / No ticker number given. Quitting. \e[1m\n"
        printf "\e[37m\e[0m\n"
        exit 1
    fi
fi

if [ "$(. /etc/os-release; echo $NAME)" = "TUXEDO OS" ]; then
    apt -y install curl zip > /dev/null 2>&1
elif [ "$(. /etc/os-release; echo $NAME)" = "Ubuntu" ]; then
    apt -y install curl zip > /dev/null 2>&1
elif [ "$(. /etc/os-release; echo $NAME)" = "elementary OS" ]; then
    apt -y install curl zip > /dev/null 2>&1
elif [ "$(. /etc/os-release; echo $NAME)" = "KDE neon" ]; then
    apt -y install curl zip > /dev/null 2>&1
elif [ "$(. /etc/os-release; echo $NAME)" = "openSUSE Leap" ]; then
    zypper in -y curl zip > /dev/null 2>&1
elif [ "$(. /etc/os-release; echo $NAME)" = "Manjaro Linux" ]; then
    pacman -Sy --no-confirm curl zip > /dev/null 2>&1
else
    printf "Nicht unterstütze Distribution! Überspringe... / Unsupported Distribution! Skip... \n"
fi


printf "\n"
echo 'Ticketnummer: ' $ticketnumber | tee -a $infoFileName $lspciFileName $udevFileName $logFileName $packagesFileName $audioFileName $networkFileName $boardFileName $firmwareFileName
echo 'systeminfos.sh started at' $started | tee -a $infoFileName $lspciFileName $udevFileName $logFileName $packagesFileName $audioFileName $networkFileName $boardFileName $firmwareFileName
printf "\n\n" | tee -a $infoFileName $lspciFileName $udevFileName $logFileName $packagesFileName $audioFileName $networkFileName $boardFileName $firmwareFileName

### $infoFileName Section

printf 'uname -a\n\n' >> $infoFileName
uname -a >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "lscpu\n\n" >> $infoFileName
lscpu >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "lsb_release -a\n\n" >> $infoFileName
lsb_release -a >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "tuxedo-tomte list\n\n" >> $infoFileName
tuxedo-tomte list >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "lsusb\n\n" >> $infoFileName
lsusb >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "lsblk\n\n" >> $infoFileName
lsblk >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "fstab\n\n" >> $infoFileName
egrep -iv "cifs|nfs" /etc/fstab >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "xinput\n\n" >> $infoFileName
xinput >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "/etc/default/grub\n\n" >> $infoFileName
cat /etc/default/grub >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "free -h\n\n" >> $infoFileName
free -h >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "lsmod\n\n" >> $infoFileName
lsmod >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "dkms status\n\n" >> $infoFileName
dkms status >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "upower -i $(upower -e | grep 'BAT')\n\n" >> $infoFileName
upower -i $(upower -e | grep 'BAT') >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "/sys/power/mem_sleep\n\n" >> $infoFileName
cat /sys/power/mem_sleep >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "glxinfo|grep vendor\n\n" >> $infoFileName
glxinfo|grep vendor >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "prime-select query\n\n" >> $infoFileName
prime-select query >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "Display Info (/sys/kernel/debug/dri/*/i1915_display_info)\n\n" >> $infoFileName
grep -A 100 "^Connector info" /sys/kernel/debug/dri/*/i915_display_info >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "Display Info colormgr\n\n"
colormgr get-devices-by-kind display >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "XDG_SESSION_TYPE\n\n" >> $infoFileName
echo $XDG_SESSION_TYPE >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "Desktop\n\n" >> $infoFileName
echo $XDG_CURRENT_DESKTOP >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "Display-Manager\n\n" >> $infoFileName
cat /etc/systemd/system/display-manager.service >> $infoFileName

printf "\n\n\n" >> $infoFileName

if [ -f /etc/modprobe.d/tuxedo_keyboard.conf ]; then
    printf "tuxedo_keyboard.conf\n\n" >> $infoFileName
    cat /etc/modprobe.d/tuxedo_keyboard.conf >> $infoFileName
    printf "\n\n\n" >> $logFileName

else
    printf "TUXEDO Keyboard scheint nicht installiert zu sein.\n" >> $logFileName
    printf "TUXEDO Keyboard seems not to be installed." >> $logFileName
    printf "\n\n\n" >> $logFileName

fi

printf "\n\n\n" >> $infoFileName

printf "xrandr\n\n" >> $infoFileName
xrandr >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "disk usage (df -h)\n\n" >> $infoFileName
df -h >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "lshw\n\n" >> $infoFileName
lshw >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "journalctl -k --grep=tpm\n\n" >> $infoFileName
journalctl -k --grep=tpm >> $infoFileName

### $logFileName Section

if [ -f /var/log/tuxedo-install.log ]; then
    head -n 1 /var/log/tuxedo-install.log >> $logFileName
    cat /var/log/tuxedo-install.log | grep "Starting FAI execution" >> $logFileName
    printf "\n\n\n" >> $logFileName

else
    printf "WebFAI Install-Log konnte nicht gefunden werden.\n" >> $logFileName
    printf "Moeglicherweise handelt es sich um keine WebFAI Installation.\n\n" >> $logFileName
    printf "WebFAI Install-log could not be found.\n" >> $logFileName
    printf "Maybe it's not a WebFAI installation." >> $logFileName
    printf "\n\n\n" >> $logFileName

fi

if [ -f /var/log/tomte/tomte.log ]; then
    printf "cat /var/log/tomte/tomte.log\n\n" >> $logFileName
    cat /var/log/tomte/tomte.log >> $logFileName
    printf "\n\n\n" >> $logFileName

else
    printf "Tomte Log konnte nicht gefunden werden.\n" >> $logFileName
    printf "Moeglicherweise ist Tomte nicht installiert.\n\n" >> $logFileName
    printf "Tomte Log could not be found.\n" >> $logFileName
    printf "Maybe Tomte is not installed." >> $logFileName
    printf "\n\n\n" >> $logFileName

fi

printf "/var/log/syslog\n\n" >> $logFileName
tail --lines=1000 /var/log/syslog >> $logFileName

printf "\n\n\n" >> $logFileName

printf "journalctl --system -e\n\n" >> $logFileName
journalctl --system -e >> $logFileName

printf "\n\n\n" >> $logFileName

printf "/var/log/boot.log\n\n" >> $logFileName
tail --lines=1000 /var/log/boot.log >> $logFileName

printf "\n\n\n" >> $logFileName

printf "dmesg\n\n" >> $logFileName
dmesg >> $logFileName

printf "systemctl status systemd-modules-load.service\n\n" >> $logFileName
systemctl status systemd-modules-load.service >> $logFileName

### $boardFileName Section

printf "/sys/class/dmi/id/board_vendor\n\n" >> $boardFileName
cat /sys/class/dmi/id/board_vendor >> $boardFileName

printf "\n\n\n" >> $boardFileName

printf "/sys/class/dmi/id/chassis_vendor\n\n" >> $boardFileName
cat /sys/class/dmi/id/chassis_vendor >> $boardFileName

printf "\n\n\n" >> $boardFileName

printf "/sys/class/dmi/id/sys_vendor\n\n" >> $boardFileName
cat /sys/class/dmi/id/sys_vendor >> $boardFileName

printf "\n\n\n" >> $boardFileName

printf "/sys/class/dmi/id/board_name\n\n" >> $boardFileName
cat /sys/class/dmi/id/board_name >> $boardFileName

printf "\n\n\n" >> $boardFileName

printf "/sys/class/dmi/id/product_name\n\n" >> $boardFileName
cat /sys/class/dmi/id/product_name >> $boardFileName

printf "\n\n\n" >> $boardFileName

printf "/sys/class/dmi/id/product_sku\n\n" >> $boardFileName
cat /sys/class/dmi/id/product_sku >> $boardFileName

printf "\n\n\n" >> $boardFileName

printf "/sys/class/dmi/id/board_serial\n\n" >> $boardFileName
cat /sys/class/dmi/id/board_serial >> $boardFileName

printf "\n\n\n" >> $boardFileName

printf "/sys/class/dmi/id/bios_version\n\n" >> $boardFileName
cat /sys/class/dmi/id/bios_version >> $boardFileName

printf "\n\n\n" >> $boardFileName

if [ -f /sys/class/dmi/id/ec_firmware_release ]; then
    printf "/sys/class/dmi/id/ec_firmware_release\n\n" >> $boardFileName
    cat /sys/class/dmi/id/ec_firmware_release >> $boardFileName

    printf "\n\n\n" >> $boardFileName
else
    printf "EC-Version kann nicht ausgelesen werden! Überspringe...\n" >> $boardFileName
    printf "EC-Version can't be read out! Skip..." >> $boardFileName
    printf "\n\n\n" >> $boardFileName

fi

printf "configured memory speed\n\n" >> $boardFileName
dmidecode | grep -i "configured memory speed" >> $boardFileName

printf "\n\n\n" >> $boardFileName

printf "dmidecode\n\n" >> $boardFileName
dmidecode >> $boardFileName

### $lspciFileName Section

printf "lspci -vvnn\n\n" >> $lspciFileName
lspci -vvnn >> $lspciFileName

### $audioFileName Section

printf "aplay -l\n\n" >> $audioFileName
aplay -l >> $audioFileName

printf "\n\n\n" >> $audioFileName

printf "echo 1 > /sys/module/snd_hda_codec/parameters/dump_coef\n" >> $audioFileName
printf "cat /proc/asound/card*/codec*\n\n" >> $audioFileName
echo 1 > /sys/module/snd_hda_codec/parameters/dump_coef
cat /proc/asound/card*/codec* >> $audioFileName

printf "\n\n\n" >> $audioFileName

printf "lspci -v | grep -A7 -i "audio"\n\n" >> $audioFileName
lspci -v | grep -A7 -i "audio" >> $audioFileName

printf "\n\n\n" >> $audioFileName

printf "pacmd list-sink-inputs\n\n" >> $audioFileName
pacmd list-sink-inputs >> $audioFileName

printf "\n\n\n" >> $audioFileName

printf "pa-info\n\n" >> $audioFileName
pa-info >> $audioFileName

printf "\n\n\n" >> $audioFileName

printf "arecord -l\n\n" >> $audioFileName
arecord -l >> $audioFileName

printf "\n\n\n" >> $audioFileName

printf "fuser -v /dev/snd/*\n\n" >> $audioFileName
fuser -v /dev/snd/* >> $audioFileName

### $networkFileName Section

printf "\n\n\n" >> $networkFileName

echo 'lspci -nnk | grep -E -A3 -i "Ethernet|Network"' >> $networkFileName
printf "\n\n" >> $networkFileName
lspci -nnk | grep -E -A3 -i "Ethernet|Network" >> $networkFileName

printf "\n\n\n" >> $networkFileName

printf "ip addr show\n\n" >> $networkFileName
ip addr show >> $networkFileName

printf "\n\n\n" >> $networkFileName

printf "ip link show\n\n" >> $networkFileName
ip link show >> $networkFileName

printf "\n\n\n" >> $networkFileName

printf "ip route show\n\n" >> $networkFileName
ip route show >> $networkFileName

printf "\n\n\n" >> $networkFileName

printf "rfkill list\n\n" >> $networkFileName
rfkill list >> $networkFileName

printf "\n\n\n" >> $networkFileName

printf "iwconfig\n\n" >> $networkFileName
iwconfig >> $networkFileName

### $packagesFileName Section

printf "\n\n\n" >> $packagesFileName

# TUXEDO_OS
if [ "$(. /etc/os-release; echo $NAME)" = "TUXEDO OS" ]; then

    printf "sources.list\n\n" >> $packagesFileName
    cat /etc/apt/sources.list >> $packagesFileName

    printf "\n\n\n" >> $packagesFileName

    printf "/etc/apt/sources.list.d\n\n" >> $packagesFileName
    ls /etc/apt/sources.list.d >> $packagesFileName

    printf "\n\n\n" >> $packagesFileName

    printf "/etc/apt/sources.list.d ppa\n\n" >> $packagesFileName
    cat /etc/apt/sources.list.d/* >> $packagesFileName

    printf "\n\n\n" >> $packagesFileName

    printf "dpkg -l\n\n" >> $packagesFileName
    dpkg -l >> $packagesFileName

    printf "\n\n\n" >> $packagesFileName

    printf "dpkg -l | grep tuxedo\n\n" >> $packagesFileName
    dpkg -l|grep tuxedo >> $packagesFileName

    printf "\n\n\n" >> $packagesFileName

    printf "dpkg -l | grep nvidia\n\n" >> $packagesFileName
    dpkg -l|grep nvidia >> $packagesFileName

    printf "\n\n\n" >> $packagesFileName

    printf "/var/log/apt/history.log\n\n" >> $packagesFileName
    cat /var/log/apt/history.log >> $packagesFileName

# Ubuntu
elif [ "$(. /etc/os-release; echo $NAME)" = "Ubuntu" ]; then

    printf "sources.list\n\n" >> $packagesFileName
    cat /etc/apt/sources.list >> $packagesFileName

    printf "\n\n\n" >> $packagesFileName

    printf "/etc/apt/sources.list.d\n\n" >> $packagesFileName
    ls /etc/apt/sources.list.d >> $packagesFileName

    printf "\n\n\n" >> $packagesFileName

    printf "/etc/apt/sources.list.d ppa\n\n" >> $packagesFileName
    cat /etc/apt/sources.list.d/* >> $packagesFileName

    printf "\n\n\n" >> $packagesFileName

    printf "dpkg -l\n\n" >> $packagesFileName
    dpkg -l >> $packagesFileName

    printf "\n\n\n" >> $packagesFileName

    printf "dpkg -l | grep tuxedo\n\n" >> $packagesFileName
    dpkg -l|grep tuxedo >> $packagesFileName

    printf "\n\n\n" >> $packagesFileName

    printf "dpkg -l | grep nvidia\n\n" >> $packagesFileName
    dpkg -l|grep nvidia >> $packagesFileName

    printf "\n\n\n" >> $packagesFileName

    printf "/var/log/apt/history.log\n\n" >> $packagesFileName
    cat /var/log/apt/history.log >> $packagesFileName

# elementary OS
elif [ "$(. /etc/os-release; echo $NAME)" = "elementary OS" ]; then

    printf "sources.list\n\n" >> $packagesFileName
    cat /etc/apt/sources.list >> $packagesFileName

    printf "\n\n\n" >> $packagesFileName

    printf "/etc/apt/sources.list.d\n\n" >> $packagesFileName
    ls /etc/apt/sources.list.d >> $packagesFileName

    printf "\n\n\n" >> $packagesFileName

    printf "/etc/apt/sources.list.d ppa\n\n" >> $packagesFileName
    cat /etc/apt/sources.list.d/* >> $packagesFileName

    printf "\n\n\n" >> $packagesFileName

    printf "dpkg -l\n\n" >> $packagesFileName
    dpkg -l >> $packagesFileName

    printf "\n\n\n" >> $packagesFileName

    printf "dpkg -l | grep tuxedo\n\n" >> $packagesFileName
    dpkg -l|grep tuxedo >> $packagesFileName

    printf "\n\n\n" >> $packagesFileName

    printf "dpkg -l | grep nvidia\n\n" >> $packagesFileName
    dpkg -l|grep nvidia >> $packagesFileName

    printf "\n\n\n" >> $packagesFileName

    printf "/var/log/apt/history.log\n\n" >> $packagesFileName
    cat /var/log/apt/history.log >> $packagesFileName

# KDE neon
elif [ "$(. /etc/os-release; echo $NAME)" = "KDE neon" ]; then

    printf "sources.list\n\n" >> $packagesFileName
    cat /etc/apt/sources.list >> $packagesFileName

    printf "\n\n\n" >> $packagesFileName

    printf "/etc/apt/sources.list.d\n\n" >> $packagesFileName
    ls /etc/apt/sources.list.d >> $packagesFileName

    printf "\n\n\n" >> $packagesFileName

    printf "/etc/apt/sources.list.d ppa\n\n" >> $packagesFileName
    cat /etc/apt/sources.list.d/* >> $packagesFileName

    printf "\n\n\n" >> $packagesFileName

    printf "dpkg -l\n\n" >> $packagesFileName
    dpkg -l >> $packagesFileName

    printf "\n\n\n" >> $packagesFileName

    printf "dpkg -l | grep tuxedo\n\n" >> $packagesFileName
    dpkg -l|grep tuxedo >> $packagesFileName

    printf "\n\n\n" >> $packagesFileName

    printf "dpkg -l | grep nvidia\n\n" >> $packagesFileName
    dpkg -l|grep nvidia >> $packagesFileName

    printf "\n\n\n" >> $packagesFileName

    printf "/var/log/apt/history.log\n\n" >> $packagesFileName
    cat /var/log/apt/history.log >> $packagesFileName

# openSUSE
elif [ "$(. /etc/os-release; echo $NAME)" = "openSUSE Leap" ]; then

    printf "/etc/zypp/repos.d\n\n" >> $packagesFileName
    ls -al /etc/zypp/repos.d/ >> $packagesFileName

    printf "\n\n\n" >> $packagesFileName

    printf "rpm -qa\n\n" >> $packagesFileName
    rpm -qa >> $packagesFileName

    printf "\n\n\n" >> $packagesFileName

    printf "rpm -qa | grep tuxedo\n\n" >> $packagesFileName
    rpm -qa | grep tuxedo >> $packagesFileName

    printf "\n\n\n" >> $packagesFileName

    printf "rpm -qa | grep nvidia\n\n" >> $packagesFileName
    rpm -qa | grep nvidia >> $packagesFileName

    printf "\n\n\n" >> $packagesFileName

    printf "/var/log/zypp/history\n\n" >> $packagesFileName
    cat /var/log/zypp/history >> $packagesFileName

# Manjaro
elif [ "$(. /etc/os-release; echo $NAME)" = "Manjaro Linux" ]; then

    printf "cat /etc/pacman.conf" >> $packagesFileName
    cat /etc/pacman.conf >> $packagesFileName

    printf "\n\n\n" >> $packagesFileName

    printf "pacman -Qqe" >> $packagesFileName
    pacman -Qqe >> $packagesFileName

    printf "pacman -Qqe | grep tuxedo" >> $packagesFileName
    pacman -Qqe | grep tuxedo >> $packagesFileName

    printf "\n\n\n" >> $packagesFileName
    
    printf "pacman Repo's" >> $packagesFileName
    cat /etc/pacman.conf | grep -E 'core|extra|community|multilib' >> $packagesFileName

    printf "\n\n\n" >> $packagesFileName

    cat /var/log/pacman.log >> $packagesFileName
    printf "\n\n\n" >> $packagesFileName

else
    printf "Nicht unterstütze Distribution! Überspringe...\n"
    printf "Unsupported Distribution! Skip... \n\n\n"
fi

### $udevFileName Section

printf "/etc/udev/rules.d/\n\n" >> $udevFileName
ls /etc/udev/rules.d/ >> $udevFileName

printf "\n\n\n" >> $udevFileName

printf "/etc/udev/rules.d/ files\n\n" >> $udevFileName
cat /etc/udev/rules.d/* >> $udevFileName

printf "/lib/udev/rules.d/\n\n" >> $udevFileName
ls /lib/udev/rules.d/ >> $udevFileName

printf "\n\n\n" >> $udevFileName

printf "/lib/udev/rules.d/ files\n\n" >> $udevFileName
cat /lib/udev/rules.d/* >> $udevFileName

# $firmwareFileName Section

printf "ls -l /lib/firmware\n\n" >> $firmwareFileName
ls -l /lib/firmware >> $firmwareFileName

printf "\n\n\n" >> $firmwareFileName

printf "dmesg|grep firmware\n\n" >> $firmwareFileName
dmesg|grep firmware >> $firmwareFileName

# Rename files
mv $infoFileName systeminfos-$ticketnumber.txt
mv $lspciFileName lspci-$ticketnumber.txt
mv $udevFileName udev-$ticketnumber.txt
mv $logFileName log-$ticketnumber.txt
mv $packagesFileName packages-$ticketnumber.txt
mv $audioFileName audio-$ticketnumber.txt
mv $networkFileName network-$ticketnumber.txt
mv $boardFileName boardinfo-$ticketnumber.txt
mv $firmwareFileName firmware-$ticketnumber.txt

zip -9 systeminfos-$ticketnumber.zip *-$ticketnumber.txt

# Re-Check Internet connection before sending
printf "\n"
printf "Überprüfe Internetverbindung... / Checking Internet connection... \n"
wget -q --spider https://www.tuxedocomputers.com
if [ $? -eq 0 ]; then
    printf "\e[32mOnline\e[0m\n"
    printf "\e[37m\e[0m\n"
else
    printf "\e[31mOffline! Um die Ergebnisse übermitteln zu können ist eine Internetverbindung erforderlich! / Offline! An Internet connection is required to transmit the results! \e[1m\n"
    printf "\e[37m\e[0m\n"
    rm systeminfos-$ticketnumber.zip *-$ticketnumber.txt
    exit 1
fi

curl -k -F "file=@systeminfos-$ticketnumber.zip" $serverURI?ticketnumber=$ticketnumber

rm systeminfos-$ticketnumber.zip *-$ticketnumber.txt

printf "\n"
printf "\e[32mSysteminfos erfolgreich übermittelt. Beende... / Systeminformations successfully transferred. Exit... \e[0m\n"
printf "\e[37m\e[0m\n"
exit 0;
