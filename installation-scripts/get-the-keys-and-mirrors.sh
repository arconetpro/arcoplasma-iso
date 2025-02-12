#!/bin/bash

######################################################################################################################

sudo pacman -S wget --noconfirm --needed

echo "Getting the ArcoLinux keys from the ArcoLinux repo - report if link is broken"
sudo wget https://github.com/arcolinux/arcolinux_repo/raw/main/x86_64/arcolinux-keyring-20251209-3-any.pkg.tar.zst -O /tmp/arcolinux-keyring-20251209-3-any.pkg.tar.zst
sudo pacman -U --noconfirm /tmp/arcolinux-keyring-20251209-3-any.pkg.tar.zst

echo "Getting the latest arcolinux mirrors file - report if link is broken"
sudo wget https://github.com/arcolinux/arcolinux_repo/raw/main/x86_64/arcolinux-mirrorlist-git-24.03-12-any.pkg.tar.zst -O /tmp/arcolinux-mirrorlist-git-24.03-12-any.pkg.tar.zst
sudo pacman -U --noconfirm /tmp/arcolinux-mirrorlist-git-24.03-12-any.pkg.tar.zst
