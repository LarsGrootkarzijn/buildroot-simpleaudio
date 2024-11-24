download_file() {
  if command -v curl &> /dev/null; then
    curl -L -o "$2" "$1"
  elif command -v wget &> /dev/null; then
    wget -qO "$2" "$1"
  else
    echo "Neither curl nor wget are available for downloading."
    exit 1
  fi
}

LATEST_TAG=$(download_file "https://api.github.com/repos/LarsGrootkarzijn/buildroot-simpleaudio/releases/latest" -) 
LATEST_TAG=$(echo "$LATEST_TAG" | grep '"tag_name":' | cut -d '"' -f 4) || { echo "Failed to fetch the latest release tag."; exit 1; }

UIMAGE_URL="https://github.com/LarsGrootkarzijn/buildroot-simpleaudio/releases/download/${LATEST_TAG}/uImage"

echo "Downloading $LATEST_TAG"

download_file "$UIMAGE_URL" "uImage"

if [ ! -d /boot ]; then
  echo "Creating /boot directory..."
  mkdir -p /boot
fi

BLK=$(cat /proc/cmdline | grep -o 'root=/dev/mmcblk[0-9]' | cut -d '=' -f 2)
echo "Device to write to is $BLK"
mount ${BLK}p1 /boot

rm /boot/uImage
mv ./uImage /boot
rm /boot/bootargs

echo "console=ttyS0,115200 root=/dev/ram0 rw rdinit=/sbin/init" >> /boot/bootargs

umount ${BLK}p1
sync 
reboot
