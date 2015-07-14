#!/bin/bash
scriptdir=$(pwd)
printf "Please leave partitions unmounted.\n"
printf "Root partition will be reformatted as an encrypted container with an ext4 partition inside."
printf "Only a three partition boot, swap, and root setup is supported at this time.\n"

#LUKS Prompt
printf "\n\nCryptsetup must be installed for the encrypted gentoo installer"
printf "\nDo you wish to proceed?(y/n)\n"
read haveCryptsetup
if [ "$haveCryptsetup" == "y" ]
then
  #Cryptsetup
  mkdir /mnt/gentoo
  printf "\n\nEnter root partition device(e.g. sda3)\n"
  read rootPart
  rootUUID=$(blkid /dev/${rootPart} | sed -n 's/.* UUID=\"\([^\"]*\)\".*/\1/p')
  printf "\nEncryption key for the partition will be asked for next."
  cryptsetup -s 512 luksFormat /dev/$rootPart
  printf "\nRe-enter your encryption key below:"
  cryptsetup luksOpen /dev/$rootPart ecroot
  mkfs.ext4 /dev/mapper/ecroot
  mount /dev/mapper/ecroot /mnt/gentoo
  sed -i -e 's/CRYPTROOT/${rootUUID}/g' .config

  #Boot Partition setup
  mkdir /mnt/gentoo/boot
  printf "\n\nEnter boot partition device(e.g. sda1)\n"
  read bootPart
  mkfs.ext4 /dev/$bootPart
  mount /dev/$bootPart /mnt/gentoo/boot

  #Swap partition setup
  printf "\n\nWill there be a swap partition(y/n)?\n"
  read swapBool
  if [ "$swapBool" == "y" ]
  then
    printf "\nEnter swap partition device (eg: sda2)\n"
    read swapPart
    swapon /dev/$swapPart
  fi

  #Generate random seed for mirror selection
  mirrorSeed=$(($(date +%s)%21+1))
  mirror=$(sed -n -e ${mirrorSeed}p mirrors)

  #Download and extract stage3 and portage files.
  cd /mnt/gentoo/
  dt=$(date -d "5 day ago" +%Y%m%d)
  wget "${mirror}/releases/amd64/autobuilds/current-stage3-amd64-hardened/stage3-amd64-hardened-${dt}.tar.bz2"
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
  cp ${scriptdir}/fstab etc
  cp -R ${scriptdir}/buildScripts .

  #Enter chroot and execute post.sh
  chroot /mnt/gentoo ./post.sh
fi
