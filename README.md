Follow these steps to upgrade your Simple Audio Roomplayer+ to HifiBerryOS with kernel upgrade to 6.1.

# 1. SSH into your Roomplayer
ssh root@YOUR_IP

# 2. Download the upgrade script
wget https://github.com/LarsGrootkarzijn/buildroot-simpleaudio/releases/download/v0.1.3/upgrade-roomplayer.sh

# 3. Make the script executable
chmod +x upgrade-roomplayer.sh

# 4. Run the upgrade script
./upgrade-roomplayer.sh

⚠️ Important:

    The upgrade process takes 10–20 minutes.

    Do not unplug the power during the upgrade.

    Wait until the system automatically reboots.

# 5. After reboot, open your browser and go to:
http://hifiberry.local

Follow the setup steps in the web interface, and you're done!
