# Dustie_Plasma_Mobile
Intended to document the configuration of Ubuntu with raspberry pi and touch friendly kde-plasma

# Download and Flash Ubuntu Server

# Download Ubuntu Server for Raspberry Pi:

Visit ubuntu.com/download/raspberry-pi
Choose Ubuntu Server 24.04 LTS (or latest LTS) for Raspberry Pi 4
Select 64-bit version for better performance

# Configure for Headless Boot
Before first boot, you need to configure network and SSH access:
## Using Raspberry Pi Imager (Easiest)

### Open Raspberry Pi Imager
Choose "Other general-purpose OS" → "Ubuntu" → Select Ubuntu Server
Click the gear icon (⚙) for advanced options
Configure:

- Set hostname
- Enable SSH with password or SSH key
- Set username and password
- Configure WiFi (SSID and password)
- Set locale and timezone

# Insert the SD card and boot raspberry pi and proceed with:
## Step 1: Initial System Configuration
First, let's update everything and prepare the system:
bash# Update package lists and upgrade system
sudo apt update && sudo apt upgrade -y

# Install essential packages
sudo apt install -y software-properties-common ubuntu-desktop-minimal xorg

# Set your timezone (optional)
sudo dpkg-reconfigure tzdata

# Configure your locale if needed
sudo dpkg-reconfigure locales

## Step 2: Enable Universe Repository
Plasma Mobile packages require the universe repository:
bashsudo add-apt-repository universe
sudo apt update

# NOW, let's check what Ubuntu version you have:
bashlsb_release -a

# Then Add KDE's repositories for more Plasma packages:
bash# Add Kubuntu PPA for more KDE/Plasma packages
sudo add-apt-repository ppa:kubuntu-ppa/backports
sudo apt update

# Install KDE Plasma Desktop first, then add mobile components
Since full Plasma Mobile isn't in Ubuntu's standard repos, you might have better luck with:
bash# Install full KDE Plasma desktop
sudo apt install -y kubuntu-desktop

# Then add touch-friendly settings
sudo apt install -y plasma-integration kde-config-sddm
