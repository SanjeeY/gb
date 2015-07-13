#!/bin/bash
scriptdir=$(pwd)
echo "This Gentoo install script requires partitions to be formatted and unmounted."
echo "This script also requires superuser access."
echo "The kernel config provided supports most filesystems(Ext4, XFS, Reiser4. F2FS), so root partiton can be formatted based on livecd disk utilities."
echo "Only a three partition boot, swap, and root partition is supported at this time."
echo "Do you wish to continue(y/n)?"
read start
if [ "$start" == "y" ]
then
  mkdir /mnt/gentoo
  echo "\n\nEnter root partition device(eg: sda3)"
  read rootPart
  mount $rootPart /mnt/gentoo
  mkdir /mnt/gentoo/boot
  echo "\n\nEnter boot partition device(eg: sda1) - Must be ext2 for BIOS, vfat for UEFI installations."
  read bootPart
  mount $bootPart /mnt/gentoo/boot
  echo "\n\nWill there be a swap partition(y/n)?"
  read swapBool
  if [ "$swapBool" == "y" ]
  then
    echo "\nEnter swap partition device (eg: sda2)"
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
  mkdir /etc/portage
  cp ${scriptdir}/make.conf /mnt/gentoo/etc/portage/make.conf
  echo "MAKEOPTS=\"-j${cpucores}\"" >> /mnt/gentoo/etc/portage/make.conf
  cp -L /etc/resolv.conf /mnt/gentoo/etc/
  mount -t proc proc /mnt/gentoo/proc
  mount --rbind /sys /mnt/gentoo/sys
  mount --make-rslave /mnt/gentoo/sys
  mount --rbind /dev /mnt/gentoo/dev
  mount --make-rslave /mnt/gentoo/dev
  cp ${scriptdir}/.config /mnt/gentoo/.config
  cp ${scriptdir}/post.sh /mnt/gentoo/
  cp -R ${scriptdir}/buildScripts /mnt/gentoo
  chroot /mnt/gentoo ./post.sh
fi
