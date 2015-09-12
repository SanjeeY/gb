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
printf "\n\n[1.] Building kernel\n"
printf "=======================================================================\n"
emerge git cpuinfo2cpuflags bc
cpuinfo2cpuflags-x86 >> /etc/portage/make.conf
cd /usr/src
git clone https://github.com/raspberrypi/linux.git
cd linux
cpucores=$(grep -c ^processor /proc/cpuinfo)
KERNEL=kernel7
make bcm2709_defconfig
make -j${cpucores}
make zImage modules dtbs
make modules_install
cp arch/arm/boot/dts/*.dtb /boot/
cp arch/arm/boot/dts/overlays/*.dtb* /boot/overlays/
cp arch/arm/boot/dts/overlays/README /boot/overlays/
scripts/mkknlimg arch/arm/boot/zImage /boot/$KERNEL.img
#cp /usr/src/linux/arch/arm/boot/zImage /boot/kernel7.img

#Selects vanilla systemd profile. Builds systemd, bootloader, some net tools and a world update.
printf "\n\n[2.] Updating world and installing various network utilities\n"
printf "=======================================================================\n"
printf "sys-fs/cryptsetup -gcrypt\n" >> /etc/portage/package.use/cryptsetup
eselect profile set 12
emerge -uDN @world ntp grub wpa_supplicant dhcpcd wireless-tools cryptsetup
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


#printf "\n\n[3.] Building xorg-server\n"
#printf "=======================================================================\n"
#. /buildScripts/xorg.sh
#emerge gdm gnome-terminal gnome
emerge --sync
#systemctl enable gdm
passwd

#printf "[4.] Building Cinnamon\n"
#printf "=======================================================================\n"
#. /buildScripts/buildCinnamon.sh

printf "\n\n\nGentoo Linux has been installed\n"
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
