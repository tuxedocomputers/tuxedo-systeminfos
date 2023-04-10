#!/bin/bash
# shellcheck disable=SC2129
LC_ALL=C
LANG=C
LANGUAGE=C
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
tccFileName=tccoutput.txt
modprobeFileName=modprobeoutput.txt
securebootFileName=securebootoutput.txt
tomteFileName=tomteoutput.txt
displayFileName=displayoutput.txt
failogFilename=failogoutput.txt
started=$(date +"%d.%m.%y-%H:%Mh")
ticketnumber="$1"

if [ -z "$SYSINFOS_DEBUG" ]; then
    SYSINFOS_DEBUG=0
elif [ "$SYSINFOS_DEBUG" -eq 1 ]; then
    echo -e "Running in debug mode\n"
else
    SYSINFOS_DEBUG=0
fi

if [ "$(id -u)" -ne 0 ]; then
    echo -e "\e[31msysteminfos.sh muss mit root Rechten ausgefuehrt werden! / systeminfos.sh must be executed with root privileges! \e[1m\n"
    echo -e "\e[37m\e[0m\n"
    exec sudo --preserve-env="XDG_SESSION_TYPE,XDG_CURRENT_DESKTOP" su -c "bash '$(basename "$0")' $1"
fi

# NOTE: SYSINFOS_DEBUG is only for internal testing purposes.
if [ "$SYSINFOS_DEBUG" -eq 1 ]; then
    echo -e "Running in debug mode\n"
else
    # Check Internet connection
    echo -e "Ueberpruefe Internetverbindung... / Checking Internet connection... \n"
    if wget -q --spider https://www.tuxedocomputers.com; then
        echo -e "\e[32mOnline\e[0m\n"
        echo -e "\e[37m\e[0m\n"
    else
        echo -e "\e[31mOffline! Um das Skript ausfuehren zu koennen ist eine Internetverbindung erforderlich! / Offline! An internet connection is required to run the script! \e[1m\n"
        echo -e "\e[37m\e[0m\n"
        exit 1
    fi

    # clear terminal window before printing messages
    clear

    if [ "$(. /etc/default/locale; echo $LANG)" = "de_DE.UTF-8" ]; then
        echo -e "Das Skript sammelt keinerlei persönliche Daten und keine Zugangsdaten! \n"
        echo -e "Es werden lediglich Informationen über Ihre Hard- und Softwarekonfiguration gesammelt. \n"
        echo -e "Bitte beachten sie dass sie nur für TUXEDO OS, Ubuntu und openSUSE Support von TUXEDO Computers erhalten. \n"
        echo -e "Eventuell auftauchende Fehlermeldungen können sie ignorieren. \n"
    else
        echo -e "The script does not collect any personal data and no access data! \n"
        echo -e "Only information about your hardware and software configuration is collected. \n"
        echo -e "Please note that you will only receive support for TUXEDO OS, Ubuntu and openSUSE from TUXEDO Computers. \n"
        echo -e "You can ignore any error messages that may appear. \n"
    fi

    # 5 seconds before next textbox. Clear screen again before next textbox appears
    sleep 5
    clear

    if [ "$(. /etc/default/locale; echo $LANG)" = "de_DE.UTF-8" ]; then
        echo -e "Wie lautet Ihre Ticketnummer? Mit [ENTER] bestätigen \n"
        echo -e "Die Ticketnummer beginnt mit 99 und ist neun Stellen lang \n"
        echo -e "Eingesendete Systeminformationen ohne gültige Ticketnummer können nicht bearbeitet werden und werden unbearbeitet geschlossen \n"
        echo -e "Um eine Ticketnummer zu erhalten, schreiben Sie uns eine E-Mail an tux[at]tuxedocomputer.com mit Ihrem Anliegen. \n"
    else
        echo -e "What is your ticket number? Confirm with [ENTER] \n"
        echo -e "The ticket number starts with 99 and is nine digits long \n"
        echo -e "Submitted system information without a valid ticket number can't be processed and will be closed unprocessed \n"
        echo -e "To get an ticket number you can contact us by e-mail to tux[at]tuxedocomputers.com \n"
    fi

    if [ -z "$ticketnumber" ]; then
        read -p "Ticket#: " ticketnumber
        if [ -z "$ticketnumber" ]; then
            echo -e "\e[31mKeine Tickernummer angegeben. Beende. / No ticket number given. Quitting. \e[1m\n"
            echo -e "\e[37m\e[0m\n"
            exit 1
        fi
    fi
fi

if [ "$(. /etc/os-release; echo $NAME)" = "TUXEDO OS" ]; then
    apt-get update && apt-get -y install curl zip nvme-cli edid-decode > /dev/null 2>&1
    echo -e "Installiere benoetigte Abhaengigkeiten. Bitte warten... / Install required dependencies. Please wait... \n"
elif [ "$(. /etc/os-release; echo $NAME)" = "Ubuntu" ]; then
    apt-get update && apt-get -y install curl zip nvme-cli edid-decode > /dev/null 2>&1
    echo -e "Installiere benoetigte Abhaengigkeiten. Bitte warten... / Install required dependencies. Please wait... \n"
elif [ "$(. /etc/os-release; echo $NAME)" = "elementary OS" ]; then
    apt-get update && apt-get -y install curl zip nvme-cli edid-decode > /dev/null 2>&1
    echo -e "Installiere benoetigte Abhaengigkeiten. Bitte warten... / Install required dependencies. Please wait... \n"
elif [ "$(. /etc/os-release; echo $NAME)" = "KDE neon" ]; then
    apt-get update && apt-get -y install curl zip nvme-cli edid-decode > /dev/null 2>&1
    echo -e "Installiere benoetigte Abhaengigkeiten. Bitte warten... / Install required dependencies. Please wait... \n"
elif [ "$(. /etc/os-release; echo $NAME)" = "openSUSE Leap" ]; then
    zypper in -y curl zip nvme-cli edid-decode > /dev/null 2>&1
    echo -e "Installiere benoetigte Abhaengigkeiten. Bitte warten... / Install required dependencies. Please wait... \n"
elif [ "$(. /etc/os-release; echo $NAME)" = "Fedora Linux" ]; then
    dnf in -y curl zip nvme-cli edid-decode > /dev/null 2>&1
    echo -e "Installiere benoetigte Abhaengigkeiten. Bitte warten... / Install required dependencies. Please wait... \n"
elif [ "$(. /etc/os-release; echo $NAME)" = "Manjaro Linux" ]; then
    pacman -Sy --noconfirm curl zip nvme-cli edid-decode > /dev/null 2>&1
    echo -e "Installiere benoetigte Abhaengigkeiten. Bitte warten... / Install required dependencies. Please wait... \n"
else
    echo -e "Nicht unterstuetze Distribution! Ueberspringe... / Unsupported Distribution! Skipping... \n"
fi


echo -e "\n"
if [ "$SYSINFOS_DEBUG" -eq 1 ]; then
    echo -e "Running in debug mode\n"
else
    echo 'Ticketnummer: ' "$ticketnumber" | tee -a $infoFileName $lspciFileName $udevFileName $logFileName $packagesFileName $audioFileName $networkFileName $boardFileName $firmwareFileName $tccFileName $modprobeFileName $securebootFileName $tomteFileName $displayFileName $failogFilename > /dev/null 2>&1
fi
echo 'systeminfos.sh started at' "$started" | tee -a $infoFileName $lspciFileName $udevFileName $logFileName $packagesFileName $audioFileName $networkFileName $boardFileName $firmwareFileName $tccFileName $modprobeFileName $securebootFileName $tomteFileName $displayFileName $failogFilename > /dev/null 2>&1
echo -e "\n\n" | tee -a $infoFileName $lspciFileName $udevFileName $logFileName $packagesFileName $audioFileName $networkFileName $boardFileName $firmwareFileName $tccFileName $modprobeFileName $securebootFileName $tomteFileName $displayFileName $failogFilename > /dev/null 2>&1

### $infoFileName Section

echo -e "uname -a\n\n" >> "$infoFileName"
uname -a >> "$infoFileName"

echo -e "\n\n\n" >> "$infoFileName"

echo -e "lsb_release -a\n\n" >> "$infoFileName"
lsb_release -a >> "$infoFileName"

echo -e "\n\n\n" >> "$infoFileName"

echo -e "lscpu\n\n" >> "$infoFileName"
lscpu >> "$infoFileName"

echo -e "\n\n\n" >> "$infoFileName"

echo -e "lscpu -e\n\n" >> "$infoFileName"
lscpu -e >> "$infoFileName"

echo -e "\n\n\n" >> "$infoFileName"

echo -e "free -h\n\n" >> "$infoFileName"
free -h >> "$infoFileName"

echo -e "\n\n\n" >> "$infoFileName"

echo -e "/sys/power/mem_sleep\n\n" >> "$infoFileName"
cat /sys/power/mem_sleep >> "$infoFileName"

echo -e "\n\n\n" >> "$infoFileName"

echo -e "lsusb\n\n" >> "$infoFileName"
lsusb >> "$infoFileName"

echo -e "\n\n\n" >> "$infoFileName"

echo -e "lsblk\n\n" >> "$infoFileName"
lsblk -d -o NAME,SIZE,TYPE,TRAN >> "$infoFileName"

echo -e "\n\n\n" >> "$infoFileName"

echo -e "fstab\n\n" >> "$infoFileName"
grep -Eiv "cifs|nfs|davfs|http" /etc/fstab >> "$infoFileName"

echo -e "\n\n\n" >> "$infoFileName"

echo -e "disk usage (df -h)\n\n" >> "$infoFileName"
df -h >> "$infoFileName"

echo -e "\n\n\n" >> "$infoFileName"

echo -e "xinput\n\n" >> "$infoFileName"
xinput >> "$infoFileName"

echo -e "\n\n\n" >> "$infoFileName"

echo -e "/etc/default/grub\n\n" >> "$infoFileName"
cat /etc/default/grub >> "$infoFileName"

echo -e "\n\n\n" >> "$infoFileName"

echo -e "lsmod\n\n" >> "$infoFileName"
lsmod >> "$infoFileName"

echo -e "\n\n\n" >> "$infoFileName"

if [ -f /etc/modprobe.d/tuxedo_keyboard.conf ]; then
    echo -e "tuxedo_keyboard.conf\n\n" >> "$infoFileName"
    cat /etc/modprobe.d/tuxedo_keyboard.conf >> "$infoFileName"
    echo -e "\n\n\n" >> "$infoFileName"

else
    echo -e "TUXEDO Keyboard scheint nicht installiert zu sein" >> "$infoFileName"
    echo -e "\n\n\n" >> "$infoFileName"

fi

echo -e "dkms status\n\n" >> "$infoFileName"
dkms status >> "$infoFileName"

echo -e "\n\n\n" >> "$infoFileName"

echo -e "upower -i $(upower -e | grep 'BAT')\n\n" >> "$infoFileName"
upower -i "$(upower -e | grep 'BAT')" >> "$infoFileName"

echo -e "\n\n\n" >> "$infoFileName"

echo -e "prime-select query\n\n" >> "$infoFileName"
prime-select query >> "$infoFileName"

echo -e "\n\n\n" >> "$infoFileName"

echo -e "XDG_SESSION_TYPE\n\n" >> "$infoFileName"
echo "$XDG_SESSION_TYPE" >> "$infoFileName"

echo -e "\n\n\n" >> "$infoFileName"

echo -e "Desktop\n\n" >> "$infoFileName"
echo "$XDG_CURRENT_DESKTOP" >> "$infoFileName"

echo -e "\n\n\n" >> "$infoFileName"

echo -e "Display-Manager\n\n" >> "$infoFileName"
cat /etc/systemd/system/display-manager.service >> "$infoFileName"

echo -e "\n\n\n" >> "$infoFileName"

echo -e "xrandr\n\n" >> "$infoFileName"
xrandr >> "$infoFileName"

echo -e "\n\n\n" >> "$infoFileName"

echo -e "lshw\n\n" >> "$infoFileName"
lshw >> "$infoFileName"

echo -e "\n\n\n" >> "$infoFileName"

echo -e "journalctl -k --grep=tpm\n\n" >> "$infoFileName"
journalctl -k --grep=tpm >> "$infoFileName"

echo -e "\n\n\n" >> "$infoFileName"

if [ -d /sys/class/nvme ]; then
    echo -e "nvme list\n\n" >> "$infoFileName"
    nvme list >> "$infoFileName"
fi

if [ -d /sys/firmware/efi ]; then
   echo -e "efibootmgr\n\n" >> "$infoFileName"
   efibootmgr -v >> "$infoFileName"
   echo -e "\n\n\n" >> "$infoFileName"
else
   echo -e "Es wird Legacy genutzt" >> "$infoFileName"
   echo -e "\n\n\n" >> "$infoFileName"
fi

### $logFileName Section

if [ -f /var/log/tuxedo-install.log ]; then
    cat /var/log/tuxedo-install.log >> "$failogFilename"

else
    echo -e "WebFAI Install-Log konnte nicht gefunden werden.\n" >> "$failogFilename"
    echo -e "Moeglicherweise handelt es sich um keine WebFAI Installation.\n" >> "$failogFilename"

fi

if [ -f /var/log/tomte/tomte.log ]; then
    echo -e "cat /var/log/tomte/tomte.log\n\n" >> "$logFileName"
    cat /var/log/tomte/tomte.log >> "$logFileName"
    echo -e "\n\n\n" >> "$logFileName"

else
    echo -e "Tomte Log konnte nicht gefunden werden.\n" >> "$logFileName"
    echo -e "Moeglicherweise ist Tomte nicht installiert.\n" >> "$logFileName"
    echo -e "\n\n\n" >> "$logFileName"

fi

echo -e "/var/log/syslog\n\n" >> "$logFileName"
tail --lines=1000 /var/log/syslog >> "$logFileName"

echo -e "\n\n\n\n\n" >> "$logFileName"

echo -e "journalctl --system -e\n\n" >> "$logFileName"
journalctl --system -e >> "$logFileName"

echo -e "\n\n\n\n\n" >> "$logFileName"

echo -e "/var/log/boot.log\n\n" >> "$logFileName"
tail --lines=1000 /var/log/boot.log >> "$logFileName"

echo -e "\n\n\n\n\n" >> "$logFileName"

echo -e "/var/log/Xorg.0.log\n\n" >> "$logFileName"
if [ -e "/var/log/Xorg.0.log" ]; then
    if [ "$(wc --lines /var/log/Xorg.0.log | cut --delimiter=" " --fields=1)" -le 2500 ]; then
        cat /var/log/Xorg.0.log >> "$logFileName"
    else
        head --lines=1250 /var/log/Xorg.0.log >> "$logFileName"
        echo "[...]" >> "$logFileName"
        tail --lines=1250 /var/log/Xorg.0.log >> "$logFileName"
    fi
fi

echo -e "\n\n\n\n\n" >> "$logFileName"

echo -e "dmesg\n\n" >> "$logFileName"
dmesg >> "$logFileName"

echo -e "\n\n\n\n\n" >> "$logFileName"

echo -e "systemctl status systemd-modules-load.service\n\n" >> "$logFileName"
systemctl status systemd-modules-load.service >> "$logFileName"

### $boardFileName Section

echo -e "BIOS date and time\n\n" >> $boardFileName
cat /sys/class/rtc/rtc0/date >> $boardFileName
echo -e "\n"  >> $boardFileName
cat /sys/class/rtc/rtc0/time >> $boardFileName

echo -e "\n\n\n" >> "$infoFileName"

echo -e "/sys/class/dmi/id/board_vendor\n\n" >> $boardFileName
cat /sys/class/dmi/id/board_vendor >> $boardFileName

echo -e "\n\n\n" >> $boardFileName

echo -e "/sys/class/dmi/id/chassis_vendor\n\n" >> $boardFileName
cat /sys/class/dmi/id/chassis_vendor >> $boardFileName

echo -e "\n\n\n" >> $boardFileName

echo -e "/sys/class/dmi/id/sys_vendor\n\n" >> $boardFileName
cat /sys/class/dmi/id/sys_vendor >> $boardFileName

echo -e "\n\n\n" >> $boardFileName

echo -e "/sys/class/dmi/id/board_name\n\n" >> $boardFileName
cat /sys/class/dmi/id/board_name >> $boardFileName

echo -e "\n\n\n" >> $boardFileName

echo -e "/sys/class/dmi/id/product_name\n\n" >> $boardFileName
cat /sys/class/dmi/id/product_name >> $boardFileName

echo -e "\n\n\n" >> $boardFileName

echo -e "/sys/class/dmi/id/product_sku\n\n" >> $boardFileName
cat /sys/class/dmi/id/product_sku >> $boardFileName

echo -e "\n\n\n" >> $boardFileName

echo -e "/sys/class/dmi/id/board_serial\n\n" >> $boardFileName
cat /sys/class/dmi/id/board_serial >> $boardFileName

echo -e "\n\n\n" >> $boardFileName

echo -e "/sys/class/dmi/id/bios_version\n\n" >> $boardFileName
cat /sys/class/dmi/id/bios_version >> $boardFileName

echo -e "\n\n\n" >> $boardFileName

if [ -f /sys/class/dmi/id/ec_firmware_release ]; then
    echo -e "/sys/class/dmi/id/ec_firmware_release\n\n" >> $boardFileName
    cat /sys/class/dmi/id/ec_firmware_release >> $boardFileName

    echo -e "\n\n\n" >> $boardFileName
else
    echo -e "EC-Version kann nicht ausgelesen werden \n" >> $boardFileName
    echo -e "\n\n\n" >> $boardFileName

fi

echo -e "dmidecode -t memory\n\n" >> $boardFileName
dmidecode -t memory >> $boardFileName

echo -e "\n\n\n" >> $boardFileName

echo -e "dmidecode\n\n" >> $boardFileName
dmidecode >> $boardFileName

### $lspciFileName Section

echo -e "lspci -vvnn\n\n" >> $lspciFileName
lspci -vvnn >> $lspciFileName

### $audioFileName Section

echo -e "aplay -l\n\n" >> $audioFileName
aplay -l >> $audioFileName

echo -e "\n\n\n" >> $audioFileName

echo -e "echo 1 > /sys/module/snd_hda_codec/parameters/dump_coef\n" >> $audioFileName
echo -e "cat /proc/asound/card*/codec*\n\n" >> $audioFileName
echo 1 > /sys/module/snd_hda_codec/parameters/dump_coef
cat /proc/asound/card*/codec* >> $audioFileName

echo -e "\n\n\n" >> $audioFileName

echo -e "lspci -v | grep -A7 -i \"audio\"\n\n" >> $audioFileName
lspci -v | grep -A7 -i "audio" >> $audioFileName

echo -e "\n\n\n" >> $audioFileName

echo -e "pacmd list-sink-inputs\n\n" >> $audioFileName
pacmd list-sink-inputs >> $audioFileName

echo -e "\n\n\n" >> $audioFileName

echo -e "pa-info\n\n" >> $audioFileName
pa-info >> $audioFileName

echo -e "\n\n\n" >> $audioFileName

echo -e "arecord -l\n\n" >> $audioFileName
arecord -l >> $audioFileName

echo -e "\n\n\n" >> $audioFileName

echo -e "fuser -v /dev/snd/*\n\n" >> $audioFileName
fuser -v /dev/snd/* >> $audioFileName

### $networkFileName Section

echo -e "\n\n\n" >> $networkFileName

echo 'lspci -nnk | grep -E -A3 -i "Ethernet|Network"' >> $networkFileName
echo -e "\n\n" >> $networkFileName
lspci -nnk | grep -E -A3 -i "Ethernet|Network" >> $networkFileName

echo -e "\n\n\n" >> $networkFileName

echo -e "ip addr show\n\n" >> $networkFileName
ip addr show >> $networkFileName

echo -e "\n\n\n" >> $networkFileName

echo -e "ip route show\n\n" >> $networkFileName
ip route show >> $networkFileName

echo -e "\n\n\n" >> $networkFileName

echo -e "rfkill list\n\n" >> $networkFileName
rfkill list >> $networkFileName

echo -e "\n\n\n" >> $networkFileName

echo -e "iwconfig\n\n" >> $networkFileName
iwconfig >> $networkFileName

echo -e "\n\n\n" >> $networkFileName

echo -e "mmcli\n\n" >> $networkFileName
mmcli -m 0 | grep -v -e "imei:*" -e "equipment id:*" >> $networkFileName

### $packagesFileName Section

echo -e "\n\n\n" >> $packagesFileName

# TUXEDO_OS
if [ "$(. /etc/os-release; echo $NAME)" = "TUXEDO OS" ]; then

    echo -e "sources.list\n\n" >> $packagesFileName
    cat /etc/apt/sources.list >> $packagesFileName

    echo -e "\n\n\n" >> $packagesFileName

    echo -e "/etc/apt/sources.list.d\n\n" >> $packagesFileName
    ls /etc/apt/sources.list.d >> $packagesFileName

    echo -e "\n\n\n" >> $packagesFileName

    echo -e "/etc/apt/sources.list.d ppa\n\n" >> $packagesFileName
    cat /etc/apt/sources.list.d/* >> $packagesFileName

    echo -e "\n\n\n" >> $packagesFileName

    echo -e "dpkg -l\n\n" >> $packagesFileName
    dpkg -l >> $packagesFileName

    echo -e "\n\n\n" >> $packagesFileName

    echo -e "dpkg -l | grep tuxedo\n\n" >> $packagesFileName
    dpkg -l|grep tuxedo >> $packagesFileName

    echo -e "\n\n\n" >> $packagesFileName

    echo -e "dpkg -l | grep nvidia\n\n" >> $packagesFileName
    dpkg -l|grep nvidia >> $packagesFileName

    echo -e "\n\n\n" >> $packagesFileName

    echo -e "/var/log/apt/history.log\n\n" >> $packagesFileName
    cat /var/log/apt/history.log >> $packagesFileName

# Ubuntu
elif [ "$(. /etc/os-release; echo $NAME)" = "Ubuntu" ]; then

    echo -e "sources.list\n\n" >> $packagesFileName
    cat /etc/apt/sources.list >> $packagesFileName

    echo -e "\n\n\n" >> $packagesFileName

    echo -e "/etc/apt/sources.list.d\n\n" >> $packagesFileName
    ls /etc/apt/sources.list.d >> $packagesFileName

    echo -e "\n\n\n" >> $packagesFileName

    echo -e "/etc/apt/sources.list.d ppa\n\n" >> $packagesFileName
    cat /etc/apt/sources.list.d/* >> $packagesFileName

    echo -e "\n\n\n" >> $packagesFileName

    echo -e "dpkg -l\n\n" >> $packagesFileName
    dpkg -l >> $packagesFileName

    echo -e "\n\n\n" >> $packagesFileName

    echo -e "dpkg -l | grep tuxedo\n\n" >> $packagesFileName
    dpkg -l|grep tuxedo >> $packagesFileName

    echo -e "\n\n\n" >> $packagesFileName

    echo -e "dpkg -l | grep nvidia\n\n" >> $packagesFileName
    dpkg -l|grep nvidia >> $packagesFileName

    echo -e "\n\n\n" >> $packagesFileName

    echo -e "/var/log/apt/history.log\n\n" >> $packagesFileName
    cat /var/log/apt/history.log >> $packagesFileName

# elementary OS
elif [ "$(. /etc/os-release; echo $NAME)" = "elementary OS" ]; then

    echo -e "sources.list\n\n" >> $packagesFileName
    cat /etc/apt/sources.list >> $packagesFileName

    echo -e "\n\n\n" >> $packagesFileName

    echo -e "/etc/apt/sources.list.d\n\n" >> $packagesFileName
    ls /etc/apt/sources.list.d >> $packagesFileName

    echo -e "\n\n\n" >> $packagesFileName

    echo -e "/etc/apt/sources.list.d ppa\n\n" >> $packagesFileName
    cat /etc/apt/sources.list.d/* >> $packagesFileName

    echo -e "\n\n\n" >> $packagesFileName

    echo -e "dpkg -l\n\n" >> $packagesFileName
    dpkg -l >> $packagesFileName

    echo -e "\n\n\n" >> $packagesFileName

    echo -e "dpkg -l | grep tuxedo\n\n" >> $packagesFileName
    dpkg -l|grep tuxedo >> $packagesFileName

    echo -e "\n\n\n" >> $packagesFileName

    echo -e "dpkg -l | grep nvidia\n\n" >> $packagesFileName
    dpkg -l|grep nvidia >> $packagesFileName

    echo -e "\n\n\n" >> $packagesFileName

    echo -e "/var/log/apt/history.log\n\n" >> $packagesFileName
    cat /var/log/apt/history.log >> $packagesFileName

# KDE neon
elif [ "$(. /etc/os-release; echo $NAME)" = "KDE neon" ]; then

    echo -e "sources.list\n\n" >> $packagesFileName
    cat /etc/apt/sources.list >> $packagesFileName

    echo -e "\n\n\n" >> $packagesFileName

    echo -e "/etc/apt/sources.list.d\n\n" >> $packagesFileName
    ls /etc/apt/sources.list.d >> $packagesFileName

    echo -e "\n\n\n" >> $packagesFileName

    echo -e "/etc/apt/sources.list.d ppa\n\n" >> $packagesFileName
    cat /etc/apt/sources.list.d/* >> $packagesFileName

    echo -e "\n\n\n" >> $packagesFileName

    echo -e "dpkg -l\n\n" >> $packagesFileName
    dpkg -l >> $packagesFileName

    echo -e "\n\n\n" >> $packagesFileName

    echo -e "dpkg -l | grep tuxedo\n\n" >> $packagesFileName
    dpkg -l|grep tuxedo >> $packagesFileName

    echo -e "\n\n\n" >> $packagesFileName

    echo -e "dpkg -l | grep nvidia\n\n" >> $packagesFileName
    dpkg -l|grep nvidia >> $packagesFileName

    echo -e "\n\n\n" >> $packagesFileName

    echo -e "/var/log/apt/history.log\n\n" >> $packagesFileName
    cat /var/log/apt/history.log >> $packagesFileName

# openSUSE
elif [ "$(. /etc/os-release; echo $NAME)" = "openSUSE Leap" ]; then

    echo -e "/etc/zypp/repos.d\n\n" >> $packagesFileName
    ls -al /etc/zypp/repos.d/ >> $packagesFileName

    echo -e "\n\n\n" >> $packagesFileName

    echo -e "zypper sources lists\n\n" >> $packagesFileName
    cat /etc/zypp/repos.d/* >> $packagesFileName

    echo -e "\n\n\n" >> $packagesFileName

    echo -e "rpm -qa\n\n" >> $packagesFileName
    rpm -qa >> $packagesFileName

    echo -e "\n\n\n" >> $packagesFileName

    echo -e "rpm -qa | grep tuxedo\n\n" >> $packagesFileName
    rpm -qa | grep tuxedo >> $packagesFileName

    echo -e "\n\n\n" >> $packagesFileName

    echo -e "rpm -qa | grep nvidia\n\n" >> $packagesFileName
    rpm -qa | grep nvidia >> $packagesFileName

    echo -e "\n\n\n" >> $packagesFileName

    echo -e "/var/log/zypp/history\n\n" >> $packagesFileName
    cat /var/log/zypp/history >> $packagesFileName

# Fedora
elif [ "$(. /etc/os-release; echo $NAME)" = "Fedora Linux" ]; then

    echo -e "/etc/yum.repos.d\n\n" >> $packagesFileName
    ls -al /etc/yum.repos.d/ >> $packagesFileName

    echo -e "\n\n\n" >> $packagesFileName

    echo -e "dnf sources lists\n\n" >> $packagesFileName
    cat /etc/yum.repos.d/* >> $packagesFileName

    echo -e "\n\n\n" >> $packagesFileName

    echo -e "rpm -qa\n\n" >> $packagesFileName
    rpm -qa >> $packagesFileName

    echo -e "\n\n\n" >> $packagesFileName

    echo -e "rpm -qa | grep tuxedo\n\n" >> $packagesFileName
    rpm -qa | grep tuxedo >> $packagesFileName

    echo -e "\n\n\n" >> $packagesFileName

    echo -e "rpm -qa | grep nvidia\n\n" >> $packagesFileName
    rpm -qa | grep nvidia >> $packagesFileName

    echo -e "\n\n\n" >> $packagesFileName

    echo -e "/var/log/dnf.log\n\n" >> $packagesFileName
    cat /var/log/dnf.log >> $packagesFileName

    echo -e "/var/log/dnf.librepo.log\n\n" >> $packagesFileName
    cat /var/log/dnf.librepo.log >> $packagesFileName

    echo -e "/var/log/dnf.rpm.log\n\n" >> $packagesFileName
    cat /var/log/dnf.rpm.log >> $packagesFileName

# Manjaro
elif [ "$(. /etc/os-release; echo $NAME)" = "Manjaro Linux" ]; then

    echo -e "cat /etc/pacman.conf" >> $packagesFileName
    cat /etc/pacman.conf >> $packagesFileName

    echo -e "\n\n\n" >> $packagesFileName

    echo -e "pacman -Qqe" >> $packagesFileName
    pacman -Qqe >> $packagesFileName

    echo -e "pacman -Qqe | grep tuxedo" >> $packagesFileName
    pacman -Qqe | grep tuxedo >> $packagesFileName

    echo -e "\n\n\n" >> $packagesFileName

    echo -e "pacman Repo's" >> $packagesFileName
    cat /etc/pacman.conf | grep -E 'core|extra|community|multilib' >> $packagesFileName

    echo -e "\n\n\n" >> $packagesFileName

    cat /var/log/pacman.log >> $packagesFileName
    echo -e "\n\n\n" >> $packagesFileName

else
    echo -e "Nicht unterstuetze Distribution! Ueberspringe...\n"
    echo -e "Unsupported Distribution! Skipping... \n\n\n"
fi

### $udevFileName Section

echo -e "/etc/udev/rules.d/\n\n" >> $udevFileName
ls /etc/udev/rules.d/ >> $udevFileName

echo -e "\n\n\n" >> $udevFileName

echo -e "/etc/udev/rules.d/ files\n\n" >> $udevFileName
cat /etc/udev/rules.d/* >> $udevFileName

echo -e "/lib/udev/rules.d/\n\n" >> $udevFileName
ls /lib/udev/rules.d/ >> $udevFileName

echo -e "\n\n\n" >> $udevFileName

echo -e "/lib/udev/rules.d/ files\n\n" >> $udevFileName
cat /lib/udev/rules.d/* >> $udevFileName

# $firmwareFileName Section

echo -e "ls -l /lib/firmware\n\n" >> $firmwareFileName
ls -l /lib/firmware >> $firmwareFileName

echo -e "\n\n\n" >> $firmwareFileName

echo -e "dmesg|grep firmware\n\n" >> $firmwareFileName
dmesg|grep firmware >> $firmwareFileName

# $tccFileName Section

echo -e "cat /etc/tcc/settings\n\n" >> $tccFileName
cat /etc/tcc/settings >> $tccFileName

echo -e "\n\n\n" >> $tccFileName

echo -e "systemctl is-active tccd.service\n\n" >> $tccFileName
systemctl is-active tccd.service >> $tccFileName

# $modprobeFileName Section

echo -e "/etc/modprobe.d/\n\n" >> $modprobeFileName
ls /etc/modprobe.d/ >> $modprobeFileName

echo -e "\n\n\n" >> $modprobeFileName

echo -e "/etc/modprobe.d/ files\n\n" >> $modprobeFileName
cat /etc/modprobe.d/* >> $modprobeFileName

# $securebootFileName section

echo -e "mokutil --sb-state\n\n" >> $securebootFileName
mokutil --sb-state >> $securebootFileName

echo -e "\n\n\n" >> $securebootFileName

echo -e "mokutil --pk\n\n" >> $securebootFileName
mokutil --pk >> $securebootFileName

echo -e "\n\n\n" >> $securebootFileName

echo -e "mokutil --kek\n\n" >> $securebootFileName
mokutil --kek >> $securebootFileName

echo -e "\n\n\n" >> $securebootFileName

echo -e "mokutil --db\n\n" >> $securebootFileName
mokutil --db >> $securebootFileName

echo -e "\n\n\n" >> $securebootFileName

echo -e "mokutil --dbx\n\n" >> $securebootFileName
mokutil --dbx >> $securebootFileName

echo -e "\n\n\n" >> $securebootFileName

echo -e "mokutil --list-enrolled\n\n" >> $securebootFileName
mokutil --list-enrolled >> $securebootFileName

echo -e "\n\n\n" >> $securebootFileName

echo -e "mokutil --list-new\n\n" >> $securebootFileName
mokutil --list-new >> $securebootFileName

echo -e "\n\n\n" >> $securebootFileName

echo -e "mokutil --list-delete\n\n" >> $securebootFileName
mokutil --list-delete >> $securebootFileName

echo -e "\n\n\n" >> $securebootFileName

echo -e "mokutil --mokx\n\n" >> $securebootFileName
mokutil --mokx >> $securebootFileName

echo -e "\n\n\n" >> $securebootFileName

# $tomteFileName section

echo -e "tuxedo-tomte list\n\n" >> $tomteFileName
tuxedo-tomte list >> $tomteFileName

echo -e "\n\n\n" >> $tomteFileName

if [ -f /etc/tomte/AUTOMATIC ]; then
    echo -e "Tomte wird in den vorgesehenen Standardeinstellungen verwendet\n" >> $tomteFileName
    echo -e "\n\n\n" >> $tomteFileName
elif [ -f /etc/tomte/DONT_CONFIGURE ]; then
    echo -e "Tomte ist so konfiguriert, dass nur die als \"notwendig\" (prerequisite) markierten Module konfiguriert werden\n" >> $tomteFileName
    echo -e "\n\n\n" >> $tomteFileName
elif [ -f /etc/tomte/UPDATES_ONLY ]; then
    echo -e "Tomte ist so konfiguriert, dass nur Aktualisierungen ueber Tomte verarbeitet werden\n" >> $tomteFileName
    echo -e "\n\n\n" >> $tomteFileName
else
    echo -e "Tomte wird in den Standardeinstellungen verwendet\n" >> $tomteFileName
    echo -e "\n\n\n" >> $tomteFileName
fi

# $displayFileName section

echo -e "glxinfo|grep vendor\n\n" >> $displayFileName
glxinfo|grep vendor >> $displayFileName

echo -e "\n\n\n" >> $displayFileName

echo -e "Display Info (/sys/kernel/debug/dri/*/i1915_display_info)\n\n" >> $displayFileName
grep -A 100 "^Connector info" /sys/kernel/debug/dri/*/i915_display_info >> $displayFileName

echo -e "\n\n\n" >> $displayFileName

echo -e "Display Info colormgr\n\n"
colormgr get-devices-by-kind display >> $displayFileName

echo -e "\n\n\n" >> $displayFileName

for f in /sys/class/drm/card*-*/edid; do
    ls -la /sys/class/drm/card*-*/edid
    echo -e "\n\n" >> $displayFileName
    echo -e "====================\n" >> $displayFileName
    echo -e "Decoding: ${f}" >> $displayFileName
    echo -e "\n" >> $displayFileName
    cat "$f" | edid-decode >> $displayFileName
    echo -e "====================" >> $displayFileName
done

echo -e "\n\n\n" >> $displayFileName

# NOTE: SYSINFOS_DEBUG is only for internal testing purposes.
if [ "$SYSINFOS_DEBUG" -eq 1 ]; then
    echo -e "Running in debug mode\n"
else
# Rename files
mv "$infoFileName" "systeminfos-${ticketnumber}.txt"
mv "$lspciFileName" "lspci-${ticketnumber}.txt"
mv "$udevFileName" "udev-${ticketnumber}.txt"
mv "$logFileName" "log-${ticketnumber}.txt"
mv "$packagesFileName" "packages-${ticketnumber}.txt"
mv "$audioFileName" "audio-${ticketnumber}.txt"
mv "$networkFileName" "network-${ticketnumber}.txt"
mv "$boardFileName" "boardinfo-${ticketnumber}.txt"
mv "$firmwareFileName" "firmware-${ticketnumber}.txt"
mv "$tccFileName" "tcc-${ticketnumber}.txt"
mv "$modprobeFileName" "modprobe-${ticketnumber}.txt"
mv "$securebootFileName" "secureboot-${ticketnumber}.txt"
mv "$tomteFileName" "tomte-${ticketnumber}.txt"
mv "$displayFileName" "display-${ticketnumber}.txt"
mv "$failogFilename" "failog-${ticketnumber}.txt"

zip -9 "systeminfos-${ticketnumber}.zip" ./*-"$ticketnumber".txt
fi

# NOTE: SYSINFOS_DEBUG is only for internal testing purposes.
if [ "$SYSINFOS_DEBUG" -eq 1 ]; then
    echo -e "Running in debug mode\n"
else
    # Re-Check Internet connection before sending
    echo -e "\n"
    echo -e "Ueberpruefe Internetverbindung... / Checking Internet connection... \n"
    if wget -q --spider https://www.tuxedocomputers.com; then
        echo -e "\e[32mOnline\e[0m\n"
        echo -e "\e[37m\e[0m\n"
    else
        echo -e "\e[31mOffline! Um die Ergebnisse uebermitteln zu koennen ist eine Internetverbindung erforderlich! / Offline! An Internet connection is required to transmit the results! \e[1m\n"
        echo -e "\e[37m\e[0m\n"
        rm "systeminfos-${ticketnumber}.zip" ./*-"$ticketnumber".txt
        exit 1
    fi
fi

# NOTE: SYSINFOS_DEBUG is only for internal testing purposes.
if [ "$SYSINFOS_DEBUG" -eq 1 ]; then
    unset LC_ALL
    unset LANG
    unset LANGUAGE
    exit 0;
else
    curl -k -F "file=@systeminfos-${ticketnumber}.zip" "${serverURI}?ticketnumber=${ticketnumber}"
    rm "systeminfos-${ticketnumber}.zip" ./*-"$ticketnumber".txt
fi

if [ "$(. /etc/default/locale; echo $LANG)" = "de_DE.UTF-8" ]; then
    echo -e "\n"
    echo -e "Systeminfos erfolgreich uebermittelt. \n"
    echo -e "Wir werden die eingesendeten Systeminfos nun auswerten und uns bei Ihnen melden. \n"
    echo -e "Bitte haben Sie etwas Geduld. \n"
else
    echo -e "\n"
    echo -e "Systeminformations successfully transferred. \n"
    echo -e "We will now evaluate the submitted system information and get back to you. \n"
    echo -e "Please be patient. \n"
fi

unset LC_ALL
unset LANG
unset LANGUAGE

exit 0;
