#!bin/bash
sed -i 's/USE="/USE="gtk /' /etc/portage/make.conf
printf "x11-libs/gtk+ X\n" >> /etc/portage/package.use/webkitgtk
printf "net-libs/webkit-gtk -gles2\n" >> /etc/portage/package.use/webkitgtk
printf "virtual/notification-daemon gnome\n" >> /etc/portage/package.use/webkitgtk
emerge notification-daemon
emerge cinnamon gdm
systemctl enable gdm
