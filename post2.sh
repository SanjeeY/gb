#1/bin/bash
#Selects vanilla systemd profile. Builds systemd, bootloader, some net tools and a world update.
eselect profile set 15
emerge -1 checkpolicy policycoreutils
FEATURES="-selinux" emerge -1 selinux-base
FEATURES="-selinux" emerge selinux-base-policy
emerge -uDN @world ntp 

#Enables dhcpcd, and ntp.
rc-update add dhcpcd default
rc-update add ntpd default

#Update config files
etc-update --automode -3

#Root password prompt
printf "\nPlease enter root password:\n"
passwd

#WPA_Supplicant configuration
printf "\nWould you like to set up wifi essid/key(y/n)?"
read wifiBool
if [ "$wifiBool" == "y" ];
then
  printf "\nEnter wifi ssid:"
  read wifiSSID
  printf "\nEnter wifi key:"
  read wifiKEY
  printf "\nESSID: ${wifiSSID}  Key: $wifiKEY"
  printf "\nIf incorrect, it can be manually edited at /etc/wpa_supplicant/wpa_supplicant.conf"
  sed -i -e 's/SSIDVAR/$wifiSSID/g' /etc/wpa_supplicant/wpa_supplicant.conf
  sed -i -e 's/KEYVAR/$wifiKEY/g' /etc/wpa_supplicant/wpa_supplicant.conf
fi

#Xorg-server + desktop environment build scripts
printf "\nDo you want to install xorg-server?"
read xorg
if [ "$xorg" == "y" ];
then
  ./buildScripts/xorg.sh
  printf "\nDo you want to install a desktop environment?"
  read deskBool
  if[ "$deskBool" == "y" ];
  then
    printf "\nEnter the number of the desktop environment you wish to install:"
    printf "\n[1] - Cinnamon"
    read deskEnv
    case $deskEnv in
      [1] )
        ./buildScripts/buildCinnamon.sh ;;
    esac
  fi
fi
