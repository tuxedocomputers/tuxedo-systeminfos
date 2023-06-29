#!/bin/sh
LC_ALL=C
LANG=C
LANGUAGE=C
serverURI=https://systeminfo.tuxedo.de/systeminfo.php
infoFileName=systeminfos.txt
lspciFileName=lspcioutput.txt
udevFileName=udevoutput.txt
logFileName=logoutput.txt
normalpackagesFileName=normalpackagesoutput.txt
flatpakpackagesFileName=flatpakpackagesoutput.txt
snappackagesFileName=snappakpackagesoutput.txt
audioFileName=audiooutput.txt
networkFileName=networkoutput.txt
boardFileName=boardoutput.txt
firmwareFileName=firmwareoutput.txt
tccFileName=tccoutput.txt
modprobeFileName=modprobeoutput.txt
securebootFileName=securebootoutput.txt
tomteFileName=tomteoutput.txt
displayFileName=displayoutput.txt
failogFilename=failogoutput.txt
started=$(date +"%d.%m.%y-%H:%Mh")
ticketnumber=$1

if [ $SYSINFOS_DEBUG -eq 1 ]; then
    printf "Running in debug mode\n"
else
    SYSINFOS_DEBUG=0
fi

if [ "$(id -u)" -ne 0 ]; then
    printf "\e[31msysteminfos.sh muss mit root Rechten ausgefuehrt werden! / systeminfos.sh must be executed with root privileges! \e[1m\n"
    printf "\e[37m\e[0m\n"
    exec sudo --preserve-env="XDG_SESSION_TYPE,XDG_CURRENT_DESKTOP" su -c "sh '$(basename $0)' $1"
fi

# NOTE: SYSINFOS_DEBUG is only for internal testing purposes.
if [ $SYSINFOS_DEBUG -eq 1 ]; then
    printf "Running in debug mode\n"
else
    # Check Internet connection
    printf "Ueberpruefe Internetverbindung... / Checking Internet connection... \n"
    wget -q --spider https://www.tuxedocomputers.com
    if [ $? -eq 0 ]; then
        printf "\e[32mOnline\e[0m\n"
        printf "\e[37m\e[0m\n"
    else
        printf "\e[31mOffline! Um das Skript ausfuehren zu koennen ist eine Internetverbindung erforderlich! / Offline! An internet connection is required to run the script! \e[1m\n"
        printf "\e[37m\e[0m\n"
        exit 1
    fi

    # clear terminal window before printing messages
    clear

    if [ "$(. /etc/default/locale; echo $LANG)" = "de_DE.UTF-8" ]; then
        printf "Das Skript sammelt keinerlei persönliche Daten und keine Zugangsdaten! \n"
        printf "Es werden lediglich Informationen über Ihre Hard- und Softwarekonfiguration gesammelt. \n"
        printf "Bitte beachten sie dass sie nur für TUXEDO OS, Ubuntu und openSUSE Support von TUXEDO Computers erhalten. \n"
        printf "Eventuell auftauchende Fehlermeldungen können sie ignorieren. \n"
    else
        printf "The script does not collect any personal data and no access data! \n"
        printf "Only information about your hardware and software configuration is collected. \n"
        printf "Please note that you will only receive support for TUXEDO OS, Ubuntu and openSUSE from TUXEDO Computers. \n"
        printf "You can ignore any error messages that may appear. \n"
    fi

    # 5 seconds before next textbox. Clear screen again before next textbox appears
    sleep 5
    clear

    if [ "$(. /etc/default/locale; echo $LANG)" = "de_DE.UTF-8" ]; then
        printf "Wie lautet Ihre Ticketnummer? Mit [ENTER] bestätigen \n"
        printf "Die Ticketnummer beginnt mit 99 und ist neun Stellen lang \n"
        printf "Eingesendete Systeminformationen ohne gültige Ticketnummer können nicht bearbeitet werden und werden unbearbeitet geschlossen \n"
        printf "Um eine Ticketnummer zu erhalten, schreiben Sie uns eine E-Mail an tux[at]tuxedocomputer.com mit Ihrem Anliegen. \n"
    else
        printf "What is your ticket number? Confirm with [ENTER] \n"
        printf "The ticket number starts with 99 and is nine digits long \n"
        printf "Submitted system information without a valid ticket number can't be processed and will be closed unprocessed \n"
        printf "To get an ticket number you can contact us by e-mail to tux[at]tuxedocomputers.com \n"
    fi

    if [ -z $ticketnumber ]; then
        read -p "Ticket#: " ticketnumber
        if [ -z $ticketnumber ]; then
            printf "\e[31mKeine Tickernummer angegeben. Beende. / No ticket number given. Quitting. \e[1m\n"
            printf "\e[37m\e[0m\n"
            exit 1
        fi
    fi
fi

if [ "$(. /etc/os-release; echo $NAME)" = "TUXEDO OS" ]; then
    apt-get update && apt-get -y install curl zip nvme-cli edid-decode efibootmgr > /dev/null 2>&1
    printf "Installiere benoetigte Abhaengigkeiten. Bitte warten... / Install required dependencies. Please wait... \n"
elif [ "$(. /etc/os-release; echo $NAME)" = "Ubuntu" ]; then
    apt-get update && apt-get -y install curl zip nvme-cli edid-decode efibootmgr > /dev/null 2>&1
    printf "Installiere benoetigte Abhaengigkeiten. Bitte warten... / Install required dependencies. Please wait... \n"
elif [ "$(. /etc/os-release; echo $NAME)" = "elementary OS" ]; then
    apt-get update && apt-get -y install curl zip nvme-cli edid-decode efibootmgr > /dev/null 2>&1
    printf "Installiere benoetigte Abhaengigkeiten. Bitte warten... / Install required dependencies. Please wait... \n"
elif [ "$(. /etc/os-release; echo $NAME)" = "KDE neon" ]; then
    apt-get update && apt-get -y install curl zip nvme-cli edid-decode efibootmgr > /dev/null 2>&1
    printf "Installiere benoetigte Abhaengigkeiten. Bitte warten... / Install required dependencies. Please wait... \n"
elif [ "$(. /etc/os-release; echo $NAME)" = "openSUSE Leap" ]; then
    zypper in -y curl zip nvme-cli edid-decode efibootmgr > /dev/null 2>&1
    printf "Installiere benoetigte Abhaengigkeiten. Bitte warten... / Install required dependencies. Please wait... \n"
elif [ "$(. /etc/os-release; echo $NAME)" = "Fedora Linux" ]; then
    dnf in -y curl zip nvme-cli edid-decode efibootmgr > /dev/null 2>&1
    printf "Installiere benoetigte Abhaengigkeiten. Bitte warten... / Install required dependencies. Please wait... \n"
elif [ "$(. /etc/os-release; echo $NAME)" = "Manjaro Linux" ]; then
    pacman -Sy --noconfirm curl zip nvme-cli edid-decode efibootmgr > /dev/null 2>&1
    printf "Installiere benoetigte Abhaengigkeiten. Bitte warten... / Install required dependencies. Please wait... \n"
else
    printf "Nicht unterstuetze Distribution! Ueberspringe... / Unsupported Distribution! Skipping... \n"
fi


printf "\n"
if [ $SYSINFOS_DEBUG -eq 1 ]; then
    printf "Running in debug mode\n"
else
    echo 'Ticketnummer: ' $ticketnumber | tee -a $infoFileName $lspciFileName $udevFileName $logFileName $normalpackagesFileName $audioFileName $networkFileName $boardFileName $firmwareFileName $tccFileName $modprobeFileName $securebootFileName $tomteFileName $displayFileName $failogFilename $flatpakpackagesFileName $snappackagesFileName > /dev/null 2>&1
fi
echo 'systeminfos.sh started at' $started | tee -a $infoFileName $lspciFileName $udevFileName $logFileName $normalpackagesFileName $audioFileName $networkFileName $boardFileName $firmwareFileName $tccFileName $modprobeFileName $securebootFileName $tomteFileName $displayFileName $failogFilename $flatpakpackagesFileName $snappackagesFileName > /dev/null 2>&1
printf "\n\n" | tee -a $infoFileName $lspciFileName $udevFileName $logFileName $normalpackagesFileName $audioFileName $networkFileName $boardFileName $firmwareFileName $tccFileName $modprobeFileName $securebootFileName $tomteFileName $displayFileName $failogFilename $flatpakpackagesFileName $snappackagesFileName > /dev/null 2>&1

### $infoFileName Section

printf "/etc/machine-id\n\n" >> $infoFileName
cat /etc/machine-id >> $infoFileName

printf "/var/lib/dbus/machine-id\n\n" >> $infoFileName
cat /var/lib/dbus/machine-id >> $infoFileName

printf "uname -a\n\n" >> $infoFileName
uname -a >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "lsb_release -a\n\n" >> $infoFileName
lsb_release -a >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "lscpu\n\n" >> $infoFileName
lscpu >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "lscpu -e\n\n" >> $infoFileName
lscpu -e >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "free -h\n\n" >> $infoFileName
free -h >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "/sys/power/mem_sleep\n\n" >> $infoFileName
cat /sys/power/mem_sleep >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "lsusb\n\n" >> $infoFileName
lsusb >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "lsblk\n\n" >> $infoFileName
lsblk -d -o NAME,SIZE,TYPE,TRAN >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "fstab\n\n" >> $infoFileName
egrep -iv "cifs|nfs|davfs|http" /etc/fstab >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "disk usage (df -h)\n\n" >> $infoFileName
df -h >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "xinput\n\n" >> $infoFileName
xinput >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "/etc/default/grub\n\n" >> $infoFileName
cat /etc/default/grub >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "lsmod\n\n" >> $infoFileName
lsmod >> $infoFileName

printf "\n\n\n" >> $infoFileName

if [ -f /etc/modprobe.d/tuxedo_keyboard.conf ]; then
    printf "tuxedo_keyboard.conf\n\n" >> $infoFileName
    cat /etc/modprobe.d/tuxedo_keyboard.conf >> $infoFileName
    printf "\n\n\n" >> $infoFileName

else
    printf "TUXEDO Keyboard scheint nicht installiert zu sein" >> $infoFileName
    printf "\n\n\n" >> $infoFileName

fi

printf "dkms status\n\n" >> $infoFileName
dkms status >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "upower -i $(upower -e | grep 'BAT')\n\n" >> $infoFileName
upower -i $(upower -e | grep 'BAT') >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "prime-select query\n\n" >> $infoFileName
prime-select query >> $infoFileName

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

printf "xrandr\n\n" >> $infoFileName
xrandr >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "lshw\n\n" >> $infoFileName
lshw >> $infoFileName

printf "\n\n\n" >> $infoFileName

printf "journalctl -k --grep=tpm\n\n" >> $infoFileName
journalctl -k --grep=tpm >> $infoFileName

printf "\n\n\n" >> $infoFileName

if [ -d /sys/class/nvme ]; then
    printf "nvme list\n\n" >> $infoFileName
    nvme list >> $infoFileName
fi

if [ -d /sys/firmware/efi ]; then
   printf "efibootmgr\n\n" >> $infoFileName
   efibootmgr -v >> $infoFileName
   printf "\n\n\n" >> $infoFileName
else
   printf "Es wird Legacy genutzt" >> $infoFileName
   printf "\n\n\n" >> $infoFileName
fi

### $logFileName Section

if [ -f /var/log/tuxedo-install.log ]; then
    cat /var/log/tuxedo-install.log >> $failogFilename

else
    printf "WebFAI Install-Log konnte nicht gefunden werden.\n" >> $failogFilename
    printf "Moeglicherweise handelt es sich um keine WebFAI Installation.\n" >> $failogFilename

fi

if [ -f /var/log/tomte/tomte.log ]; then
    printf "cat /var/log/tomte/tomte.log\n\n" >> $logFileName
    cat /var/log/tomte/tomte.log >> $logFileName
    printf "\n\n\n" >> $logFileName

else
    printf "Tomte Log konnte nicht gefunden werden.\n" >> $logFileName
    printf "Moeglicherweise ist Tomte nicht installiert.\n" >> $logFileName
    printf "\n\n\n" >> $logFileName

fi

printf "/var/log/syslog\n\n" >> $logFileName
tail --lines=1000 /var/log/syslog >> $logFileName

printf "\n\n\n\n\n" >> $logFileName

printf "journalctl --system -e\n\n" >> $logFileName
journalctl --system -e >> $logFileName

printf "\n\n\n\n\n" >> $logFileName

printf "/var/log/boot.log\n\n" >> $logFileName
tail --lines=1000 /var/log/boot.log >> $logFileName

printf "\n\n\n\n\n" >> $logFileName

printf "/var/log/Xorg.0.log\n\n" >> $logFileName
if [ $(wc --lines /var/log/Xorg.0.log | cut --delimiter=" " --fields=1) -le 2500 ]; then
    cat /var/log/Xorg.0.log >> $logFileName
else
    head --lines=1250 /var/log/Xorg.0.log >> $logFileName
    echo [...] >> $logFileName
    tail --lines=1250 /var/log/Xorg.0.log >> $logFileName
fi

printf "\n\n\n\n\n" >> $logFileName

printf "dmesg\n\n" >> $logFileName
dmesg >> $logFileName

printf "\n\n\n\n\n" >> $logFileName

printf "systemctl status systemd-modules-load.service\n\n" >> $logFileName
systemctl status systemd-modules-load.service >> $logFileName

### $boardFileName Section

printf "BIOS date and time\n\n" >> $boardFileName
cat /sys/class/rtc/rtc0/date >> $boardFileName
printf "\n"  >> $boardFileName
cat /sys/class/rtc/rtc0/time >> $boardFileName

printf "\n\n\n" >> $infoFileName

printf "find /sys/class/dmi/id/ -maxdepth 1 -type f -print -exec cat {}  \; -exec echo \;\n\n" >> $boardFileName
find /sys/class/dmi/id/ -maxdepth 1 -type f -print -exec cat {}  \; -exec echo \; >> $boardFileName

printf "\n\n\n" >> $boardFileName

printf "dmidecode -t memory\n\n" >> $boardFileName
dmidecode -t memory >> $boardFileName

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

printf "ip route show\n\n" >> $networkFileName
ip route show >> $networkFileName

printf "\n\n\n" >> $networkFileName

printf "rfkill list\n\n" >> $networkFileName
rfkill list >> $networkFileName

printf "\n\n\n" >> $networkFileName

printf "iwconfig\n\n" >> $networkFileName
iwconfig >> $networkFileName

printf "\n\n\n" >> $networkFileName

printf "mmcli\n\n" >> $networkFileName
mmcli -m 0 | grep -v -e "imei:*" -e "equipment id:*" >> $networkFileName

### $normalpackagesFileName Section

printf "\n\n\n" >> $normalpackagesFileName

# TUXEDO_OS
if [ "$(. /etc/os-release; echo $NAME)" = "TUXEDO OS" ]; then

    printf "sources.list\n\n" >> $normalpackagesFileName
    cat /etc/apt/sources.list >> $normalpackagesFileName

    printf "\n\n\n" >> $normalpackagesFileName

    printf "/etc/apt/sources.list.d\n\n" >> $normalpackagesFileName
    ls /etc/apt/sources.list.d >> $normalpackagesFileName

    printf "\n\n\n" >> $normalpackagesFileName

    printf "/etc/apt/sources.list.d ppa\n\n" >> $normalpackagesFileName
    cat /etc/apt/sources.list.d/* >> $normalpackagesFileName

    printf "\n\n\n" >> $normalpackagesFileName

    printf "dpkg -l\n\n" >> $normalpackagesFileName
    dpkg -l >> $normalpackagesFileName

    printf "\n\n\n" >> $normalpackagesFileName

    printf "dpkg -l | grep tuxedo\n\n" >> $normalpackagesFileName
    dpkg -l|grep tuxedo >> $normalpackagesFileName

    printf "\n\n\n" >> $normalpackagesFileName

    printf "dpkg -l | grep nvidia\n\n" >> $normalpackagesFileName
    dpkg -l|grep nvidia >> $normalpackagesFileName

    printf "\n\n\n" >> $normalpackagesFileName

    printf "/var/log/apt/history.log\n\n" >> $normalpackagesFileName
    cat /var/log/apt/history.log >> $normalpackagesFileName

# Ubuntu
elif [ "$(. /etc/os-release; echo $NAME)" = "Ubuntu" ]; then

    printf "sources.list\n\n" >> $normalpackagesFileName
    cat /etc/apt/sources.list >> $normalpackagesFileName

    printf "\n\n\n" >> $normalpackagesFileName

    printf "/etc/apt/sources.list.d\n\n" >> $normalpackagesFileName
    ls /etc/apt/sources.list.d >> $normalpackagesFileName

    printf "\n\n\n" >> $normalpackagesFileName

    printf "/etc/apt/sources.list.d ppa\n\n" >> $normalpackagesFileName
    cat /etc/apt/sources.list.d/* >> $normalpackagesFileName

    printf "\n\n\n" >> $normalpackagesFileName

    printf "dpkg -l\n\n" >> $normalpackagesFileName
    dpkg -l >> $normalpackagesFileName

    printf "\n\n\n" >> $normalpackagesFileName

    printf "dpkg -l | grep tuxedo\n\n" >> $normalpackagesFileName
    dpkg -l|grep tuxedo >> $normalpackagesFileName

    printf "\n\n\n" >> $normalpackagesFileName

    printf "dpkg -l | grep nvidia\n\n" >> $normalpackagesFileName
    dpkg -l|grep nvidia >> $normalpackagesFileName

    printf "\n\n\n" >> $normalpackagesFileName

    printf "/var/log/apt/history.log\n\n" >> $normalpackagesFileName
    cat /var/log/apt/history.log >> $normalpackagesFileName

# elementary OS
elif [ "$(. /etc/os-release; echo $NAME)" = "elementary OS" ]; then

    printf "sources.list\n\n" >> $normalpackagesFileName
    cat /etc/apt/sources.list >> $normalpackagesFileName

    printf "\n\n\n" >> $normalpackagesFileName

    printf "/etc/apt/sources.list.d\n\n" >> $normalpackagesFileName
    ls /etc/apt/sources.list.d >> $normalpackagesFileName

    printf "\n\n\n" >> $normalpackagesFileName

    printf "/etc/apt/sources.list.d ppa\n\n" >> $normalpackagesFileName
    cat /etc/apt/sources.list.d/* >> $normalpackagesFileName

    printf "\n\n\n" >> $normalpackagesFileName

    printf "dpkg -l\n\n" >> $normalpackagesFileName
    dpkg -l >> $normalpackagesFileName

    printf "\n\n\n" >> $normalpackagesFileName

    printf "dpkg -l | grep tuxedo\n\n" >> $normalpackagesFileName
    dpkg -l|grep tuxedo >> $normalpackagesFileName

    printf "\n\n\n" >> $normalpackagesFileName

    printf "dpkg -l | grep nvidia\n\n" >> $normalpackagesFileName
    dpkg -l|grep nvidia >> $normalpackagesFileName

    printf "\n\n\n" >> $normalpackagesFileName

    printf "/var/log/apt/history.log\n\n" >> $normalpackagesFileName
    cat /var/log/apt/history.log >> $normalpackagesFileName

# KDE neon
elif [ "$(. /etc/os-release; echo $NAME)" = "KDE neon" ]; then

    printf "sources.list\n\n" >> $normalpackagesFileName
    cat /etc/apt/sources.list >> $normalpackagesFileName

    printf "\n\n\n" >> $normalpackagesFileName

    printf "/etc/apt/sources.list.d\n\n" >> $normalpackagesFileName
    ls /etc/apt/sources.list.d >> $normalpackagesFileName

    printf "\n\n\n" >> $normalpackagesFileName

    printf "/etc/apt/sources.list.d ppa\n\n" >> $normalpackagesFileName
    cat /etc/apt/sources.list.d/* >> $normalpackagesFileName

    printf "\n\n\n" >> $normalpackagesFileName

    printf "dpkg -l\n\n" >> $normalpackagesFileName
    dpkg -l >> $normalpackagesFileName

    printf "\n\n\n" >> $normalpackagesFileName

    printf "dpkg -l | grep tuxedo\n\n" >> $normalpackagesFileName
    dpkg -l|grep tuxedo >> $normalpackagesFileName

    printf "\n\n\n" >> $normalpackagesFileName

    printf "dpkg -l | grep nvidia\n\n" >> $normalpackagesFileName
    dpkg -l|grep nvidia >> $normalpackagesFileName

    printf "\n\n\n" >> $normalpackagesFileName

    printf "/var/log/apt/history.log\n\n" >> $normalpackagesFileName
    cat /var/log/apt/history.log >> $normalpackagesFileName

# openSUSE
elif [ "$(. /etc/os-release; echo $NAME)" = "openSUSE Leap" ]; then

    printf "/etc/zypp/repos.d\n\n" >> $normalpackagesFileName
    ls -al /etc/zypp/repos.d/ >> $normalpackagesFileName

    printf "\n\n\n" >> $normalpackagesFileName

    printf "zypper sources lists\n\n" >> $normalpackagesFileName
    cat /etc/zypp/repos.d/* >> $normalpackagesFileName

    printf "\n\n\n" >> $normalpackagesFileName

    printf "rpm -qa\n\n" >> $normalpackagesFileName
    rpm -qa >> $normalpackagesFileName

    printf "\n\n\n" >> $normalpackagesFileName

    printf "rpm -qa | grep tuxedo\n\n" >> $normalpackagesFileName
    rpm -qa | grep tuxedo >> $normalpackagesFileName

    printf "\n\n\n" >> $normalpackagesFileName

    printf "rpm -qa | grep nvidia\n\n" >> $normalpackagesFileName
    rpm -qa | grep nvidia >> $normalpackagesFileName

    printf "\n\n\n" >> $normalpackagesFileName

    printf "/var/log/zypp/history\n\n" >> $normalpackagesFileName
    cat /var/log/zypp/history >> $normalpackagesFileName

# Fedora
elif [ "$(. /etc/os-release; echo $NAME)" = "Fedora Linux" ]; then

    printf "/etc/yum.repos.d\n\n" >> $normalpackagesFileName
    ls -al /etc/yum.repos.d/ >> $normalpackagesFileName

    printf "\n\n\n" >> $normalpackagesFileName

    printf "dnf sources lists\n\n" >> $normalpackagesFileName
    cat /etc/yum.repos.d/* >> $normalpackagesFileName

    printf "\n\n\n" >> $normalpackagesFileName

    printf "rpm -qa\n\n" >> $normalpackagesFileName
    rpm -qa >> $normalpackagesFileName

    printf "\n\n\n" >> $normalpackagesFileName

    printf "rpm -qa | grep tuxedo\n\n" >> $normalpackagesFileName
    rpm -qa | grep tuxedo >> $normalpackagesFileName

    printf "\n\n\n" >> $normalpackagesFileName

    printf "rpm -qa | grep nvidia\n\n" >> $normalpackagesFileName
    rpm -qa | grep nvidia >> $normalpackagesFileName

    printf "\n\n\n" >> $normalpackagesFileName

    printf "/var/log/dnf.log\n\n" >> $normalpackagesFileName
    cat /var/log/dnf.log >> $normalpackagesFileName

    printf "/var/log/dnf.librepo.log\n\n" >> $normalpackagesFileName
    cat /var/log/dnf.librepo.log >> $normalpackagesFileName

    printf "/var/log/dnf.rpm.log\n\n" >> $normalpackagesFileName
    cat /var/log/dnf.rpm.log >> $normalpackagesFileName

# Manjaro
elif [ "$(. /etc/os-release; echo $NAME)" = "Manjaro Linux" ]; then

    printf "cat /etc/pacman.conf" >> $normalpackagesFileName
    cat /etc/pacman.conf >> $normalpackagesFileName

    printf "\n\n\n" >> $normalpackagesFileName

    printf "pacman -Qqe" >> $normalpackagesFileName
    pacman -Qqe >> $normalpackagesFileName

    printf "pacman -Qqe | grep tuxedo" >> $normalpackagesFileName
    pacman -Qqe | grep tuxedo >> $normalpackagesFileName

    printf "\n\n\n" >> $normalpackagesFileName

    printf "pacman Repo's" >> $normalpackagesFileName
    cat /etc/pacman.conf | grep -E 'core|extra|community|multilib' >> $normalpackagesFileName

    printf "\n\n\n" >> $normalpackagesFileName

    cat /var/log/pacman.log >> $normalpackagesFileName
    printf "\n\n\n" >> $normalpackagesFileName

else
    printf "Nicht unterstuetze Distribution! Ueberspringe...\n"
    printf "Unsupported Distribution! Skipping... \n\n\n"
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

# $tccFileName Section

printf "cat /etc/tcc/settings\n\n" >> $tccFileName
cat /etc/tcc/settings >> $tccFileName

printf "\n\n\n" >> $tccFileName

printf "systemctl is-active tccd.service\n\n" >> $tccFileName
systemctl is-active tccd.service >> $tccFileName

# $modprobeFileName Section

printf "/etc/modprobe.d/\n\n" >> $modprobeFileName
ls /etc/modprobe.d/ >> $modprobeFileName

printf "\n\n\n" >> $modprobeFileName

printf "/etc/modprobe.d/ files\n\n" >> $modprobeFileName
cat /etc/modprobe.d/* >> $modprobeFileName

# $securebootFileName section

printf "mokutil --sb-state\n\n" >> $securebootFileName
mokutil --sb-state >> $securebootFileName

printf "\n\n\n" >> $securebootFileName

printf "mokutil --pk\n\n" >> $securebootFileName
mokutil --pk >> $securebootFileName

printf "\n\n\n" >> $securebootFileName

printf "mokutil --kek\n\n" >> $securebootFileName
mokutil --kek >> $securebootFileName

printf "\n\n\n" >> $securebootFileName

printf "mokutil --db\n\n" >> $securebootFileName
mokutil --db >> $securebootFileName

printf "\n\n\n" >> $securebootFileName

printf "mokutil --dbx\n\n" >> $securebootFileName
mokutil --dbx >> $securebootFileName

printf "\n\n\n" >> $securebootFileName

printf "mokutil --list-enrolled\n\n" >> $securebootFileName
mokutil --list-enrolled >> $securebootFileName

printf "\n\n\n" >> $securebootFileName

printf "mokutil --list-new\n\n" >> $securebootFileName
mokutil --list-new >> $securebootFileName

printf "\n\n\n" >> $securebootFileName

printf "mokutil --list-delete\n\n" >> $securebootFileName
mokutil --list-delete >> $securebootFileName

printf "\n\n\n" >> $securebootFileName

printf "mokutil --mokx\n\n" >> $securebootFileName
mokutil --mokx >> $securebootFileName

printf "\n\n\n" >> $securebootFileName

# $tomteFileName section

printf "tuxedo-tomte list\n\n" >> $tomteFileName
tuxedo-tomte list >> $tomteFileName

printf "\n\n\n" >> $tomteFileName

if [ -f /etc/tomte/AUTOMATIC ]; then
    printf "Tomte wird in den vorgesehenen Standardeinstellungen verwendet\n" >> $tomteFileName
    printf "\n\n\n" >> $tomteFileName
elif [ -f /etc/tomte/DONT_CONFIGURE ]; then
    printf "Tomte ist so konfiguriert, dass nur die als "notwendig" (prerequisite) markierten Module konfiguriert werden\n" >> $tomteFileName
    printf "\n\n\n" >> $tomteFileName
elif [ -f /etc/tomte/UPDATES_ONLY ]; then
    printf "Tomte ist so konfiguriert, dass nur Aktualisierungen ueber Tomte verarbeitet werden\n" >> $tomteFileName
    printf "\n\n\n" >> $tomteFileName
else
    printf "Tomte wird in den Standardeinstellungen verwendet\n" >> $tomteFileName
    printf "\n\n\n" >> $tomteFileName
fi

# $displayFileName section

printf "glxinfo|grep vendor\n\n" >> $displayFileName
glxinfo|grep vendor >> $displayFileName

printf "\n\n\n" >> $displayFileName

printf "Display Info (/sys/kernel/debug/dri/*/i1915_display_info)\n\n" >> $displayFileName
grep -A 100 "^Connector info" /sys/kernel/debug/dri/*/i915_display_info >> $displayFileName

printf "\n\n\n" >> $displayFileName

printf "Display Info colormgr\n\n"
colormgr get-devices-by-kind display >> $displayFileName

printf "\n\n\n" >> $displayFileName

for f in /sys/class/drm/card*-*/edid; do
    ls -la /sys/class/drm/card*-*/edid
    printf "\n\n" >> $displayFileName
    printf "====================\n" >> $displayFileName
    printf "Decoding: %s" $f >> $displayFileName
    printf "\n" >> $displayFileName
    cat $f | edid-decode >> $displayFileName
    printf "====================" >> $displayFileName
done

printf "\n\n\n" >> $displayFileName

# NOTE: SYSINFOS_DEBUG is only for internal testing purposes.
if [ $SYSINFOS_DEBUG -eq 1 ]; then
    printf "Running in debug mode\n"
else
# Rename files
mv $infoFileName systeminfos-$ticketnumber.txt
mv $lspciFileName lspci-$ticketnumber.txt
mv $udevFileName udev-$ticketnumber.txt
mv $logFileName log-$ticketnumber.txt
mv $normalpackagesFileName packages-normal-$ticketnumber.txt
mv $flatpakpackagesFileName packages-flatpak-$ticketnumber.txt
mv $snappackagesFileName packages-snap-$ticketnumber.txt
mv $audioFileName audio-$ticketnumber.txt
mv $networkFileName network-$ticketnumber.txt
mv $boardFileName boardinfo-$ticketnumber.txt
mv $firmwareFileName firmware-$ticketnumber.txt
mv $tccFileName tcc-$ticketnumber.txt
mv $modprobeFileName modprobe-$ticketnumber.txt
mv $securebootFileName secureboot-$ticketnumber.txt
mv $tomteFileName tomte-$ticketnumber.txt
mv $displayFileName display-$ticketnumber.txt
mv $failogFilename failog-$ticketnumber.txt

zip -9 systeminfos-$ticketnumber.zip *-$ticketnumber.txt
fi

# NOTE: SYSINFOS_DEBUG is only for internal testing purposes.
if [ $SYSINFOS_DEBUG -eq 1 ]; then
    printf "Running in debug mode\n"
else
    # Re-Check Internet connection before sending
    printf "\n"
    printf "Ueberpruefe Internetverbindung... / Checking Internet connection... \n"
    wget -q --spider https://www.tuxedocomputers.com
    if [ $? -eq 0 ]; then
        printf "\e[32mOnline\e[0m\n"
        printf "\e[37m\e[0m\n"
    else
        printf "\e[31mOffline! Um die Ergebnisse uebermitteln zu koennen ist eine Internetverbindung erforderlich! / Offline! An Internet connection is required to transmit the results! \e[1m\n"
        printf "\e[37m\e[0m\n"
        rm systeminfos-$ticketnumber.zip *-$ticketnumber.txt
        exit 1
    fi
fi

# NOTE: SYSINFOS_DEBUG is only for internal testing purposes.
if [ $SYSINFOS_DEBUG -eq 1 ]; then
    unset LC_ALL
    unset LANG
    unset LANGUAGE
    exit 0;
else
    curl -k -F "file=@systeminfos-$ticketnumber.zip" $serverURI?ticketnumber=$ticketnumber
    rm systeminfos-$ticketnumber.zip *-$ticketnumber.txt
fi

if [ "$(. /etc/default/locale; echo $LANG)" = "de_DE.UTF-8" ]; then
    printf "\n"
    printf "Systeminfos erfolgreich uebermittelt. \n"
    printf "Wir werden die eingesendeten Systeminfos nun auswerten und uns bei Ihnen melden. \n"
    printf "Bitte haben Sie etwas Geduld. \n"
else
    printf "\n"
    printf "Systeminformations successfully transferred. \n"
    printf "We will now evaluate the submitted system information and get back to you. \n"
    printf "Please be patient. \n"
fi

unset LC_ALL
unset LANG
unset LANGUAGE

exit 0;
