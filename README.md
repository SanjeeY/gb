# gentoodev
Gentoo Builder

A collection of bash scripts to build a working gentoo linux distro.

gscript.sh is the initial starting point which partitions the disk, mounts it, and installs the stage3 tarball and portage.

It then copies over the post.sh file into the new root, chroots into it, and finishes by compiling a kernel with default options,builds any necessary system utilities (such as linux-firmware, dhcpcd, wpa_supplicant, and grub). It then installs grub to sda, and finalizes by asking for a root password.

#To-Do
Flexible partitioning options. Currently it is setup for a main partition on sda1 and a swap partition on sda2. No boot, or home partition is considered.

UEFI setup. An option to use EFI needs to be implemented, copying over the kernel to a vfat EFI partition.
