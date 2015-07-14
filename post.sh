#!/bin/bash
source /etc/profile
env-update

#*Remove some accidentally created files (easier than debugging for now)
rm index*
rm gentoo*
rm portage*
mv wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf

#Add CPU processor flags for builds such as ffmpeg
emerge cpuinfo2cpuflags
cpuinfo2cpuflags-x86 >> /etc/portage/make.conf
printf "\n" >> /etc/portage/make.conf

#Enable Linux 4 kernel
printf "sys-kernel/hardened-sources ~amd64\n" >> /etc/portage/package.accept_keywords
printf "sys-fs/cryptsetup -gcrypt\n" >> /etc/portage/package.use/llvm

#Download and build kernel. Uses included kernel config file from git.
emerge =sys-kernel/hardened-sources-4.0.8 linux-firmware genkernel-next
cd /usr/src/linux
mv /.config .
genkernel --luks all

#Selects vanilla systemd profile. Builds systemd, bootloader, some net tools and a world update.
eselect profile set 15
emerge -uDN @world  wpa_supplicant dhcpcd wireless-tools grub ntp cryptsetup
grub2-install --target=i386-pc /dev/sda
grub2-mkconfig -o /boot/grub/grub.cfg

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
