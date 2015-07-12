#!/bin/bash
source /etc/profile
env-update
wget http://gentoo.mirrors.tds.net/gentoo/snapshots/portage-latest.tar.xz
tar -xvpf portage-latest.tar.bz2 -C /usr
emerge --sync
rm portage-latest.tar.bz2
rm stage3*
eselect profile set 12
emerge -uvDN @world gentoo-sources linux-firmware wpa_supplicant dhpcd wireless_tools grub
cd /usr/src/linux
mv /.config .
cpucores=grep -c ^processor /proc/cpuinfo
make -j$(cpucores)
make install
grub2-install --target=i386-pc /dev/sda
grub2-mkconfig -o /boot/grub/grub.cfg
systemctl enable gdm
systemctl enable sshd
