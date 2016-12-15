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
mkfs.ext4 -F /dev/sda1
mkdir /mnt/gentoo/
mount /dev/sda1 /mnt/gentoo
swapon /dev/sda2


#Generate random seed for mirror selection
cp mirrors /mnt/gentoo/
cd /mnt/gentoo/
numMirrors=$(wc -l < mirrors)
mirrorSeed=$((($(date +%s)%${numMirrors})+1))
mirror=$(sed -n -e ${mirrorSeed}p mirrors)


wget ${mirror}releases/amd64/autobuilds/latest-stage3-amd64-systemd.txt
version=$(sed -n -e 3p latest-stage3-amd64-systemd.txt | grep -o '^\S*' |  cut -d \/ -f 1)
wget ${mirror}releases/amd64/autobuilds/current-stage3-amd64-systemd/stage3-amd64-systemd-${version}.tar.bz2
wget ${mirror}releases/amd64/autobuilds/current-stage3-amd64-systemd/stage3-amd64-systemd-${version}.tar.bz2.DIGESTS.asc
wget ${mirror}snapshots/portage-latest.tar.xz
wget ${mirror}snapshots/portage-latest.tar.xz.md5sum


printf "Extracting stage3...\n"
tar xvjpf stage3*.tar.bz2 --xattrs
rm -f latest-stage3-amd64-systemd.txt
rm -f stage3*
mv portage-latest.tar.xz usr/
cd usr
printf "Extracting portage...\n"
tar xf portage-latest.tar.xz
rm -f portage-latest.tar.xz
cd ..


#Update various configuration files in /etc
printf "\nGENTOO_MIRRORS=\"" >> ${scriptdir}/make.conf
printf $mirror >> ${scriptdir}/make.conf
printf "\"\n" >> ${scriptdir}/make.conf

#Determine number of CPU cores + add to make.conf
cpucores=$(grep -c ^processor /proc/cpuinfo)
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

#Enter chroot and execute post.sh
chroot /mnt/gentoo ./post.sh
#v=$(date +%Y%m%d%H%M)
fi
