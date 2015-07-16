#!/bin/bash
sed -i 's/USE="/USE="X dbus qt5 /' /etc/portage/make.conf
printf "media-libs/mesa ~arm\n" >> /etc/portage/package.accept_keywords
printf "x11-libs/libdrm ~arm\n" >> /etc/portage/package.accept_keywords
printf "app-eselect/eselect-opengl ~arm\n" >> /etc/portage/package.accept_keywords
printf "x11-proto/glproto ~arm\n" >> /etc/portage/package.accept_keywords
printf "x11-base/xorg-drivers ~arm\n" >> /etc/portage/package.accept_keywords
printf "x11-base/xorg-server ~arm\n" >> /etc/portage/package.accept_keywords
printf "media-libs/mesa -vaapi xa\n" >> /etc/portage/package.use/mesa
printf "x11-libs/libdrm libkms\n" >> /etc/portage/package.use/mesa
printf "sys-libs/zlib minizip\n" >> /etc/portage/package.use/zlib
printf "x11-drivers/xf86-video-r128\n" >> /etc/portage/package.unmask
export CC=clang
export CXX=clang++
emerge libdrm libXdamage libXxf86vm xinit qtgui
export CC=gcc
export CXX=g++
emerge xorg-server mesa boost boost-build ffmpeg vlc x11-libs/cairo libev recode pixman libaacplus poppler cmake
