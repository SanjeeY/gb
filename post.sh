#!/bin/bash
source /etc/profile
env-update

#*Remove some accidentally created files (easier than debugging for now)
rm portage*
mkdir /etc/wpa_supplicant
mv wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf

#Sync portage tree
emerge --sync

#Build and switch to clang. Also build some packages with gcc that break with clang.
mkdir /etc/portage/package.use/
printf "sys-devel/clang ~arm\n" >> /etc/portage/package.accept_keywords
printf "sys-devel/llvm ~arm\n" >> /etc/portage/package.accept_keywords
printf "app-arch/p7zip ~arm\n" >> /etc/portage/package.accept_keywords
printf "sys-kernel/raspberrypi-sources **\n" >> /etc/portage/package.accept_keywords
printf "sys-kernel/raspberrypi-firmware ~arm\n" >> /etc/portage/package.accept_keywords
printf "sys-devel/llvm clang\n" >> /etc/portage/package.use/llvm
printf "dev-python/py -test\n" >> /etc/portage/package.use/llvm
printf "media-libs/harfbuzz icu\n" >> /etc/portage/package.use/llvm
printf "sys-apps/systemd gudev\n" >> /etc/portage/package.use/llvm
emerge clang glibc guile autogen ntp
export CC=clang
export CXX=clang++

#Download and build kernel. Uses included kernel config file from git.
emerge raspberrypi-sources raspberrypi-firmware
cd /usr/src/linux
mv /.config .
cpucores=$(grep -c ^processor /proc/cpuinfo)
make -j${cpucores}
make modules
#make modules_install
#make install
#cp /usr/src/linux/arch/arm/boot/zImage /boot/kernel7.img

#Selects vanilla systemd profile. Builds systemd, bootloader, some net tools and a world update.
eselect profile set 12
emerge -uDN @world wpa_supplicant dhcpcd wireless-tools p7zip

#Enables ssh, dhcpcd, and ntp.
systemctl enable sshd
systemctl enable dhcpcd
systemctl enable ntpd

#Update config files
etc-update --automode -3

#Root password prompt
printf "\nPlease enter root password:\n"
passwd
mkdir /backup
tar -cvpf /backup/backup.tar --directory=/ --exclude=proc --exclude=sys --exclude=dev/pts --exclude=backup .
7z a -mx9 /backup/backup.tar.7z /backup/backup.tar
rm /backup/backup.tar
