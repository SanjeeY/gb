#!/bin/bash
scriptdir=$(pwd)
printf "==========================================================================================\n"
printf "Replace configuration files in the root folder(such as kernel config, fstab, or make.conf)\n
Warning: Editing the USE variable in make.conf may cause autobuild to fail.\n"
printf "==========================================================================================\n"
printf "\nType 'y' to start\n"
read start
if [ "$start" == "y" ]
then
  #Read and mount partitions
  mkdir /mnt/gentoo
  mkdir /mnt/gentoo/boot
  #bootPart=mmcblk0p5
  #mkfs.ext2 /dev/$bootPart
  #mount /dev/$bootPart /mnt/gentoo/boot
  #Generate random seed for mirror selection
  numMirrors=$(wc -l < mirrors)
  mirrorSeed=$((($(date +%s)%${numMirrors})+1))
  mirror=$(sed -n -e ${mirrorSeed}p mirrors)

  #Download and extract stage3 and portage files.
  cd /mnt/gentoo/
  wget ${mirror}releases/arm/autobuilds/latest-stage3-armv7a_hardfp.txt
  version=$(sed -n -e 3p latest-stage3-armv7a_hardfp.txt | grep -o '^\S*' |  cut -d \/ -f 1)
  rm latest-stage3-armv7a_hardfp.txt
  wget ${mirror}releases/arm/autobuilds/current-stage3-armv7a_hardfp/stage3-armv7a_hardfp-${version}.tar.bz2
  wget ${mirror}/snapshots/portage-latest.tar.xz
  tar xvjpf stage3*.tar.bz2
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
  cp ${scriptdir}/boot/* boot

  #Enter chroot and execute post.sh
  chroot /mnt/gentoo ./post.sh

fi
