#!/bin/bash
#startH=$(date '+%-H')
#startM=$(date '+%-M')
#startS=$(date '+%-S')
{
source /etc/profile
env-update
emerge --sync

mkdir /etc/wpa_supplicant
mv wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf
ln -s /usr/share/zoneinfo/US/Eastern /etc/localtime
sed -i s/#en/en/g /etc/locale.gen
locale-gen
eselect locale set 4

#Build and switch to clang. Also build some packages with gcc that break with clang.
printf "sys-devel/clang ~amd64\n" >> /etc/portage/package.accept_keywords
printf "sys-devel/llvm ~amd64\n" >> /etc/portage/package.accept_keywords
printf "sys-kernel/gentoo-sources ~amd64\n" >> /etc/portage/package.accept_keywords
printf "sys-devel/llvm clang\n" >> /etc/portage/package.use/llvm
printf "media-libs/harfbuzz icu\n" >> /etc/portage/package.use/llvm
printf "sys-apps/systemd gudev\n" >> /etc/portage/package.use/llvm
printf "[1.] Building LLVM & Clang\n"
printf "======================================================================="
emerge clang guile autogen ntp
export CC=clang
export CXX=clang++

#Download and build kernel. Uses included kernel config file from git.
printf "[2.] Building kernel [clang enabled]"
printf "======================================================================="

emerge gentoo-sources linux-firmware
cd /usr/src/linux
openssl req -new -nodes -utf8 -sha512 -days 36500 -batch -x509 -config /buildScripts/x509.genkey -outform DER -out signing_key.x509 -keyout signing_key.priv
cp /.config .
cpucores=$(grep -c ^processor /proc/cpuinfo)
make oldconfig
make -j${cpucores}
#make modules
make modules_install
make install
#cp /usr/src/linux/arch/arm/boot/zImage /boot/kernel7.img

#Selects vanilla systemd profile. Builds systemd, bootloader, some net tools and a world update.
printf "[3.] Updating world and installing various network utilities [clang enabled]"
printf "======================================================================="
eselect profile set 12
emerge -C udev
emerge -uDN @world wpa_supplicant dhcpcd wireless-tools p7zip dev-tcltk/expect grub

#Enables ssh, dhcpcd, and ntp.
systemctl enable sshd
systemctl enable dhcpcd
systemctl enable ntpd

#Update config files
etc-update --automode -3




#Root password prompt
./setp.sh
mkdir /backup

printf "[F1.] Archiving installation"
printf "======================================================================="
XZ_OPT=-9 tar -cvpJf /backup/backup.tar.xz --directory=/ --exclude=proc --exclude=sys --exclude=dev/pts --exclude=backup .

printf "[4.] Building xorg-server"
printf "======================================================================="
./buildScripts/xorg.sh

printf "[F2.] Archiving installation"
printf "======================================================================="
XZ_OPT=-9 tar -cvpJf /backup/backup.xorg-server.tar.xz --directory=/ --exclude=proc --exclude=sys --exclude=dev/pts --exclude=backup .


printf "[5.] Building Cinnamon"
printf "======================================================================="
./buildScripts/buildCinnamon.sh

printf "[F3.] Archiving installation"
printf "======================================================================="
XZ_OPT=-9 tar -cvpJf /backup/backup.cinnamon.tar.xz --directory=/ --exclude=proc --exclude=sys --exclude=dev/pts --exclude=backup .

exit
} 2>&1 | tee -a post.log

#while IFS= read -r line;
#do
#newH=$(date '+%-H')
#newM=$(date '+%-M')
#newS=$(date '+%-S')
#fH=$((newH-startH))
#fM=$((newM-startM))
#fS=$((newS-startS))
#done
