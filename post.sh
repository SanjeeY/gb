#!/bin/bash
{
source /etc/profile
env-update

#*Remove some accidentally created files (easier than debugging for now)
mkdir /etc/wpa_supplicant
mv wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf

#Build and switch to clang. Also build some packages with gcc that break with clang.
printf "sys-devel/llvm ~arm\n" >> /etc/portage/package.accept_keywords
printf "sys-devel/clang ~arm\n" >> /etc/portage/package.accept_keywords
printf "app-arch/p7zip ~arm\n" >> /etc/portage/package.accept_keywords
printf "sys-kernel/raspberrypi-sources **\n" >> /etc/portage/package.accept_keywords
printf "sys-boot/raspberrypi-firmware ~arm\n" >> /etc/portage/package.accept_keywords
printf "sys-devel/llvm clang\n" >> /etc/portage/package.use/llvm
printf "dev-python/py -test\n" >> /etc/portage/package.use/llvm
printf "media-libs/harfbuzz icu\n" >> /etc/portage/package.use/llvm
printf "sys-apps/systemd gudev\n" >> /etc/portage/package.use/llvm

#Download and build kernel.
emerge raspberrypi-sources raspberrypi-firmware
cd /usr/src/linux
mv /.config .
cpucores=$(grep -c ^processor /proc/cpuinfo)
make oldconfig
make -j${cpucores}
make modules
#make modules_install
#make install
#cp /usr/src/linux/arch/arm/boot/zImage /boot/kernel7.img

#Selects vanilla systemd profile. Builds systemd, bootloader, some net tools and a world update.
eselect profile set 12
emerge -uDN @world wpa_supplicant dhcpcd wireless-tools p7zip dev-tcltk/expect

#Enables ssh, dhcpcd, and ntp.
systemctl enable sshd
systemctl enable dhcpcd
systemctl enable ntpd

#Update config files
etc-update --automode -3

./setp.sh root
mkdir /backup
XZ_OPT=-9 tar -cvpJf /backup/pigen.tar.xz --directory=/ --exclude=proc --exclude=sys --exclude=dev/pts --exclude=backup .
emerge clang llvm

XZ_OPT=-9 tar -cvpJf /backup/pigen.clang.tar.xz --directory=/ --exclude=proc --exclude=sys --exclude=dev/pts --exclude=backup .
} 2>&1 | while IFS= read -r line; do printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$line"; done | tee -a post.log
