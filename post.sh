#!/bin/bash
#startH=$(date '+%-H')
#startM=$(date '+%-M')
#startS=$(date '+%-S')
{
source /etc/profile
env-update

mkdir /etc/wpa_supplicant
mv wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf
ln -s /usr/share/zoneinfo/US/Eastern /etc/localtime
#sed -i s/#en/en/g /etc/locale.gen
#locale-gen
#eselect locale set 4

#Download and build kernel. Uses included kernel config file from git.
printf "[1.] Building kernel\n"
printf "=======================================================================\n"

emerge gentoo-sources linux-firmware
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
eselect profile set 12
emerge -uDN @world ntp grub wpa_supplicant dhcpcd wireless-tools p7zip dev-tcltk/expect

#Enables ssh, dhcpcd, and ntp.
systemctl enable sshd
systemctl enable dhcpcd
systemctl enable ntpd

#Update config files
etc-update --automode -3


emerge --depclean
grub2-install --target=i386-pc /dev/sda
grub2-mkconfig -o /boot/grub/grub.cfg
mkdir /backup
passwd


printf "[3.] Building xorg-server\n"
printf "=======================================================================\n"
. /buildScripts/xorg.sh

printf "[4.] Building Cinnamon\n"
printf "=======================================================================\n"
. /buildScripts/buildCinnamon.sh

exit
} 2>&1 | tee -a post.log

#while IFS= read -r line;
#do
#newH=$(date '+%-H')
#newM=$(date '+%-M')
#newS=$(date '+%-S')
#fH=$((newH-startH))
#fM=$((newM-startM))
#fS=$((newS-startS))
#done
