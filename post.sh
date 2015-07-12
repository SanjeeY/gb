
emerge-webrsync
eselect profile set 12
emerge -uvDN @world gentoo-sources linux-firmware wpa_supplicant dhpcd wireless_tools grub
cd /usr/src/linux
cpucores=grep -c ^processor /proc/cpuinfo
make -j$(cpucores)
make install
grub2-install --target=i386-pc /dev/sda
grub2-mkconfig -o /boot/grub/grub.cfg
systemctl enable gdm
systemctl enable sshd
