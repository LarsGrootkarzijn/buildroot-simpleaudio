#!/bin/bash

# Define variables
IMAGE_NAME="disk_image.img"
ROOTFS_TAR="../buildroot/output/images/rootfs.tar"

# Create a 4GB image file with a block size of 256KB
dd if=/dev/zero of=${IMAGE_NAME} bs=256K count=14800

# Create partitions in the image
# This will use 'sfdisk' for non-interactive partitioning
sfdisk ${IMAGE_NAME} << EOF
,50M,c
,1G,83
,1G,83
,,83
EOF

# Map image to loop device
loop_device=$(losetup -f --show -P ${IMAGE_NAME})

# Format partitions
mkfs.vfat -n "BOOT" ${loop_device}p1     # Partition 1 (50MB VFAT for kernel/bootloader)
mkfs.ext4 -L "rootfs1" ${loop_device}p2  # Partition 2 (1GB ext4 root filesystem)
mkfs.ext4 -L "rootfs2" ${loop_device}p3  # Partition 3 (1GB ext4 second root filesystem)
mkfs.ext4 -L "DATA" ${loop_device}p4     # Partition 4 (Remaining space as ext4 for data)

# Mount partition 2
mkdir -p /mnt/rootfs2
mount ${loop_device}p2 /mnt/rootfs2

# Check if the rootfs.tar file exists
if [[ -f ${ROOTFS_TAR} ]]; then
    # Copy and extract the rootfs.tar into partition 2
    tar -xvf ${ROOTFS_TAR} -C /mnt/rootfs2
else
    echo "Error: ${ROOTFS_TAR} not found!"
    exit 1
fi

# Unmount the partition
umount /mnt/rootfs2

# Unmount the loop device
losetup -d ${loop_device}

gzip -k -f $IMAGE_NAME
echo "Disk image created, partitions formatted, and root filesystem extracted successfully!"
