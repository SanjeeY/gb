#!/bin/bash
{
scriptdir=$(pwd)

#Create working directory
rm -rf /mnt/gentoo
mkdir /mnt/gentoo
mkdir /mnt/gentoo/boot

#Generate random seed for mirror selection
numMirrors=$(wc -l < mirrors)
mirrorSeed=$((($(date +%s)%${numMirrors})+1))
mirror=$(sed -n -e ${mirrorSeed}p mirrors)

#Download and extract stage3 and portage files.
cd /mnt/gentoo/
wget ${mirror}releases/amd64/autobuilds/latest-stage3-amd64.txt
version=$(sed -n -e 3p latest-stage3-amd64.txt | grep -o '^\S*' |  cut -d \/ -f 1)
wget ${mirror}releases/amd64/autobuilds/current-stage3-amd64/stage3-amd64-${version}.tar.bz2
wget ${mirror}snapshots/portage-latest.tar.xz
tar xvjpf stage3*.tar.bz2
rm latest-stage3-amd64.txt
rm stage3*
mv portage-latest.tar.xz usr/
cd usr
tar xfv portage-latest.tar.xz
rm portage-latest.tar.xz
cd ..


#Edit fstab
sed -i -e 's/BOOT/sda1/g' etc/fstab
sed -i -e 's/SWAP/sda2/g' etc/fstab
sed -i -e 's/ROOT/sda3/g' etc/fstab


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

#Enter chroot and execute post.sh
chroot /mnt/gentoo ./post.sh
} 2>&1 | while IFS= read -r line; do printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$line"; done | tee -a gscript.log
v=$(date +%Y%m%d%H%M)
cp /mnt/gentoo/backup/backup.tar.xz /mnt/storage/gbuild.${v}.tar.xz
cp /mnt/gentoo/backup/backup.xorg-server.tar.xz /mnt/storage/gbuild.xorg-server.${v}.tar.xz
cp /mnt/gentoo/backup/backup.cinnamon.tar.xz /mnt/storage/gbuild.cinnamon.${v}.tar.xz
