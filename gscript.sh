#!/bin/bash
scriptdir=$(pwd)
printf "Please create your partitions prior to installation.\n"
printf "The kernel config provided supports most filesystems(Ext4, XFS, Reiser4. F2FS),\n so root partiton can be formatted based on livecd disk utilities.\n"
printf "Only a three partition boot, swap, and root partition is supported at this time.\n"
#Read and mount partitions
mkdir /mnt/gentoo
mkdir /workgen
rootPart=workgen
mount /dev/$rootPart /mnt/gentoo
mkdir /mnt/gentoo/boot
bootPart=mmcblk0p5
#mkfs.ext2 /dev/$bootPart
mount /dev/$bootPart /mnt/gentoo/boot
#Generate random seed for mirror selection
numMirrors=$(wc -l < mirrors)
mirrorSeed=$((($(date +%s)%${numMirrors})+1))
mirror=$(sed -n -e ${mirrorSeed}p mirrors)

#Download and extract stage3 and portage files.
cd /mnt/gentoo/
wget -rnd -l1 ${mirror}releases/arm/autobuilds/current-stage3-armv7a/ -A "stage3-armv7a-20*.tar.bz2" -e robots=off
wget ${mirror}/snapshots/portage-latest.tar.xz
tar xvjpf stage3*.tar.bz2 --xattrs
rm stage3*
mv portage-latest.tar.xz usr/
cd usr
tar xfv portage-latest.tar.xz
rm portage-latest.tar.xz
cd ..

#Update various configuration files in /etc
printf "\nGENTOO_MIRRORS=\"" >> etc/portage/make.conf
printf $mirror >> etc/portage/make.conf
printf "\"\n" >> etc/portage/make.conf

#Determine number of CPU cores + add to make.conf
cpucores=$(grep -c ^processor /proc/cpuinfo)
cp ${scriptdir}/make.conf etc/portage/make.conf
printf "MAKEOPTS=\"-j${cpucores}\"\n" >> etc/portage/make.conf
cp -L /etc/resolv.conf etc


#Mount necessary filesystems before chroot
mount -t proc proc proc
mount --rbind /sys sys
mount --make-rslave sys
mount --rbind /dev dev
mount --make-rslave dev

#Copy kernel config, wifi config, post-chroot script, and other post-installation build scripts
cp ${scriptdir}/.config .
cp ${scriptdir}/wpa_supplicant.conf .
cp ${scriptdir}/post.sh .
cp -R ${scriptdir}/buildScripts .
cp -R ${scriptdir}/boot boot

#Enter chroot and execute post.sh
chroot /mnt/gentoo ./post.sh
