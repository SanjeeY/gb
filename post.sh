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
printf "=sys-kernel/gentoo-sources-4.2.0-r1 ~amd64/n" >> /etc/portage/package.accept_keywords
emerge =sys-kernel/gentoo-sources-4.2.0-r1 linux-firmware cpuinfo2cpuflags
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
emerge -uDN @world ntp wpa_supplicant dhcpcd wireless-tools cryptsetup
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
emerge --sync

printf "[3.] Building xorg-server\n"
printf "=======================================================================\n"
. /buildScripts/xorg.sh

passwd
#printf "[4.] Building Cinnamon\n"
#printf "=======================================================================\n"
#. /buildScripts/buildCinnamon.sh

printf "Gentoo Linux has been installed\n"
printf "wpa_supplicant.conf in /etc/wpa_supplicant/ may need to be configured if it hasn't\n"
printf "been prior to installation.\n"
#while IFS= read -r line;
#do
#newH=$(date '+%-H')
#newM=$(date '+%-M')
#newS=$(date '+%-S')
#fH=$((newH-startH))
#fM=$((newM-startM))
#fS=$((newS-startS))
#done
