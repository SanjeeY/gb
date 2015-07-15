#!/bin/bash
source /etc/profile
env-update

#*Remove some accidentally created files (easier than debugging for now)
rm portage*
mkdir /etc/wpa_supplicant
mv wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf

#Add CPU processor flags for builds such as ffmpeg
emerge --sync
emerge cpuinfo2cpuflags
cpuinfo2cpuflags-x86 >> /etc/portage/make.conf
printf "\n" >> /etc/portage/make.conf

#Build and switch to clang. Also build some packages with gcc that break with clang.
printf "=sys-devel/clang ~amd64\n" >> /etc/portage/package.accept_keywords
printf "=sys-devel/llvm ~amd64\n" >> /etc/portage/package.accept_keywords
printf "sys-kernel/ck-sources ~amd64\n" >> /etc/portage/package.accept_keywords
printf "sys-devel/llvm clang\n" >> /etc/portage/package.use/llvm
printf "media-libs/harfbuzz icu\n" >> /etc/portage/package.use/llvm
printf "sys-apps/systemd gudev\n" >> /etc/portage/package.use/llvm
emerge clang glibc guile autogen ntp
export CC=clang
export CXX=clang++

#Download and build kernel. Uses included kernel config file from git.
emerge ck-sources linux-firmware
cd /usr/src/linux
mv /.config .
cpucores=$(grep -c ^processor /proc/cpuinfo)
make -j${cpucores}
make modules_install
make install

#Selects vanilla systemd profile. Builds systemd, bootloader, some net tools and a world update.
eselect profile set 12
emerge -uDN @world  wpa_supplicant dhcpcd wireless-tools grub
grub2-install --target=i386-pc /dev/sda
grub2-mkconfig -o /boot/grub/grub.cfg

#Enables ssh, dhcpcd, and ntp.
systemctl enable sshd
systemctl enable dhcpcd
systemctl enable ntpd

#Update config files
etc-update --automode -3

#Root password prompt
printf "\nPlease enter root password:\n"
passwd

#WPA_Supplicant configuration
printf "\nWould you like to set up wifi essid/key(y/n)?"
read wifiBool
if [ "$wifiBool" == "y" ]
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
if [ "$xorg" == "y" ]
then
  ./buildScripts/xorg.sh
  printf "\nDo you want to install a desktop environment?"
  read deskBool
  if[ "$deskBool" == "y" ]
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
