#!/bin/sh

# Clone Simple Audio HifiberryOS external configuration only if the folder doesn't exist
if [ ! -d "./hifiberry-os-simpleaudio" ]; then
    echo "Cloning Simple Audio HifiberryOS external configuration"
    git clone https://github.com/LarsGrootkarzijn/hifiberrys-os-simpleaudio.git
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

echo "Set Simple Audio Buildroot config"

cd ./buildroot/
make BR2_DEFCONFIG=../configs/buildroot/roomplayer-buildroot-config defconfig

echo "Building, this can tak hours"
make BR2_EXTERNAL=../hifiberry-os/buildroot
