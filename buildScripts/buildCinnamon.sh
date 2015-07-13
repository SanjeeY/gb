#!bin/bash
export CC=clang
export CXX=clang++
echo "net-libs/webkit-gtk -opengl" >> /etc/portage/package.use/webkitgtk
echo "virtual/notification-daemon gnome" >> /etc/portage/package.use/webkitgtk
emerge notification-daemon
emerge cinnamon
