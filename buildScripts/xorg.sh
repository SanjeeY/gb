export CC=gcc
export CXX=g++
echo "media-libs/mesa ~amd64" >> /etc/portage/package.accept_keywords
echo "x11-libs/libdrm ~amd64" >> /etc/portage/package.accept_keywords
echo "app-eselect/eselect-opengl ~amd64" >> /etc/portage/package.accept_keywords
echo "x11-proto/glproto ~amd64" >> /etc/portage/package.accept_keywords
echo "x11-base/xorg-drivers ~amd64" >> /etc/portage/package.accept_keywords
echo "x11-base/xorg-server ~amd64" >> /etc/portage/package.accept_keywords
echo "media-libs/mesa -vaapi xa" >> /etc/portage/package.use/mesa
echo "x11-libs/libdrm libkms" >> /etc/portage/package.use/mesa
echo "sys-libs/zlib minizip" >> /etc/portage/package.use/zlib
echo "x11-drivers/xf86-video-r128" >> /etc/portage/package.mask/xf86r128
emerge xorg-server mesa ffmpeg vlc x11-libs/cairo libev recode pixman libaacplus poppler cmake
