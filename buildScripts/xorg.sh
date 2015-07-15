export CC=gcc
export CXX=g++
sed 's/USE="/USE="X dbus /' /etc/portage/make.conf > /etc/portage/make.conf
printf "media-libs/mesa ~amd64\n" >> /etc/portage/package.accept_keywords
printf "x11-libs/libdrm ~amd64\n" >> /etc/portage/package.accept_keywords
printf "app-eselect/eselect-opengl ~amd64\n" >> /etc/portage/package.accept_keywords
printf "x11-proto/glproto ~amd64\n" >> /etc/portage/package.accept_keywords
printf "x11-base/xorg-drivers ~amd64\n" >> /etc/portage/package.accept_keywords
printf "x11-base/xorg-server ~amd64\n" >> /etc/portage/package.accept_keywords
printf "media-libs/mesa -vaapi xa\n" >> /etc/portage/package.use/mesa
printf "x11-libs/libdrm libkms\n" >> /etc/portage/package.use/mesa
printf "sys-libs/zlib minizip\n" >> /etc/portage/package.use/zlib
printf "x11-drivers/xf86-video-r128\n" >> /etc/portage/package.mask/xf86r128
emerge xorg-server mesa boost boost-build ffmpeg vlc x11-libs/cairo libev recode pixman libaacplus poppler cmake
