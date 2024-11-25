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

# Prompt the user
echo "*********************************************"
echo "*                                           *"
echo "*           Upgrade Confirmation            *"
echo "*                                           *"
echo "*********************************************"
echo "*                                           *"
echo "* Are you sure you want to upgrade?         *"
echo "*                                           *"
echo "* ⚠️  THIS IS STILL A BETA VERSION!          *"
echo "* ⚠️  UPGRADE IF YOU KNOW HOW TO UNBRICK!    *"
echo "*                                           *"
echo "* This process may take some time.          *"
echo "*                                           *"
echo "* Please type y or n and press Enter.       *"
echo "*                                           *"
echo "*********************************************"

# Read user input
read -r answer
# Check the response
case "$answer" in
    [Yy]* ) 
        echo "Proceeding with the upgrade..."
        # Add your upgrade commands here
        ;;
    [Nn]* ) 
        echo "Upgrade canceled."
	exit 1
        ;;
    * ) 
        echo "Invalid input. Please enter 'y' for yes or 'n' for no."
	exit 1
        ;;
esac

LATEST_TAG=$(download_file "https://api.github.com/repos/LarsGrootkarzijn/buildroot-simpleaudio/releases/latest" -)
LATEST_TAG=$(echo "$LATEST_TAG" | grep '"tag_name":' | cut -d '"' -f 4) || { echo "Failed to fetch the latest release tag."; exit 1; }

echo "${LATEST_TAG}" 

UIMAGE_URL="https://github.com/LarsGrootkarzijn/buildroot-simpleaudio/releases/download/${LATEST_TAG}/uImage_Install"
 
echo "Downloading $LATEST_TAG"
 
download_file "$UIMAGE_URL" "uImage"
 
if [ ! -d /boot ]; then
  echo "Creating /boot directory..."
  mkdir -p /boot
fi
 
MMC_DEVICE=$(ls /dev/mmcblk* | grep -o 'mmcblk[0-9]\+' | head -n 1)
 
# Extract the 'X' part from 'mmcblkX'
X=$(echo $MMC_DEVICE | sed 's/mmcblk//')
 
echo "Found MMC device: $MMC_DEVICE"
 
mount /dev/${MMC_DEVICE}p1 /boot
 
rm /boot/uImage
mv ./uImage /boot/
rm /boot/bootargs
 
echo "mainbootargs=console=ttyS0,115200 root=/dev/ram0 rw rdinit=/sbin/init" >> /boot/bootargs
 
umount /dev/${MMC_DEVICE}p1
sync

echo "All ready, will reboot to upgrade.."
sleep 5
reboot
