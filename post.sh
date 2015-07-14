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
USE="static" emerge busybox cryptsetup
emerge =sys-kernel/hardened-sources-4.0.8 linux-firmware grub wpa_supplicant dhcpcd wireless-tools cryptsetup
mkdir -p /usr/src/initramfs/{bin,dev,etc,lib,lib64,mnt/root,proc,root,sbin,sys}
cp -a /dev/{null,console,tty,sda1} /usr/src/initramfs/dev/
cp -a /dev/{urandom,random} /usr/src/initramfs/dev/
cp -a /sbin/cryptsetup /usr/src/initramfs/sbin/cryptsetup
cp -a /bin/busybox /usr/src/initramfs/bin/busybox
cd /usr/src/initramfs
printf "#!/bin/busybox sh\n
mount -t proc none /proc\n
mount -t sysfs none /sys\n
cryptsetup -T 5 luksOpen /dev/sda3 ecroot\n" >> init
find . -print0 | cpio --null -ov --format=newc | gzip -9 > /boot/custom-initramfs.cpio.gz
cd /usr/src/linux
mv /.config .
cpucores=$(grep -c ^processor /proc/cpuinfo)
make -j${cpucores}
make modules_install
make install
grub2-install --target=i386-pc /dev/sda
grub2-mkconfig -o /boot/grub/grub.cfg
reboot
