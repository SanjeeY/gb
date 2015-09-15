#!/bin/bash
printf "dev-qt/*\nlxqt-base/*\nmedia-gfx/lximage-qt\nx11-misc/obconf-qt\nx11-misc/pcmanfm-qt\nx11-misc/sddm" >> /etc/portage/package.keywords
mkdir /etc/portage/profile && echo -qt5 >> /etc/portage/profile/use.stable.mask
emerge -v lxqt-meta
