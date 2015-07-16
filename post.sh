#!/bin/bash
source /etc/profile
env-update

mkdir /etc/wpa_supplicant
mv wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf


#Build and switch to clang. Also build some packages with gcc that break with clang.
printf "sys-devel/clang ~amd64\n" >> /etc/portage/package.accept_keywords
printf "sys-devel/llvm ~amd64\n" >> /etc/portage/package.accept_keywords
printf "sys-kernel/gentoo-sources ~amd64\n" >> /etc/portage/package.accept_keywords
printf "sys-devel/llvm clang\n" >> /etc/portage/package.use/llvm
printf "media-libs/harfbuzz icu\n" >> /etc/portage/package.use/llvm
printf "sys-apps/systemd gudev\n" >> /etc/portage/package.use/llvm
emerge clang glibc guile autogen ntp
export CC=clang
export CXX=clang++

#Download and build kernel. Uses included kernel config file from git.
emerge gentoo-sources linux-firmware
cd /usr/src/linux
mv /.config .
cpucores=$(grep -c ^processor /proc/cpuinfo)
make -j${cpucores}
#make modules
make modules_install
make install
#cp /usr/src/linux/arch/arm/boot/zImage /boot/kernel7.img

#Selects vanilla systemd profile. Builds systemd, bootloader, some net tools and a world update.
eselect profile set 12
emerge -uDN @world wpa_supplicant dhcpcd wireless-tools p7zip dev-perl/expect

#Enables ssh, dhcpcd, and ntp.
systemctl enable sshd
systemctl enable dhcpcd
systemctl enable ntpd

#Update config files
etc-update --automode -3

./buildScripts/xorg.sh
./buildScripts/buildCinnamon.sh

#Root password prompt
./setp.sh
mkdir /backup
XZ_OPT=-9 tar -cvpJf /backup/backup.tar.xz --directory=/ --exclude=proc --exclude=sys --exclude=dev/pts --exclude=backup .
exit
