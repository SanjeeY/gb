#!/bin/bash
source /etc/profile
env-update

#Add CPU processor flags for builds such as ffmpeg
emerge cpuinfo2cpuflags
cpuinfo2cpuflags-x86 >> /etc/portage/make.conf
printf "\n" >> /etc/portage/make.conf

#Build and switch to clang. Also build some packages with gcc that break with clang.
printf "=sys-devel/clang-3.6.1-r100 ~amd64\n" >> /etc/portage/package.accept_keywords
printf "=sys-devel/llvm-3.6.1 ~amd64\n" >> /etc/portage/package.accept_keywords
printf "sys-devel/llvm clang\n" >> /etc/portage/package.use/llvm
emerge =sys-devel/clang-3.6.1-r100 glibc guile autogen ntp
export CC=clang
export CXX=clang++

#Download and build kernel. Uses included kernel config file from git.
emerge gentoo-sources linux-firmware
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

#Root password prompt
printf "\nPlease enter root password:\n"
passwd

#WPA_Supplicant configuration
printf "\nWould you like to set up wifi essid/key(y/n)?"
read wifiBool
if [ "$wifiBool" == "y" ];
then
  wifiSetup=0
  while[ "$wifiSetup" == "0" ]
  do
    printf "\nEnter wifi ssid:"
    read wifiSSID
    printf "\nEnter wifi key:"
    read wifiKEY
    printf "\nESSID: ${wifiSSID}  Key: $wifiKEY"
    printf "\nIs this correct?"
    read wifiConfirm
    if [ "$wifiConfirm" == "y" ]
      wifiSetup=1
    fi
  done
  sed -i -e 's/SSIDVAR/$wifiSSID/g' /wpa_supplicant.conf
  sed -i -e 's/KEYVAR/$wifiKEY/g' /wpa_supplicant.conf
  mv /wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf
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
