#!bin/bash
export CC=clang
export CXX=clang++
printf "net-libs/webkit-gtk -opengl" >> /etc/portage/package.use/webkitgtk
printf "virtual/notification-daemon gnome" >> /etc/portage/package.use/webkitgtk
emerge notification-daemon
emerge cinnamon
