#!/bin/bash
source /etc/profile
env-update
if [ ! -d "/usr/portage"]
then
  rm stage3*
  cd /usr
  wget http://gentoo.mirrors.tds.net/gentoo/snapshots/portage-latest.tar.xz
  tar xfv portage-latest.tar.xz
  emerge cpuinfo2cpuflags
  cpuinfo2cpuflags-x86 >> /etc/portage/make.conf
  eselect profile set 12
  echo "=sys-devel/clang-3.6.1-r100 ~amd64" >> /etc/portage/package.accept_keywords
  echo "=sys-devel/llvm-3.6.1 ~amd64" >> /etc/portage/package.accept_keywords
  echo "sys-devel/llvm clang" >> /etc/portage/package.use/llvm
  emerge =sys-devel/clang-3.6.1-r100 glibc guile autogen ntp
  export CC=clang
  export CXX=clang++
  emerge gentoo-sources linux-firmware
  cd /usr/src/linux
  mv /.config .
  cpucores=$(grep -c ^processor /proc/cpuinfo)
  make -j${cpucores}
  make modules_install
  make install
  emerge -uDN @world  wpa_supplicant dhcpcd wireless-tools grub

  grub2-install --target=i386-pc /dev/sda
  grub2-mkconfig -o /boot/grub/grub.cfg
  systemctl enable sshd
  systemctl enable dhcpcd
  systemctl enable ntpd
  echo "Please enter root password:\n"
  passwd
fi
echo "Do you want to install xorg-server?"
read xorg
if ["$xorg" == "y"];
then
  ./buildScripts/xorg.sh
  echo "Do you want to install cinnamon DE?"
  read cinnamon
  if["$cinnamon" == "y"]
  then
    ./buildScripts/buildCinnamon.sh
  fi
fi
