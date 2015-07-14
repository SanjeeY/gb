#!/bin/bash
scriptdir=$(pwd)
printf "This Gentoo install script requires partitions to be formatted and unmounted."
printf "This script also requires superuser access."
printf "The kernel config provided supports most filesystems(Ext4, XFS, Reiser4. F2FS), so root partiton can be formatted based on livecd disk utilities."
printf "Only a three partition boot, swap, and root partition is supported at this time."
printf "Do you wish to continue(y/n)?"
read start
if [ "$start" == "y" ]
then
  mkdir /mnt/gentoo
  printf "\n\nEnter root partition device(eg: sda3)"
  read rootPart
  mount $rootPart /mnt/gentoo
  mkdir /mnt/gentoo/boot
  printf "\n\nEnter boot partition device(eg: sda1) - Must be ext2 for BIOS, vfat for UEFI installations."
  read bootPart
  mount $bootPart /mnt/gentoo/boot
  printf "\n\nWill there be a swap partition(y/n)?"
  read swapBool
  if [ "$swapBool" == "y" ]
  then
    printf "\nEnter swap partition device (eg: sda2)"
    read swapPart
    swapon $swapPart
  fi
  cd /mnt/gentoo/
  dt=$(date -d "4 day ago" +%Y%m%d)
  rm stage3*
  wget http://gentoo.mirrors.tds.net/gentoo/releases/amd64/autobuilds/current-stage3-amd64/stage3-amd64-${dt}.tar.bz2
  tar xvjpf stage3-*.tar.bz2 --xattrs
  sed -i -e 's/BOOT/$bootPart/g' /etc/fstab
  if [ "$swapBool" == "y" ]
  then
    sed -i -e 's/SWAP/$swapPart/g' /etc/fstab
  else
    sed -i '/SWAP/d' /etc/fstab
  fi
  sed -i -e 's/ROOT/$rootPart/g' /etc/fstab
  cpucores=$(grep -c ^processor /proc/cpuinfo)
  cp ${scriptdir}/make.conf etc/portage/make.conf
  printf "MAKEOPTS=\"-j${cpucores}\"" >> etc/portage/make.conf
  cp -L /etc/resolv.conf etc/
  mount -t proc proc proc
  mount --rbind /sys sys
  mount --make-rslave sys
  mount --rbind /dev dev
  mount --make-rslave dev
  cp ${scriptdir}/.config .
  cp ${scriptdir}/post.sh .
  cp ${scriptdir}/wpa_supplicant.conf .
  cp -R ${scriptdir}/buildScripts .
  chroot /mnt/gentoo ./post.sh
fi
