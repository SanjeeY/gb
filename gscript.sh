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
mkfs.ext4 -F /dev/sda3
mkdir /mnt/gentoo/
mount /dev/sda3 /mnt/gentoo
mkdir /mnt/gentoo/boot
mount /dev/sda1 /mnt/gentoo/boot
swapon /dev/sda2


#Generate random seed for mirror selection
cp mirrors /mnt/gentoo/
cd /mnt/gentoo/
numMirrors=$(wc -l < mirrors)
mirrorSeed=$((($(date +%s)%${numMirrors})+1))
mirror=$(sed -n -e ${mirrorSeed}p mirrors)


wget ${mirror}releases/amd64/autobuilds/latest-stage3-amd64.txt
version=$(sed -n -e 3p latest-stage3-amd64.txt | grep -o '^\S*' |  cut -d \/ -f 1)
wget ${mirror}releases/amd64/autobuilds/current-stage3-amd64/hardened/stage3-amd64-hardened-${version}.tar.bz2
wget ${mirror}releases/amd64/autobuilds/current-stage3-amd64/hardened/stage3-amd64-hardened-${version}.tar.bz2.DIGESTS.asc
wget ${mirror}snapshots/portage-latest.tar.xz
wget ${mirror}snapshots/portage-latest.tar.xz.md5sum

stageTSig=$(awk '/SHA/{getline; print}' stage3-amd64-hardened-${version}.tar.bz2.DIGESTS.asc | awk 'NR==2{print $1;}')
echo $stageTSig
stageDSig=$(sha512sum stage3-amd64-hardened-${version}.tar.bz2 | awk '{print $1}')
echo $stageDSig
portageTSig=$(md5sum portage-latest.tar.xz)
portageDSig=$(grep xz portage-latest.tar.xz.md5sum)
echo $portageTSig
echo $portageDSig
#Download and extract stage3 and portage files.
while [[ "$stageTSig" != "$stageDSig" || $portageTSig != $portageDSig ]];
do
{
  rm stage3*
  rm portage*
  mirrorSeed=$((($(date +%s)%${numMirrors})+1))
  mirror=$(sed -n -e ${mirrorSeed}p mirrors)
  wget ${mirror}releases/amd64/autobuilds/latest-stage3-amd64.txt
  version=$(sed -n -e 3p latest-stage3-amd64.txt | grep -o '^\S*' |  cut -d \/ -f 1)
  wget ${mirror}releases/amd64/autobuilds/current-stage3-amd64/hardened/stage3-amd64-hardened-${version}.tar.bz2
  wget ${mirror}releases/amd64/autobuilds/current-stage3-amd64/hardened/stage3-amd64-hardened-${version}.tar.bz2.DIGESTS.asc
  wget ${mirror}snapshots/portage-latest.tar.xz
  wget ${mirror}snapshots/portage-latest.tar.xz.md5sum
  stageTSig=$(awk '/SHA/{getline; print}' stage3-amd64-hardened-${version}.tar.bz2.DIGESTS.asc | awk 'NR==2{print $1;}')
  stageDSig=$(sha512sum stage3-amd64-hardened-${version}.tar.bz2 | awk '{print $1}')
  portageTSig=$(md5sum portage-latest.tar.xz)
  portageDSig=$(grep xz portage-latest.tar.xz.md5sum)
}
done

printf "Extracting stage3...\n"
tar xjpf stage3*.tar.bz2
rm latest-stage3-amd64.txt
rm stage3*
mv portage-latest.tar.xz usr/
cd usr
printf "Extracting portage...\n"
tar xf portage-latest.tar.xz
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
v=$(date +%Y%m%d%H%M)
fi
