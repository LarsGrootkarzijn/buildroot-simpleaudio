download_file() {
  if command -v curl &> /dev/null; then
    curl -s -L -o "$2" "$1"
    if [ $? -ne 0 ]; then
      echo "curl failed to download the file."
      exit 1
    fi
  elif command -v wget &> /dev/null; then
    wget -qO "$2" "$1"
    if [ $? -ne 0 ]; then
      echo "wget failed to download the file."
      exit 1
    fi
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
        echo
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

echo "Found version ${LATEST_TAG}" 
echo

UIMAGE_URL="https://github.com/LarsGrootkarzijn/buildroot-simpleaudio/releases/download/${LATEST_TAG}/uImage_Install"

echo "Downloading $LATEST_TAG"
echo

download_file "$UIMAGE_URL" "uImage"

if [ ! -s "uImage" ]; then
    echo "Download failed."
    exit 1
fi

if [ ! -d /boot ]; then
  echo "Creating /boot directory..."
  mkdir -p /boot
fi

MMC_DEVICE=$(ls /dev/mmcblk* | grep -o 'mmcblk[0-9]\+' | head -n 1)

# Extract the 'X' part from 'mmcblkX'
if [[ $MMC_DEVICE =~ ^mmcblk([a-zA-Z0-9]+)$ ]]; then
    X=$(echo $MMC_DEVICE | sed 's/mmcblk//')
else
    echo "Invalid MMC_DEVICE format: $MMC_DEVICE"
    exit 1
fi

echo "Found MMC device: $MMC_DEVICE"

mount /dev/${MMC_DEVICE}p1 /boot

if ! mountpoint -q /boot; then
    echo "Failed to mount /boot."
    exit 1
fi


if ! rm /boot/uImage; then
    echo "Failed to remove /boot/uImage."
fi

awk '/install/ { found=1; } END { if (!found) { print "CRITICAL ERROR! Wrong kernel."; exit 1; } }' ./uImage

# Move the new uImage to /boot
if ! mv ./uImage /boot/; then
    echo "Critical error: Failed to move uImage to /boot."
    exit 1
fi

# Remove the existing bootargs file
if ! rm /boot/bootargs; then
    echo "Failed to remove /boot/bootargs."
fi

# Append bootargs to the bootargs file
if ! echo "mainbootargs=console=ttyS0,115200 root=/dev/ram0 rw rdinit=/sbin/init" >> /boot/bootargs; then
    echo "Failed to append to /boot/bootargs."
    exit 1
fi

umount /dev/${MMC_DEVICE}p1
sync

echo
echo "All ready, will reboot to upgrade, Press any key to cancel reboot."
echo

COUNTDOWN=5

for ((i=$COUNTDOWN; i>=1; i--)); do
    echo -ne "Rebooting in $i... \r"
    if read -t 1 -n 1; then
        echo -e "Reboot canceled."
        exit 0
    fi
done

echo "Rebooting, this process takes a long time. Do not unplug."
reboot
