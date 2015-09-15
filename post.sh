#!/bin/bash
#startH=$(date '+%-H')
#startM=$(date '+%-M')
#startS=$(date '+%-S')
source /etc/profile
env-update

#Download and build kernel. Uses included kernel config file from git.
printf "\n\n[1.] Building kernel\n"
printf "=======================================================================\n"

#Build GCC 4.9
#=======================
#printf "=sys-devel/gcc-4.9.3 ~amd64\n" >> /etc/portage/package.accept_keywords
#emerge =sys-devel/gcc-4.9.3
#gcc-config 2


printf "=sys-kernel/gentoo-sources-4.2.0-r1 ~amd64\n" >> /etc/portage/package.accept_keywords
emerge =sys-kernel/gentoo-sources-4.2.0-r1 linux-firmware cpuinfo2cpuflags
cpuinfo2cpuflags-x86 >> /etc/portage/make.conf

cd /usr/src/linux
cp /.config .
cpucores=$(grep -c ^processor /proc/cpuinfo)
make oldconfig
make -j${cpucores}
make modules_install
make install

#Selects vanilla systemd profile. Builds systemd, bootloader, some net tools and a world update.
printf "\n\n[2.] Updating world and installing various network utilities\n"
printf "=======================================================================\n"
printf "sys-fs/cryptsetup -gcrypt\n" >> /etc/portage/package.use/cryptsetup
eselect profile set 12
emerge -uDN @world grub wpa_supplicant dhcpcd vixie-cron cryptsetup sudo wireless-tools
mv /wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf
mv /buildScripts/setTimeZone /etc/cron.hourly/
sed -i "/s/# %wheel/%wheel" /etc/sudoers
#Enables ssh, dhcpcd, and ntp.
Systemctl enable sshd
systemctl enable dhcpcd
systemctl enable vixie-cron

grub2-install --target=i386-pc /dev/sda
grub2-mkconfig -o /boot/grub/grub.cfg


printf "\n\n[3.] Building xorg-server\n"
printf "=======================================================================\n"
. /buildScripts/xorg.sh
emerge lxdm
. /buildScripts/buildLXQt.sh
emerge --sync
systemctl enable lxdm
passwd

printf "Enter username for new user\n"
read username
useradd -G wheel $username
printf "Enter passwd for new user\m"
passwd $username
mkdir /home/$username
chown $username:$username /home/$username


#printf "[4.] Building Cinnamon\n"
#printf "=======================================================================\n"
#. /buildScripts/buildCinnamon.sh
printf "=======================================================================\n"
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
