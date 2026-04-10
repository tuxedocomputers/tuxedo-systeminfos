#!/bin/sh
### change language to "C"
LC_ALL=C
LANG=C
LANGUAGE=C
### set other parameter
serverURI=https://systeminfo.tuxedo.de/systeminfo.php
snappackagesFileName=snappackagesoutput.txt
started=$(date +"%Y-%m-%d-%H:%Mh")
ticketnumber=$1
### set filenames
audioFileName=audiooutput.txt
batteryFileName=batteryoutput.txt
boardFileName=boardoutput.txt
displayFileName=displayoutput.txt
failogFilename=failogoutput.txt
firmwareFileName=firmwareoutput.txt
flatpakpackagesFileName=flatpakpackagesoutput.txt
infoFileName=systeminfos.txt
logFileName=logoutput.txt
lspciFileName=lspcioutput.txt
modprobeFileName=modprobeoutput.txt
networkFileName=networkoutput.txt
normalpackagesFileName=normalpackagesoutput.txt
securebootFileName=securebootoutput.txt
tccFileName=tccoutput.txt
tomteFileName=tomteoutput.txt
udevFileName=udevoutput.txt

### check root privileges
if [ "$(id -u)" -ne 0 ]; then
    printf "\e[31msysteminfos.sh muss mit root Rechten ausgefuehrt werden! / systeminfos.sh must be executed with root privileges! \e[0m\n"
    exec sudo --preserve-env="XDG_SESSION_TYPE,XDG_CURRENT_DESKTOP" su -c "sh $0"
fi

if [ -f /usr/bin/systeminfos.sh ]; then
    echo "Found myself as installed package. Continue…" > /dev/null
else
    if [ -f /usr/bin/apt-get ]; then
        apt-get update && apt-get -y install curl zip nvme-cli edid-decode efibootmgr lm-sensors jq > /dev/null 2>&1
        printf "%s\n" "Installiere benoetigte Abhaengigkeiten. Bitte warten... / Install required dependencies. Please wait..."
    elif [ -f /usr/bin/zypper ]; then
        zypper in -y curl zip nvme-cli edid-decode efibootmgr lm_sensors jq > /dev/null 2>&1
        printf "%s\n" "Installiere benoetigte Abhaengigkeiten. Bitte warten... / Install required dependencies. Please wait..."
    elif [ -f /usr/bin/dnf ]; then
        dnf in -y curl zip nvme-cli edid-decode efibootmgr lm_sensors jq > /dev/null 2>&1
        printf "Installiere benoetigte Abhaengigkeiten. Bitte warten... / Install required dependencies. Please wait... \n"
    elif [ -f /usr/bin/pacman ]; then
        pacman -Sy --noconfirm curl zip nvme-cli edid-decode efibootmgr lm_sensors jq > /dev/null 2>&1
        printf "%s\n" "Installiere benoetigte Abhaengigkeiten. Bitte warten... / Install required dependencies. Please wait... \n"
    else
        if [ "$(. /etc/default/locale; echo $LANG)" = "de_DE.UTF-8" ]; then
            clear
            printf "%s\n" "Sie verwenden eine nicht unterstützte Distribution. Bitte installieren Sie die entsprechende Pakete für die folgende Software selbst und führen das Skript erneut aus"
            printf "%s\n" "- curl" "- zip" "- nvme-cli" "- edid-decode" "- efibootmgr" "- lm_sensors" "- jq"
            exit 1
        else
            clear
            printf "%s\n" "You are using an unsupported distribution. Please install the corresponding packages for the following software yourself and run the script again"
            printf "%s\n" "- curl" "- zip" "- nvme-cli" "- edid-decode" "- efibootmgr" "- lm_sensors" "- jq"
            exit 1
        fi
    fi
fi

### Check Internet connection
printf "Ueberpruefe Internetverbindung... / Checking Internet connection... \n"
scriptisonline=$(curl -o /dev/null -I -L -s -w "%{http_code}" https://www.tuxedocomputers.com)
if [ $scriptisonline -eq 200 ]; then
    printf "\e[32mOnline\e[0m\n"
    printf "\e[37m\e[0m\n"
else
    printf "\e[31mOffline! Um das Skript ausfuehren zu koennen ist eine Internetverbindung erforderlich! / Offline! An internet connection is required to run the script! \e[1m\n"
    printf "Sollten Sie sich in einem Firmennetzwerk befinden, führen Sie das Skript bitte außerhalb des Firmennetzwerkes erneut aus. / If you are in a corporate network, please run the script again outside the corporate network. \n"
    printf "In manchen Firmennetzwerken werden Skripte als nicht vertrauenswürdig eingestuft und blockiert. / In some corporate networks, scripts are classified as untrusted and blocked. \n"
    printf "\e[37m\e[0m\n"
    exit 1
fi

### clear terminal window before printing messages
clear

if [ "$(. /etc/default/locale; echo $LANG)" = "de_DE.UTF-8" ]; then
    printf "%s\n" "Das Skript sammelt keinerlei persönliche Daten und keine Zugangsdaten!"
    printf "%s\n" "Es werden lediglich Informationen über Ihre Hard- und Softwarekonfiguration gesammelt."
    printf "%s\n" "Bitte beachten Sie, dass Sie nur für TUXEDO OS und Ubuntu technischen Support von TUXEDO Computers erhalten."
    printf "%s\n" "Eventuell auftauchende Fehlermeldungen können Sie ignorieren."
else
    printf "%s\n" "The script does not collect any personal data and no access data!"
    printf "%s\n" "Only information about your hardware and software configuration is collected."
    printf "%s\n" "Please note that you will only receive technical support for TUXEDO OS and Ubuntu from TUXEDO Computers."
    printf "%s\n" "You can ignore any error messages that may appear."
fi

### Wait 5 seconds before next textbox. Clear screen again before next textbox appears
sleep 5
clear

if [ "$(. /etc/default/locale; echo $LANG)" = "de_DE.UTF-8" ]; then
    printf "%s\n" "Wie lautet Ihre Ticketnummer? Mit [ENTER] bestätigen"
    printf "%s\n" "Die Ticketnummer beginnt mit 99 und ist neun Stellen lang"
    printf "%s\n" "Eingesendete Systeminformationen ohne gültige Ticketnummer können nicht bearbeitet werden und werden unbearbeitet geschlossen"
    printf "%s\n" "Um eine Ticketnummer zu erhalten, schreiben Sie uns eine E-Mail an tux[at]tuxedocomputer.com mit Ihrem Anliegen."
else
    printf "%s\n" "What is your ticket number? Confirm with [ENTER]"
    printf "%s\n" "The ticket number starts with 99 and is nine digits long"
    printf "%s\n" "Submitted system information without a valid ticket number can't be processed and will be closed unprocessed"
    printf "%s\n" "To get an ticket number you can contact us by e-mail to tux[at]tuxedocomputers.com"
fi

if [ -z $ticketnumber ]; then
    read -p "Ticket#: " ticketnumber
    if [ -z $ticketnumber ]; then
        printf "\e[31mKeine Tickernummer angegeben. Beende. / No ticket number given. Quitting. \e[1m\n"
        printf "\e[37m\e[0m\n"
        exit 1
    fi
fi

printf "\n"

echo 'Ticketnummer: ' $ticketnumber | tee -a $audioFileName $batteryFileName $boardFileName $displayFileName $failogFilename $firmwareFileName $flatpakpackagesFileName $infoFileName $logFileName $lspciFileName $modprobeFileName $networkFileName $normalpackagesFileName $securebootFileName $snappackagesFileName $tccFileName $tomteFileName $udevFileName > /dev/null 2>&1

echo 'systeminfos.sh started at' $started | tee -a $audioFileName $batteryFileName $boardFileName $displayFileName $failogFilename $firmwareFileName $flatpakpackagesFileName $infoFileName $logFileName $lspciFileName $modprobeFileName $networkFileName $normalpackagesFileName $securebootFileName $snappackagesFileName $tccFileName $tomteFileName $udevFileName > /dev/null 2>&1
printf "\n\n" | tee -a $audioFileName $batteryFileName $boardFileName $displayFileName $failogFilename $firmwareFileName $flatpakpackagesFileName $infoFileName $logFileName $lspciFileName $modprobeFileName $networkFileName $normalpackagesFileName $securebootFileName $snappackagesFileName $tccFileName $tomteFileName $udevFileName > /dev/null 2>&1

##### $audioFileName Section

printf "%s\n\n" "aplay -l" >> $audioFileName
aplay -l >> $audioFileName

printf "\n\n\n%s\n" "echo 1 > /sys/module/snd_hda_codec/parameters/dump_coef" >> $audioFileName
printf "%s\n\n" "cat /proc/asound/card*/codec*" >> $audioFileName
echo 1 > /sys/module/snd_hda_codec/parameters/dump_coef
printf "\n"
printf "\n\n\n%s" "/proc/asound/card*/codec* files" >> $audioFileName
for f in /proc/asound/card*/codec*; do
    printf "\n\n\n=== %s ===\n\n" "$f" >> $audioFileName
    cat "$f" >> $audioFileName
done

printf "\n\n\n%s\n\n" "lspci -v | grep -A7 -i "audio"" >> $audioFileName
lspci -v | grep -A7 -i "audio" >> $audioFileName

printf "\n\n\n%s\n\n" "pacmd list-sink-inputs" >> $audioFileName
pacmd list-sink-inputs >> $audioFileName

printf "\n\n\n%s\n\n" "pa-info" >> $audioFileName
pa-info >> $audioFileName

printf "\n\n\n%s\n\n" "arecord -l" >> $audioFileName
arecord -l >> $audioFileName

printf "\n\n\n%s\n\n" "fuser -v /dev/snd/*" >> $audioFileName
fuser -v /dev/snd/* >> $audioFileName

##### $batteryFileName section

printf "%s\n\n" "upower -d" >> $batteryFileName
upower -d >> $batteryFileName

printf "\n\n\n" >> $batteryFileName

if [ -f /sys/devices/platform/tuxedo_keyboard/charging_profile/charging_profile ]; then
    printf "%s\n\n" "charging_profile" >> $batteryFileName
    cat /sys/devices/platform/tuxedo_keyboard/charging_profile/charging_profile >> $batteryFileName
    printf "\n\n\n" >> $batteryFileName
else
    printf "%s\n\n\n" "Modell unterstuetzt kein charging_profile" >> $batteryFileName
fi

if [ -f /sys/devices/platform/tuxedo_keyboard/charging_priority/charging_prio ]; then
    printf "%s\n\n" "charging_prio" >> $batteryFileName
    cat /sys/devices/platform/tuxedo_keyboard/charging_priority/charging_prio >> $batteryFileName
    printf "\n\n\n" >> $batteryFileName
else
    printf "%s\n\n\n" "Modell unterstuetzt kein charging_prio" >> $batteryFileName
fi

if [ -f /sys/class/power_supply/BAT*/charge_type ]; then
    printf "%s\n\n" "charge_type" >> $batteryFileName
    cat /sys/class/power_supply/BAT*/charge_type >> $batteryFileName
    printf "\n\n\n" >> $batteryFileName

    printf "%s\n\n" "charge_control_start_threshold" >> $infoFilbatteryFileName
    cat /sys/class/power_supply/BAT*/charge_control_start_threshold >> $batteryFileName
    printf "\n\n\n" >> $batteryFileName

    printf "%s\n\n" "charge_control_end_threshold" >> $batteryFileName
    cat /sys/class/power_supply/BAT*/charge_control_end_threshold >> $batteryFileName
    printf "\n\n\n" >> $batteryFileName

    printf "%s\n\n" "available_start_thresholds" >> $batteryFileName
    cat /sys/class/power_supply/BAT*/charge_control_start_available_thresholds >> $batteryFileName
    printf "\n\n\n" >> $batteryFileName

    printf "%s\n\n" "available_end_thresholds" >> $batteryFileName
    cat /sys/class/power_supply/BAT*/charge_control_end_available_thresholds >> $batteryFileName
    printf "\n\n\n" >> $batteryFileName

else
    printf "%s\n\n\n" "Modell unterstuetzt kein Flexicharger" >> $batteryFileName
fi

if [ -f /sys/class/power_supply/BAT*/raw_cycle_count ]; then
    printf "%s\n\n" "raw_cycle_count" >> $batteryFileName
    cat /sys/class/power_supply/BAT*/raw_cycle_count >> $batteryFileName
    raw_cycle_count=$(cat /sys/class/power_supply/BAT*/raw_cycle_count)
    
    printf "\n\n\n%s\n\n" "raw_xif1" >> $batteryFileName
    cat /sys/class/power_supply/BAT*/raw_xif1 >> $batteryFileName
    raw_xif1=$(cat /sys/class/power_supply/BAT*/raw_xif1)

    printf "\n\n\n%s\n\n" "raw_xif2" >> $batteryFileName
    cat /sys/class/power_supply/BAT*/raw_xif2 >> $batteryFileName
    raw_xif2=$(cat /sys/class/power_supply/BAT*/raw_xif2)
    printf "\n\n\n" >> $batteryFileName

    printf "%s\n" "Cycles:  $raw_cycle_count" >> $batteryFileName
    printf "%s\n" "Health:  $(expr $raw_xif2 \* 100 / $raw_xif1)%%" >> $batteryFileName

else
    printf "%s\n\n\n" "Kein NB02 Geraet" >> $batteryFileName
fi


##### $boardFileName Section

printf "%s\n\n" "BIOS date and time" >> $boardFileName
cat /sys/class/rtc/rtc0/date >> $boardFileName
printf "\n"  >> $boardFileName
cat /sys/class/rtc/rtc0/time >> $boardFileName

printf "\n\n\n%s\n\n" "find /sys/class/dmi/id/ -maxdepth 1 -type f -print -exec cat {}  \; -exec echo \;" >> $boardFileName
find /sys/class/dmi/id/ -maxdepth 1 -type f -print -exec cat {}  \; -exec echo \; >> $boardFileName

printf "\n\n\n%s\n\n" "dmidecode -t memory" >> $boardFileName
dmidecode -t memory >> $boardFileName

printf "\n\n\n%s\n\n" "dmidecode" >> $boardFileName
dmidecode >> $boardFileName


##### $displayFileName section

printf "%s\n\n" "glxinfo|grep vendor" >> $displayFileName
glxinfo|grep vendor >> $displayFileName

printf "\n\n\n%s\n\n" "Display Info (/sys/kernel/debug/dri/*/i1915_display_info)" >> $displayFileName
grep -A 100 "^Connector info" /sys/kernel/debug/dri/*/i915_display_info >> $displayFileName

printf "\n\n\n%s\n\n" "Display Info colormgr"
colormgr get-devices-by-kind display >> $displayFileName

printf "\n\n\n" >> $displayFileName

for f in /sys/class/drm/card*-*/edid; do
    ls -la /sys/class/drm/card*-*/edid
    printf "\n\n" >> $displayFileName
    printf "%s\n" "====================" >> $displayFileName
    printf "Decoding: %s" $f >> $displayFileName
    printf "\n" >> $displayFileName
    cat $f | edid-decode >> $displayFileName
    printf "====================" >> $displayFileName
done


##### $failogFilename Section

if [ -f /var/log/tuxedo-install.log ]; then
    cat /var/log/tuxedo-install.log >> $failogFilename

else
    printf "%s\n" "WebFAI Install-Log konnte nicht gefunden werden." >> $failogFilename
    printf "%s\n" "Moeglicherweise handelt es sich um keine WebFAI Installation." >> $failogFilename

fi


##### $firmwareFileName Section

printf "%s\n\n" "ls -l /lib/firmware" >> $firmwareFileName
ls -l /lib/firmware >> $firmwareFileName

printf "\n\n\n%s\n\n" "dmesg|grep firmware" >> $firmwareFileName
dmesg|grep firmware >> $firmwareFileName


##### $flatpakpackagesFileName

printf "%s\n\n" "flatpak list --app --show-details" >> $flatpakpackagesFileName
flatpak list >> $flatpakpackagesFileName

##### $infoFileName Section

printf "%s\n\n" "users" >> $infoFileName
users >> $infoFileName

printf "\n\n\n%s\n\n" "uname -a" >> $infoFileName
uname -a >> $infoFileName

printf "\n\n\n%s\n\n" "lsb_release -a" >> $infoFileName
lsb_release -a >> $infoFileName

printf "\n\n\n%s\n\n" "lscpu" >> $infoFileName
lscpu >> $infoFileName

printf "\n\n\n%s\n\n" "lscpu -e" >> $infoFileName
lscpu -e >> $infoFileName

printf "\n\n\n%s\n\n" "free -h" >> $infoFileName
free -h >> $infoFileName

printf "\n\n\n%s\n\n" "/sys/power/mem_sleep" >> $infoFileName
cat /sys/power/mem_sleep >> $infoFileName

printf "\n\n\n%s\n\n" "lsusb" >> $infoFileName
lsusb >> $infoFileName

printf "\n\n\n%s\n\n" "lsblk" >> $infoFileName
lsblk -d -o NAME,SIZE,TYPE,TRAN >> $infoFileName

printf "\n\n\n%s\n\n" "fstab" >> $infoFileName
egrep -iv "cifs|nfs|davfs|http" /etc/fstab >> $infoFileName

printf "\n\n\n%s\n\n" "disk usage (df -h)" >> $infoFileName
df -h >> $infoFileName

printf "\n\n\n%s\n\n" "xinput" >> $infoFileName
xinput >> $infoFileName

printf "\n\n\n%s\n\n" "/etc/default/grub" >> $infoFileName
cat /etc/default/grub >> $infoFileName

printf "\n\n\n%s" "/etc/default/grub.d" >> $infoFileName
for f in /etc/default/grub.d/*; do
    printf "\n\n\n=== %s ===\n\n" "$f" >> $infoFileName
    cat "$f" >> $infoFileName
done

printf "\n\n\n%s\n\n" "lsmod" >> $infoFileName
lsmod >> $infoFileName

printf "\n\n\n" >> $infoFileName

if [ -f /etc/modprobe.d/tuxedo_keyboard.conf ]; then
    printf "%s\n\n" "tuxedo_keyboard.conf" >> $infoFileName
    cat /etc/modprobe.d/tuxedo_keyboard.conf >> $infoFileName
    printf "\n\n\n" >> $infoFileName
else
    printf "%s\n\n\n" "TUXEDO Drivers scheint nicht installiert zu sein" >> $infoFileName
fi

printf "%s\n\n" "dkms status" >> $infoFileName
dkms status >> $infoFileName

printf "\n\n\n%s\n\n" "prime-select query" >> $infoFileName
prime-select query >> $infoFileName

printf "\n\n\n%s\n\n" "XDG_SESSION_TYPE" >> $infoFileName
echo $XDG_SESSION_TYPE >> $infoFileName

printf "\n\n\n%s\n\n" "Desktop" >> $infoFileName
echo $XDG_CURRENT_DESKTOP >> $infoFileName

printf "\n\n\n%s\n\n" "Display-Manager" >> $infoFileName
cat /etc/systemd/system/display-manager.service >> $infoFileName

printf "\n\n\n%s\n\n" "xrandr" >> $infoFileName
xrandr >> $infoFileName

printf "\n\n\n%s\n\n" "lshw" >> $infoFileName
lshw >> $infoFileName

printf "\n\n\n%s\n\n" "journalctl -k --grep=tpm" >> $infoFileName
journalctl -k --grep=tpm >> $infoFileName

printf "\n\n\n" >> $infoFileName

if [ -d /sys/class/nvme ]; then
    printf "%s\n\n" "nvme list" >> $infoFileName
    nvme list >> $infoFileName
    printf "\n\n\n" >> $infoFileName
fi

if [ -d /sys/firmware/efi ]; then
   printf "%s\n\n" "efibootmgr" >> $infoFileName
   efibootmgr -v >> $infoFileName
   printf "\n\n\n" >> $infoFileName
else
   printf "%s\n\n\n" "Es wird Legacy genutzt" >> $infoFileName
fi

printf "%s\n\n" "lm-sensors" >> $infoFileName
sensors >> $infoFileName


if [ -d /var/crash ]; then
    printf "\n\n\n%s\n\n" "/var/crash/" >> $infoFileName
    ls -la /var/crash/ >> $infoFileName
    printf "\n\n\n%s" "/var/crash/" >> $infoFileName
    for f in /var/crash/*; do
        printf "\n\n\n=== %s ===\n\n" "$f" >> $infoFileName
        cat "$f" >> $infoFileName
    done
fi

##### $logFileName Section


if [ -f /var/log/fai-tomte.log ]; then
    printf "%s\n\n" "cat /var/log/fai-tomte.log" >> $logFileName
    cat /var/log/fai-tomte.log >> $logFileName
    printf "\n\n\n" >> $logFileName
else
    printf "%s\n" "Tomte FAI Log konnte nicht gefunden werden." >> $logFileName
    printf "%s\n" "Moeglicherweise handelt es sich nicht um eine WebFAI Installation oder diese Distribution wird nicht von Tomte unterstuetzt." >> $logFileName
    printf "\n\n\n" >> $logFileName
fi

if [ -f /var/log/tomte/tomte.log ]; then
    printf "%s\n\n" "/var/log/tomte/tomte.log" >> $logFileName
    tail --lines=1000 /var/log/tomte/tomte.log >> $logFileName
    printf "\n\n\n" >> $logFileName

else
    printf "%s\n" "Tomte Log konnte nicht gefunden werden." >> $logFileName
    printf "%s\n" "Moeglicherweise ist Tomte nicht installiert." >> $logFileName
    printf "\n\n\n" >> $logFileName

fi

printf "%s\n\n" "/var/log/syslog" >> $logFileName
tail --lines=1000 /var/log/syslog >> $logFileName

printf "\n\n\n%s\n\n" "journalctl --system -e" >> $logFileName
journalctl --system -e >> $logFileName

printf "\n\n\n%s\n\n" "/var/log/boot.log" >> $logFileName
tail --lines=1000 /var/log/boot.log >> $logFileName

printf "\n\n\n\n\n" >> $logFileName

printf "%s\n\n" "/var/log/Xorg.0.log" >> $logFileName
if [ $(wc --lines /var/log/Xorg.0.log | cut --delimiter=" " --fields=1) -le 2500 ]; then
    cat /var/log/Xorg.0.log >> $logFileName
else
    head --lines=1250 /var/log/Xorg.0.log >> $logFileName
    echo [...] >> $logFileName
    tail --lines=1250 /var/log/Xorg.0.log >> $logFileName
fi

printf "\n\n\n%s\n\n" "dmesg" >> $logFileName
dmesg >> $logFileName

printf "\n\n\n%s\n\n" "systemctl status systemd-modules-load.service" >> $logFileName
systemctl status systemd-modules-load.service >> $logFileName


##### $lspciFileName Section

printf "%s\n\n" "lspci -vvnn" >> $lspciFileName
lspci -vvnn >> $lspciFileName


##### $modprobeFileName Section

printf "%s\n\n" "/etc/modprobe.d/" >> $modprobeFileName
ls /etc/modprobe.d/ >> $modprobeFileName

printf "\n\n\n%s" "/etc/modprobe.d/ files" >> $modprobeFileName
for f in /etc/modprobe.d/*; do
    printf "\n\n\n=== %s ===\n\n" "$f" >> $modprobeFileName
    cat "$f" >> $modprobeFileName
done


##### $networkFileName Section

printf "\n\n\n%s\n\n" "lspci -nnk | grep -E -A3 -i "Ethernet|Network"" >> $networkFileName
lspci -nnk | grep -E -A3 -i "Ethernet|Network" >> $networkFileName

printf "\n\n\n%s\n\n" "ip addr show" >> $networkFileName
ip addr show >> $networkFileName

printf "\n\n\n%s\n\n" "ip route show" >> $networkFileName
ip route show >> $networkFileName

printf "\n\n\n%s\n\n" "rfkill list" >> $networkFileName
rfkill list >> $networkFileName

printf "\n\n\n%s\n\n"iwconfig" >> $networkFileName
iwconfig >> $networkFileName

printf "\n\n\n%s\n\n" "mmcli" >> $networkFileName
mmcli -m 0 | grep -v -e "imei:*" -e "equipment id:*" >> $networkFileName

##### $normalpackagesFileName Section

printf "\n\n\n" >> $normalpackagesFileName

# TUXEDO_OS
if [ "$(. /etc/os-release; echo $NAME)" = "TUXEDO OS" ]; then

    printf "%s\n\n" "sources.list" >> $normalpackagesFileName
    cat /etc/apt/sources.list >> $normalpackagesFileName

    printf "\n\n\n%s\n\n" "/etc/apt/sources.list.d" >> $normalpackagesFileName
    ls /etc/apt/sources.list.d >> $normalpackagesFileName

    printf "\n\n\n%s" "/etc/apt/sources.list.d ppa" >> $normalpackagesFileName
    for f in /etc/apt/sources.list.d/*; do
        printf "\n\n\n=== %s ===\n\n" "$f"  >> $normalpackagesFileName
        cat "$f"  >> $normalpackagesFileName
    done

    printf "\n\n\n%s\n\n" "dpkg -l" >> $normalpackagesFileName
    dpkg -l >> $normalpackagesFileName

    printf "\n\n\n%s\n\n" "dpkg -l | grep tuxedo" >> $normalpackagesFileName
    dpkg -l|grep tuxedo >> $normalpackagesFileName

    printf "\n\n\n%s\n\n" "dpkg -l | grep nvidia" >> $normalpackagesFileName
    dpkg -l|grep nvidia >> $normalpackagesFileName

    printf "\n\n\n%s\n\n" "/var/log/apt/history.log" >> $normalpackagesFileName
    cat /var/log/apt/history.log >> $normalpackagesFileName

# Ubuntu
elif [ "$(. /etc/os-release; echo $NAME)" = "Ubuntu" ]; then

    printf "%s\n\n" "sources.list" >> $normalpackagesFileName
    cat /etc/apt/sources.list >> $normalpackagesFileName

    printf "\n\n\n%s\n\n" "/etc/apt/sources.list.d" >> $normalpackagesFileName
    ls /etc/apt/sources.list.d >> $normalpackagesFileName

    printf "\n\n\n%s" "/etc/apt/sources.list.d ppa" >> $normalpackagesFileName
    for f in /etc/apt/sources.list.d/*; do
        printf "\n\n\n=== %s ===\n\n" "$f"  >> $normalpackagesFileName
        cat "$f"  >> $normalpackagesFileName
    done

    printf "\n\n\n%s\n\n" "dpkg -l" >> $normalpackagesFileName
    dpkg -l >> $normalpackagesFileName

    printf "\n\n\n%s\n\n" "dpkg -l | grep tuxedo" >> $normalpackagesFileName
    dpkg -l|grep tuxedo >> $normalpackagesFileName

    printf "\n\n\n%s\n\n" "dpkg -l | grep nvidia" >> $normalpackagesFileName
    dpkg -l|grep nvidia >> $normalpackagesFileName

    printf "\n\n\n%s\n\n" "/var/log/apt/history.log" >> $normalpackagesFileName
    cat /var/log/apt/history.log >> $normalpackagesFileName

# elementary OS
elif [ "$(. /etc/os-release; echo $NAME)" = "elementary OS" ]; then

    printf "%s\n\n" "sources.list" >> $normalpackagesFileName
    cat /etc/apt/sources.list >> $normalpackagesFileName

    printf "\n\n\n%s\n\n" "/etc/apt/sources.list.d" >> $normalpackagesFileName
    ls /etc/apt/sources.list.d >> $normalpackagesFileName

    printf "\n\n\n%s" "/etc/apt/sources.list.d ppa" >> $normalpackagesFileName
    for f in /etc/apt/sources.list.d/*; do
        printf "\n\n\n=== %s ===\n\n" "$f"  >> $normalpackagesFileName
        cat "$f"  >> $normalpackagesFileName
    done

    printf "\n\n\n%s\n\n" "dpkg -l" >> $normalpackagesFileName
    dpkg -l >> $normalpackagesFileName

    printf "\n\n\n%s\n\n" "dpkg -l | grep tuxedo" >> $normalpackagesFileName
    dpkg -l|grep tuxedo >> $normalpackagesFileName

    printf "\n\n\n%s\n\n" "dpkg -l | grep nvidia" >> $normalpackagesFileName
    dpkg -l|grep nvidia >> $normalpackagesFileName

    printf "\n\n\n%s\n\n" "/var/log/apt/history.log" >> $normalpackagesFileName
    cat /var/log/apt/history.log >> $normalpackagesFileName

# KDE neon
elif [ "$(. /etc/os-release; echo $NAME)" = "KDE neon" ]; then

    printf "%s\n\n" "sources.list" >> $normalpackagesFileName
    cat /etc/apt/sources.list >> $normalpackagesFileName

    printf "\n\n\n%s\n\n" "/etc/apt/sources.list.d" >> $normalpackagesFileName
    ls /etc/apt/sources.list.d >> $normalpackagesFileName

    printf "\n\n\n%s" "/etc/apt/sources.list.d ppa" >> $normalpackagesFileName
    for f in /etc/apt/sources.list.d/*; do
        printf "\n\n\n=== %s ===\n\n" "$f"  >> $normalpackagesFileName
        cat "$f"  >> $normalpackagesFileName
    done

    printf "\n\n\n%s\n\n" "dpkg -l" >> $normalpackagesFileName
    dpkg -l >> $normalpackagesFileName

    printf "\n\n\n%s\n\n" "dpkg -l | grep tuxedo" >> $normalpackagesFileName
    dpkg -l|grep tuxedo >> $normalpackagesFileName

    printf "\n\n\n%s\n\n" "dpkg -l | grep nvidia" >> $normalpackagesFileName
    dpkg -l|grep nvidia >> $normalpackagesFileName

    printf "\n\n\n%s\n\n" "/var/log/apt/history.log" >> $normalpackagesFileName
    cat /var/log/apt/history.log >> $normalpackagesFileName

# Linux Mint
elif [ "$(. /etc/os-release; echo $NAME)" = "Linux Mint" ]; then

    printf "%s\n\n" "sources.list" >> $normalpackagesFileName
    cat /etc/apt/sources.list >> $normalpackagesFileName

    printf "\n\n\n%s\n\n" "/etc/apt/sources.list.d" >> $normalpackagesFileName
    ls /etc/apt/sources.list.d >> $normalpackagesFileName

    printf "\n\n\n%s" "/etc/apt/sources.list.d ppa" >> $normalpackagesFileName
    for f in /etc/apt/sources.list.d/*; do
        printf "\n\n\n=== %s ===\n\n" "$f"  >> $normalpackagesFileName
        cat "$f"  >> $normalpackagesFileName
    done

    printf "\n\n\n%s\n\n" "dpkg -l" >> $normalpackagesFileName
    dpkg -l >> $normalpackagesFileName

    printf "\n\n\n%s\n\n" "dpkg -l | grep tuxedo" >> $normalpackagesFileName
    dpkg -l|grep tuxedo >> $normalpackagesFileName

    printf "\n\n\n%s\n\n" "dpkg -l | grep nvidia" >> $normalpackagesFileName
    dpkg -l|grep nvidia >> $normalpackagesFileName

    printf "\n\n\n%s\n\n" "/var/log/apt/history.log" >> $normalpackagesFileName
    cat /var/log/apt/history.log >> $normalpackagesFileName


# openSUSE
elif [ "$(. /etc/os-release; echo $NAME)" = "openSUSE Leap" ]; then

    printf "%s\n\n" "/etc/zypp/repos.d" >> $normalpackagesFileName
    ls -al /etc/zypp/repos.d/ >> $normalpackagesFileName

    printf "\n\n\n%s" "zypper sources lists" >> $normalpackagesFileName
    for f in /etc/zypp/repos.d/*; do
        printf "\n\n\n=== %s ===\n\n" "$f" >> $normalpackagesFileName
        cat "$f" >> $normalpackagesFileName
    done

    printf "\n\n\n%s\n\n" "rpm -qa" >> $normalpackagesFileName
    rpm -qa >> $normalpackagesFileName

    printf "\n\n\n%s\n\n" "rpm -qa | grep tuxedo" >> $normalpackagesFileName
    rpm -qa | grep tuxedo >> $normalpackagesFileName

    printf "\n\n\n%s\n\n" "rpm -qa | grep nvidia" >> $normalpackagesFileName
    rpm -qa | grep nvidia >> $normalpackagesFileName

    printf "\n\n\n%s\n\n" "/var/log/zypp/history" >> $normalpackagesFileName
    cat /var/log/zypp/history >> $normalpackagesFileName

# Fedora
elif [ "$(. /etc/os-release; echo $NAME)" = "Fedora Linux" ]; then

    printf "%s\n\n" "/etc/yum.repos.d" >> $normalpackagesFileName
    ls -al /etc/yum.repos.d/ >> $normalpackagesFileName

    printf "\n\n\n%s" "dnf sources lists" >> $normalpackagesFileName
    for f in /etc/yum.repos.d/*; do
        printf "\n\n\n=== %s ===\n\n" "$f" >> $normalpackagesFileName
        cat "$f" >> $normalpackagesFileName
    done

    printf "\n\n\n%s\n\n" "rpm -qa" >> $normalpackagesFileName
    rpm -qa >> $normalpackagesFileName

    printf "\n\n\n%s\n\n" "rpm -qa | grep tuxedo" >> $normalpackagesFileName
    rpm -qa | grep tuxedo >> $normalpackagesFileName

    printf "\n\n\n%s\n\n" "rpm -qa | grep nvidia" >> $normalpackagesFileName
    rpm -qa | grep nvidia >> $normalpackagesFileName

    printf "\n\n\n%s\n\n""/var/log/dnf.log" >> $normalpackagesFileName
    cat /var/log/dnf.log >> $normalpackagesFileName

    printf "\n\n\n%s\n\n" "/var/log/dnf.librepo.log" >> $normalpackagesFileName
    cat /var/log/dnf.librepo.log >> $normalpackagesFileName

    printf "\n\n\n%s\n\n" "/var/log/dnf.rpm.log" >> $normalpackagesFileName
    cat /var/log/dnf.rpm.log >> $normalpackagesFileName

# Manjaro
elif [ "$(. /etc/os-release; echo $NAME)" = "Manjaro Linux" ]; then

    printf "%s\n\n" "cat /etc/pacman.conf" >> $normalpackagesFileName
    cat /etc/pacman.conf >> $normalpackagesFileName

    printf "\n\n\n%s\n\n" "pacman -Qqe" >> $normalpackagesFileName
    pacman -Qqe >> $normalpackagesFileName

    printf "\n\n\n%s\n\n" "pacman -Qqe | grep tuxedo" >> $normalpackagesFileName
    pacman -Qqe | grep tuxedo >> $normalpackagesFileName

    printf "\n\n\n%s\n\n" "pacman Repos" >> $normalpackagesFileName
    cat /etc/pacman.conf | grep -E 'core|extra|community|multilib' >> $normalpackagesFileName

    printf "\n\n\n%s\n\n" "pacman logs"
    cat /var/log/pacman.log >> $normalpackagesFileName
    printf "\n\n\n" >> $normalpackagesFileName

else
    printf "%s\n" "Nicht unterstuetze Distribution! Ueberspringe..."
    printf "%s\n\n\n" "Unsupported Distribution! Skipping..."
fi


##### $securebootFileName section

printf "%s\n\n" "mokutil --sb-state" >> $securebootFileName
mokutil --sb-state >> $securebootFileName

printf "\n\n\n%s\n\n" "mokutil --pk" >> $securebootFileName
mokutil --pk >> $securebootFileName

printf "\n\n\n%s\n\n" "mokutil --kek" >> $securebootFileName
mokutil --kek >> $securebootFileName

printf "\n\n\n%s\n\n" "mokutil --db" >> $securebootFileName
mokutil --db >> $securebootFileName

printf "\n\n\n%s\n\n" "mokutil --dbx" >> $securebootFileName
mokutil --dbx >> $securebootFileName

printf "\n\n\n%s\n\n" "mokutil --list-enrolled" >> $securebootFileName
mokutil --list-enrolled >> $securebootFileName

printf "\n\n\n%s\n\n" "mokutil --list-new" >> $securebootFileName
mokutil --list-new >> $securebootFileName

printf "\n\n\n%s\n\n" "mokutil --list-delete" >> $securebootFileName
mokutil --list-delete >> $securebootFileName

printf "\n\n\n%s\n\n" "mokutil --mokx" >> $securebootFileName
mokutil --mokx >> $securebootFileName


##### $snappackagesFileName

printf "%s\n\n" "snap list" >> $snappackagesFileName
snap list >> $snappackagesFileName


##### $tccFileName Section

printf "%s\n\n" "/etc/tcc/settings" >> $tccFileName
cat /etc/tcc/settings | jq >> $tccFileName

printf "\n\n\n%s\n\n" "/etc/tcc/profiles" >> $tccFileName
cat /etc/tcc/profiles | jq >> $tccFileName

printf "\n\n\n%s\n\n" "systemctl is-active tccd.service" >> $tccFileName
systemctl is-active tccd.service >> $tccFileName


##### $tomteFileName section

printf "%s\n\n" "tuxedo-tomte list" >> $tomteFileName
tuxedo-tomte list >> $tomteFileName

printf "\n\n\n" >> $tomteFileName

if [ -f /etc/tomte/AUTOMATIC ]; then
    printf "%s\n" "Tomte wird in den vorgesehenen Standardeinstellungen verwendet" >> $tomteFileName
    printf "\n\n\n" >> $tomteFileName
elif [ -f /etc/tomte/DONT_CONFIGURE ]; then
    printf "%s\n" "Tomte ist so konfiguriert, dass nur die als "notwendig" (prerequisite) markierten Module konfiguriert werden" >> $tomteFileName
    printf "\n\n\n" >> $tomteFileName
elif [ -f /etc/tomte/UPDATES_ONLY ]; then
    printf "%s\n" "Tomte ist so konfiguriert, dass nur Aktualisierungen ueber Tomte verarbeitet werden" >> $tomteFileName
    printf "\n\n\n" >> $tomteFileName
else
    printf "%s\n" "Tomte wird in den Standardeinstellungen verwendet" >> $tomteFileName
    printf "\n\n\n" >> $tomteFileName
fi

if [ -d /var/log/tuxedo-tomte-light/tuxedo-tomte-light ]; then
    printf "%s\n" "tuxedo-tomte-light.log" >> $tomteFileName
    cat /var/log/tuxedo-tomte-light/tuxedo-tomte-light/tuxedo-tomte-light.log >> $tomteFileName
    
    printf "\n\n\n%s\n\n" "tuxedo-tomte-light-packages.log" >> $tomteFileName
    cat /var/log/tuxedo-tomte-light/tuxedo-tomte-light/tuxedo-tomte-light-packages.log >> $tomteFileName
    
    printf "\n\n\n%s\n\n" "tuxedo-tomte-light-startups.log" >> $tomteFileName
    cat /var/log/tuxedo-tomte-light/tuxedo-tomte-light/tuxedo-tomte-light-startups.log >> $tomteFileName
    printf "\n\n\n" >> $tomteFileName
else
    printf "%s\n" "Tomte Light ist nicht installiert" >> $tomteFileName
    printf "\n\n\n" >> $tomteFileName
fi


##### $udevFileName Section

printf "%s\n\n" "/etc/udev/rules.d/" >> $udevFileName
ls /etc/udev/rules.d/ >> $udevFileName

printf "\n\n\n%s" "/etc/udev/rules.d/ files" >> $udevFileName
for f in /etc/udev/rules.d/*; do
    printf "\n\n\n=== %s ===\n\n" "$f" >> $udevFileName
    cat "$f" >> $udevFileName
done

printf "\n\n\n%s\n\n" "/lib/udev/rules.d/" >> $udevFileName
ls /lib/udev/rules.d/ >> $udevFileName

printf "\n\n\n%s" "/lib/udev/rules.d/ files" >> $udevFileName
for f in /lib/udev/rules.d/*; do
    printf "\n\n\n=== %s ===\n\n" "$f" >> $udevFileName
    cat "$f" >> $udevFileName
done


### Rename files
mv $audioFileName audio-$ticketnumber.txt
mv $batteryFileName battery-$ticketnumber.txt
mv $boardFileName boardinfo-$ticketnumber.txt
mv $displayFileName display-$ticketnumber.txt
mv $failogFilename failog-$ticketnumber.txt
mv $firmwareFileName firmware-$ticketnumber.txt
mv $flatpakpackagesFileName packages-flatpak-$ticketnumber.txt
mv $infoFileName systeminfos-$ticketnumber.txt
mv $logFileName log-$ticketnumber.txt
mv $lspciFileName lspci-$ticketnumber.txt
mv $modprobeFileName modprobe-$ticketnumber.txt
mv $networkFileName network-$ticketnumber.txt
mv $normalpackagesFileName packages-normal-$ticketnumber.txt
mv $securebootFileName secureboot-$ticketnumber.txt
mv $snappackagesFileName packages-snap-$ticketnumber.txt
mv $tccFileName tcc-$ticketnumber.txt
mv $tomteFileName tomte-$ticketnumber.txt
mv $udevFileName udev-$ticketnumber.txt

zip -9 systeminfos-$ticketnumber.zip *-$ticketnumber.txt


### Check Internet connection
printf "Ueberpruefe Internetverbindung... / Checking Internet connection... \n"
scriptisonline=$(curl -o /dev/null -I -L -s -w "%{http_code}" https://www.tuxedocomputers.com)
if [ $scriptisonline -eq 200 ]; then
    printf "\e[32mOnline\e[0m\n"
    printf "\e[37m\e[0m\n"
else
    printf "\e[31mOffline! Um die Ergebnisse uebermitteln zu koennen ist eine Internetverbindung erforderlich! / Offline! An Internet connection is required to transmit the results! \e[1m\n"
    printf "\e[37m\e[0m\n"
    rm systeminfos-$ticketnumber.zip *-$ticketnumber.txt
    exit 1
fi

curl -k -F "file=@systeminfos-$ticketnumber.zip" $serverURI?ticketnumber=$ticketnumber
rm systeminfos-$ticketnumber.zip *-$ticketnumber.txt

if [ "$(. /etc/default/locale; echo $LANG)" = "de_DE.UTF-8" ]; then
    printf "\n%s\n" "Systeminfos erfolgreich uebermittelt."
    printf "%s\n" "Wir werden die eingesendeten Systeminfos nun auswerten und uns bei Ihnen melden."
    printf "%s\n" "Bitte haben Sie etwas Geduld."
else
    printf "\n%s\n" "Systeminformations successfully transferred."
    printf "%s\n" "We will now evaluate the submitted system information and get back to you."
    printf "%s\n" "Please be patient."
fi

unset LC_ALL
unset LANG
unset LANGUAGE

exit 0;
