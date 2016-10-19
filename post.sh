#!/bin/bash
source /etc/profile
env-update

#Download and build kernel. Uses included kernel config file from git.
printf "\n\n[1.] Building kernel\n"
printf "=======================================================================\n"


emerge gentoo-sources linux-firmware cpuid2cpuflags
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
eselect profile set 5
emerge -uDN @world grub wpa_supplicant dhcpcd sudo wireless-tools cryptsetup
mv /wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf
sed -i "s/# %sudo/%sudo/" /etc/sudoers
#Enables ssh, dhcpcd, and ntp.
systemctl enable sshd
systemctl enable dhcpcd

grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

emerge --sync

eselect profile set 5
echo "gnome-base/gnome-control-center networkmanager" >> /etc/portage/package.use
emerge -uDN @world gdm
systemctl enable gdm
passwd

printf "Enter username for new user\n"
read username
useradd -G sudo $username
printf "Enter passwd for new user\m"
passwd $username
mkdir /home/$username
chown $username:$username /home/$username

printf "\n\n\nGentoo Linux has been installed\n"
printf "wpa_supplicant.conf in /etc/wpa_supplicant may need to be edited if it\n"
printf "wasn't modified prior to installation. dhcpcd may need to be run on first\n"
printf "reboot if ip is not leased on start\n"
