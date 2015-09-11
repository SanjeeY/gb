#!/bin/bash
#startH=$(date '+%-H')
#startM=$(date '+%-M')
#startS=$(date '+%-S')
source /etc/profile
env-update

#ln -s /usr/share/zoneinfo/US/Eastern /etc/localtime
#sed -i s/#en/en/g /etc/locale.gen
#locale-gen
#eselect locale set 4

#Download and build kernel. Uses included kernel config file from git.
printf "[1.] Building kernel\n"
printf "=======================================================================\n"
emerge gentoo-sources linux-firmware cpuinfo2cpuflags
cpuinfo2cpuflags-x86 >> /etc/portage/make.conf
cd /usr/src/linux
cp /.config .
cpucores=$(grep -c ^processor /proc/cpuinfo)
make oldconfig
make -j${cpucores}
#make modules
make modules_install
make install
#cp /usr/src/linux/arch/arm/boot/zImage /boot/kernel7.img

#Selects vanilla systemd profile. Builds systemd, bootloader, some net tools and a world update.
printf "[2.] Updating world and installing various network utilities\n"
printf "=======================================================================\n"
printf "sys-fs/cryptsetup -gcrypt\n" >> /etc/portage/package.use/cryptsetup
eselect profile set 12
emerge -uDN @world ntp grub wpa_supplicant dhcpcd wireless-tools cryptsetup
sed -i 's/USE="/USE="cryptsetup /' /etc/portage/make.conf
emerge systemd
mv /wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf
#Enables ssh, dhcpcd, and ntp.
systemctl enable sshd
systemctl enable dhcpcd
systemctl enable ntpd
timedatectl set-timezone US/Eastern

#Update config files
etc-update --automode -3


emerge --depclean
grub2-install --target=i386-pc /dev/sda
grub2-mkconfig -o /boot/grub/grub.cfg


printf "[3.] Building xorg-server\n"
printf "=======================================================================\n"
. /buildScripts/xorg.sh

emerge --autounmask-write gdm
etc-update --automode -3
emerge gdm
emerge --sync
passwd

#printf "[4.] Building Cinnamon\n"
#printf "=======================================================================\n"
#. /buildScripts/buildCinnamon.sh

printf "Gentoo Linux has been installed\n"
printf "wpa_supplicant.conf in /etc/wpa_supplicant may need to be edited if it\n"
printf "wasn't modified prior to installation. dhcpcd may need to be run on first\n"
printf "reboot if ip is not leased on start\n"
#while IFS= read -r line;
#do
#newH=$(date '+%-H')
#newM=$(date '+%-M')
#newS=$(date '+%-S')
#fH=$((newH-startH))
#fM=$((newM-startM))
#fS=$((newS-startS))
#done
