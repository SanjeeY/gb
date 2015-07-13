#!/bin/bash
source /etc/profile
env-update
emerge --sync
emerge cpuinfo2cpuflags
cpuinfo2cpuflags-x86 >> /etc/portage/make.conf
rm stage3*
eselect profile set 12
echo "=sys-devel/clang-3.6.1-r100 ~amd64" >> /etc/portage/package.accept_keywords
echo "=sys-devel/llvm-3.6.1 ~amd64" >> /etc/portage/package.accept_keywords
echo "sys-devel/llvm clang" >> /etc/portage/package.use/llvm
emerge =sys-devel/clang-3.6.1-r100 glibc guile autogen ntp
export CC=clang
export CXX=clang++
emerge gentoo-sources linux-firmware
cd /usr/src/linux
mv /.config .
cpucores=$(grep -c ^processor /proc/cpuinfo)
make -j${cpucores}
make modules_install
make install
emerge -uDN @world  wpa_supplicant dhcpcd wireless-tools grub
sed -i -e 's/BOOT/sda1/g' /etc/fstab
sed -i -e 's/SWAP/sda2/g' /etc/fstab
sed -i -e 's/ROOT/sda3/g' /etc/fstab
export CC=gcc
export CXX=g++
grub2-install --target=i386-pc /dev/sda
grub2-mkconfig -o /boot/grub/grub.cfg
systemctl enable sshd
systemctl enable dhcpcd
systemctl enable ntpd
passwd
