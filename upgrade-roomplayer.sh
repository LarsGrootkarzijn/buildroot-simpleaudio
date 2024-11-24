#!/bin/sh

# Get the latest release tag
LATEST_TAG=$(wget -qO- https://api.github.com/repos/LarsGrootkarzijn/buildroot-simpleaudio/releases/latest | grep '"tag_name":' | cut -d '"' -f 4) || { echo "Failed to fetch the latest release tag."; exit 1; }

# Construct URLs for the files
UIMAGE_URL="https://github.com/LarsGrootkarzijn/buildroot-simpleaudio/releases/download/${LATEST_TAG}/uImage"

if ! wget $UIMAGE_URL; then
  echo "Error downloading uImage."
  exit 1
fi

if [ ! -d /boot ]; then
  echo "Creating /boot directory..."
  mkdir -p /boot
fi

BLK=$(cat /proc/cmdline | grep -o 'root=/dev/mmcblk[0-9]' | cut -d '=' -f 2)
mount ${BLK}p1 /boot

rm /boot/uImage
mv ./uImage /boot
rm /boot/bootargs

echo "console=ttyS0,115200 root=/dev/ram0 rw rdinit=/sbin/init" >> /boot/bootargs

sync 
reboot
