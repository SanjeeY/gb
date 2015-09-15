#!/bin/bash
sed -i 's/USE="/USE="X wayland icu egl dbus pulseaudio gudev /' /etc/portage/make.conf
printf "media-libs/mesa ~amd64\n" >> /etc/portage/package.accept_keywords
printf "x11-libs/libdrm ~amd64\n" >> /etc/portage/package.accept_keywords
printf "app-eselect/eselect-opengl ~amd64\n" >> /etc/portage/package.accept_keywords
printf "x11-proto/glproto ~amd64\n" >> /etc/portage/package.accept_keywords
printf "gnome-base/gvfs ~amd64\n" >> /etc/portage/package.accept_keywords
printf "x11-base/xorg-drivers ~amd64\n" >> /etc/portage/package.accept_keywords
printf "x11-base/xorg-server ~amd64\n" >> /etc/portage/package.accept_keywords
printf "media-libs/mesa -vaapi xa\n" >> /etc/portage/package.use/mesa
printf "x11-apps/mesa-progs egl -gles2\n" >> /etc/portage/package.use/mesa
printf "x11-libs/libdrm libkms\n" >> /etc/portage/package.use/mesa
printf "x11-libs/cairo opengl\n" >> /etc/portage/package.use/mesa
printf "sys-libs/zlib minizip\n" >> /etc/portage/package.use/zlib
printf "x11-drivers/xf86-video-r128\n" >> /etc/portage/package.unmask
printf "media-libs/gexiv2 introspection\n" >> /etc/portage/package.use/zlib
printf "x11-libs/gdk-pixbuf jpeg\ngnome-base/gvfs cdda\nmedia-libs/gst-plugins-base theora\nwww-servers/apache apache2_mpms_prefork apache2_modules_auth_digest\ndev-libs/folks eds\nmedia-libs/clutter gtk\nvirtual/libgudev introspection\ndev-libs/libgdata gnome\nsys-apps/systemd introspection\nmedia-gfx/imagemagick jpeg png\ngnome-extra/evolution-data-server vala\napp-misc/tracker gstreamer\n" >> /etc/portage/package.use/zlib
printf "sys-libs/zlib minizip\napp-crypt/pinentry gnome-keyring\nmedia-libs/mesa gles2\nmedia-libs/cogl gles2\ngnome-base/gnome-control-center networkmanager\napp-crypt/gcr gtk\ngnome-base/gvfs gtk\napp-text/poppler cairo\nmedia-plugins/grilo-plugins upnp-av tracker\nmedia-libs/grilo playlist\ndev-libs/libgdata gnome\n" >> /etc/portage/package.use/mesaprogs
emerge xorg-server twm xclock xterm
