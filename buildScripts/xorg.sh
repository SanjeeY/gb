#!/bin/bash
sed -i 's/USE="/USE="X dbus pulseaudio qt5 /' /etc/portage/make.conf
printf "media-libs/mesa ~amd64\n" >> /etc/portage/package.accept_keywords
printf "x11-libs/libdrm ~amd64\n" >> /etc/portage/package.accept_keywords
printf "app-eselect/eselect-opengl ~amd64\n" >> /etc/portage/package.accept_keywords
printf "x11-proto/glproto ~amd64\n" >> /etc/portage/package.accept_keywords
printf "x11-base/xorg-drivers ~amd64\n" >> /etc/portage/package.accept_keywords
printf "x11-base/xorg-server ~amd64\n" >> /etc/portage/package.accept_keywords
printf "media-libs/mesa -vaapi xa\n" >> /etc/portage/package.use/mesa
printf "x11-libs/libdrm libkms\n" >> /etc/portage/package.use/mesa
printf "sys-libs/zlib minizip\n" >> /etc/portage/package.use/zlib
printf "x11-drivers/xf86-video-r128\n" >> /etc/portage/package.unmask
export CC=gcc
export CXX=g++
emerge xorg-server mesa x11-libs/cairo libev pixman
export CC=clang
export CXX=clang++
emerge libdrm libXdamage libXxf86vm xinit qtgui
export CC=gcc
export CXX=g++
emerge ffmpeg vlc recode libaacplus poppler app-crypt/gnupg
