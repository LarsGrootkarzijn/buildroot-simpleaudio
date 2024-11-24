#!/bin/bash

ALPINE_URL=https://dl-cdn.alpinelinux.org/alpine/v3.20/releases/armhf/
ALPINE_VERSION=alpine-minirootfs-3.20.3-armhf.tar.gz

#cd ./buildroot-simpleaudio

# Clone Simple Audio HifiberryOS external configuration only if the folder doesn't exist
if [ ! -d "./hifiberry-os-simpleaudio" ]; then
    echo "Cloning Simple Audio HifiberryOS external configuration"
    git clone https://github.com/LarsGrootkarzijn/hifiberry-os-simpleaudio.git
fi

if [ ! -d "./output" ]; then
    echo "Create output directory"
    mkdir ./output
fi

# Run get-buildroot only if the buildroot folder does not exist
if [ ! -d "./buildroot" ]; then
    echo "Run get-buildroot from HifiberryOS, as we need a compatible version with HifiberryOS"

    cd ./hifiberry-os-simpleaudio
    ./get-buildroot
    cd ..
fi

# Create symbolic link only if it doesn't already exist
if [ ! -L "./hifiberry-os" ]; then
    ln -s hifiberry-os-simpleaudio hifiberry-os
fi

if [ ! -d "./ti-sdk" ]; then
	echo "Getting TI-SDK"
	mkdir ./ti-sdk
	cd ./ti-sdk
	wget https://dr-download.ti.com/software-development/software-development-kit-sdk/MD-1BUptXj3op/09.01.00.001/ti-processor-sdk-linux-am335x-evm-09.01.00.001-Linux-x86-Install.bin 
	chmod a+x ./ti-processor-sdk-linux-am335x-evm-09.01.00.001-Linux-x86-Install.bin
	./ti-processor-sdk-linux-am335x-evm-09.01.00.001-Linux-x86-Install.bin --prefix ./ --mode unattended
	cd ..
fi

if [ ! -d "./initramfs" ]; then
	echo "Getting initramfs Alpine"
	mkdir ./initramfs
	cd ./initramfs
	wget $ALPINE_URL$ALPINE_VERSION
	tar -xf ./$ALPINE_VERSION
	rm ./$ALPINE_VERSION
	find . -print0 | cpio --null -ov --format=newc | gzip -9 > initramfs.cpio.gz
fi

echo "Set Simple Audio Kernel config"
cp ./configs/kernel/.config ./ti-sdk/board-support/ti-linux-kernel-6.1.46+gitAUTOINC+1d4b5da681-g1d4b5da681/.config
if [ $? -ne 0 ]; then
  echo "Failed to copy kernel config."
fi

echo "Placing Roomplayer DTS in DTS boot folder."
cp ./device-trees/kernel/roomplayer.dts ./ti-sdk/board-support/ti-linux-kernel-6.1.46+gitAUTOINC+1d4b5da681-g1d4b5da681/arch/arm/boot/dts/
if [ $? -ne 0 ]; then
  echo "Failed to copy roomplayer.dts to the boot folder."
fi

echo "Set Simple Audio Buildroot config"
cp ./configs/buildroot/.config ./buildroot/.config
if [ $? -ne 0 ]; then
  echo "Failed to copy Buildroot config."
fi
