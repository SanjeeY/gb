#!/bin/bash
source /etc/profile
env-update
eselect python set 1
printf "POLICY_TYPES=\"strict\"\n" >> /etc/portage/make.conf
#*Remove some accidentally created files (easier than debugging for now)
rm index*
rm gentoo*
rm portage*
mv wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf

#Add CPU processor flags for builds such as ffmpeg
emerge cpuinfo2cpuflags
cpuinfo2cpuflags-x86 >> /etc/portage/make.conf
printf "\n" >> /etc/portage/make.conf

#Enable Linux 4 kernel
printf "sys-kernel/hardened-sources ~amd64\n" >> /etc/portage/package.accept_keywords
printf "=sys-block/thin-provisioning-tools-0.4.1 ~amd64\n" >> /etc/portage/package.accept_keywords
printf "sys-fs/cryptsetup -gcrypt\n" >> /etc/portage/package.use/llvm

#Download and build kernel. Uses included kernel config file from git.
emerge =sys-kernel/hardened-sources-4.0.8 linux-firmware
cd /usr/src/linux
mv /.config .
cpucores=$(grep -c ^processor /proc/cpuinfo)
make -j${cpucores}
make modules_install
make install
reboot
