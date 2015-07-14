export CC=gcc
export CXX=g++
printf "media-libs/mesa ~amd64" >> /etc/portage/package.accept_keywords
printf "x11-libs/libdrm ~amd64" >> /etc/portage/package.accept_keywords
printf "app-eselect/eselect-opengl ~amd64" >> /etc/portage/package.accept_keywords
printf "x11-proto/glproto ~amd64" >> /etc/portage/package.accept_keywords
printf "x11-base/xorg-drivers ~amd64" >> /etc/portage/package.accept_keywords
printf "x11-base/xorg-server ~amd64" >> /etc/portage/package.accept_keywords
printf "media-libs/mesa -vaapi xa" >> /etc/portage/package.use/mesa
printf "x11-libs/libdrm libkms" >> /etc/portage/package.use/mesa
printf "sys-libs/zlib minizip" >> /etc/portage/package.use/zlib
printf "x11-drivers/xf86-video-r128" >> /etc/portage/package.mask/xf86r128
emerge xorg-server mesa ffmpeg vlc x11-libs/cairo libev recode pixman libaacplus poppler cmake
