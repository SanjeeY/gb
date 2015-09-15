#!/bin/bash
printf "dev-qt/*\nlxqt-base/*\nmedia-gfx/lximage-qt\nx11-misc/obconf-qt\nx11-misc/pcmanfm-qt\n" >> /etc/portage/package.keywords
printf "kde-frameworks/kf-env ~amd64\nkde-frameworks/kwindowsystem ~amd64\nkde-frameworks/extra-cmake-modules ~amd64\nx11-misc/xdg-utils ~amd64\ndev-libs/libqtxdg ~amd64\nkde-frameworks/kguiaddons ~amd64\n" >> /etc/portage/package.accept_keywords
printf "dev-libs/libpcre pcre16\nsys-auth/polkit-qt qt5" >> /etc/portage/package.use/lxqt
mkdir /etc/portage/profile && echo -qt5 >> /etc/portage/profile/use.stable.mask
emerge -v lxqt-meta
