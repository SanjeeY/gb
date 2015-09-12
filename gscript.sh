#!/bin/bash
scriptdir=$(pwd)
printf "==========================================================================================\n"
printf "Replace configuration files in the root folder(such as kernel config, fstab, or make.conf)\n
Warning: Editing the USE variable in make.conf may cause autobuild to fail.\n"
printf "==========================================================================================\n"
printf "\nType 'y' to start:  "
read start
if [ "$start" == "y" ]
then
#Create working directory
mkdir /mnt/gentoo/boot

#Generate random seed for mirror selection
cp mirrors /mnt/gentoo/
cd /mnt/gentoo/
numMirrors=$(wc -l < mirrors)
mirrorSeed=$((($(date +%s)%${numMirrors})+1))
mirror=$(sed -n -e ${mirrorSeed}p mirrors)


wget ${mirror}releases/arm/autobuilds/latest-stage3-armv7a_hardfp.txt
version=$(sed -n -e 3p latest-stage3-armv7a_hardfp.txt | grep -o '^\S*' |  cut -d \/ -f 1)
wget ${mirror}releases/arm/autobuilds/current-stage3-armv7a_hardfp/stage3-armv7a_hardfp-${version}.tar.bz2
wget ${mirror}snapshots/portage-latest.tar.xz


printf "Extracting stage3...\n"
tar xvjpf stage3*.tar.bz2
rm latest-stage3-armv7a_hardfp.txt
rm stage3*
mv portage-latest.tar.xz usr/
cd usr
printf "Extracting portage...\n"
tar xf portage-latest.tar.xz
rm portage-latest.tar.xz
cd ..


#Edit fstab
sed -i -e 's/BOOT/mmcblk0p5/g' etc/fstab
sed -i -e '/SWAP/d' etc/fstab
sed -i -e 's/ROOT/mmcblk0p5/g' etc/fstab
sed -i -e 's/ext2/ext4/g' etc/fstab
sed -i -e 's/ext3/ext4/g' etc/fstab

#Update various configuration files in /etc
printf "\nGENTOO_MIRRORS=\"" >> ${scriptdir}/make.conf
printf $mirror >> ${scriptdir}/make.conf
printf "\"\n" >> ${scriptdir}/make.conf

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

#Enter chroot and execute post.sh
chroot /mnt/gentoo ./post.sh
#v=$(date +%Y%m%d%H%M)
fi
