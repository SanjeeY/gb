#!bin/bash
export CC=clang
export CXX=clang++
printf "net-libs/webkit-gtk -opengl\n" >> /etc/portage/package.use/webkitgtk
printf "virtual/notification-daemon gnome\n" >> /etc/portage/package.use/webkitgtk
emerge notification-daemon
emerge cinnamon
