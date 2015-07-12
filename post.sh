#!/bin/bash
source /etc/profile
env-update
emerge --sync
rm stage3*
eselect profile set 12
echo "=sys-devel/clang-9999-r100 **" >> /etc/portage/package.accept_keywords
echo "=sys-devel/llvm-9999 **" >> /etc/portage/package.accept_keywords
echo "sys-devel/llvm clang" >> /etc/portage/package.use/llvm
emerge =sys-devel/clang-9999
export CC=clang
export CXX=clang++
emerge -uDN @world gentoo-sources linux-firmware wpa_supplicant dhcpcd wireless-tools grub
cd /usr/src/linux
mv /.config .
cpucores=$(grep -c ^processor /proc/cpuinfo)
make -j$(cpucores)
make modules_install
make install
export CC=gcc
export CXX=g++
grub2-install --target=i386-pc /dev/sda
grub2-mkconfig -o /boot/grub/grub.cfg
systemctl enable gdm
systemctl enable sshd
