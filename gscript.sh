#!/bin/bash
scriptdir=$(pwd)
printf "Please format your partitions prior to installation.\n"
printf "The kernel config provided supports most filesystems(Ext4, XFS, Reiser4. F2FS),\n so root partiton can be formatted based on livecd disk utilities.\n"
printf "Only a three partition boot, swap, and root partition is supported at this time.\n"
#Read and mount partitions
mkdir /mnt/gentoo
printf "\n\nEnter root partition device(e.g. sda3)\n"
read rootPart
mount /dev/$rootPart /mnt/gentoo
mkdir /mnt/gentoo/boot
printf "\n\nEnter boot partition device(e.g. sda1)\nMust be ext2 for BIOS, vfat for UEFI installations\n"
read bootPart
mount /dev/$bootPart /mnt/gentoo/boot
printf "\n\nWill there be a swap partition(y/n)?\n"
read swapBool
if [ "$swapBool" == "y" ]
then
  printf "\nEnter swap partition device (eg: sda2)\n"
  read swapPart
  swapon /dev/$swapPart
fi

#Generate random seed for mirror selection
numMirrors=$(wc -l mirrors)
mirrorSeed=$((($(date +%s)%${numMirrors})+1))
mirror=$(sed -n -e ${mirrorSeed}p mirrors)

#Download and extract stage3 and portage files.
cd /mnt/gentoo/
dt=$(date -d "5 day ago" +%Y%m%d)
wget "${mirror}/releases/amd64/autobuilds/current-stage3-amd64/stage3-amd64-${dt}.tar.bz2"
wget "${mirror}/snapshots/portage-latest.tar.xz"
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
sed -i -e 's/BOOT/${bootPart}/g' etc/fstab
if [ "$swapBool" == "y" ]
then
  sed -i -e 's/SWAP/${swapPart}/g' etc/fstab
else
  sed -i '/SWAP/d' etc/fstab
fi
sed -i -e 's/ROOT/${rootPart}/g' etc/fstab
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
