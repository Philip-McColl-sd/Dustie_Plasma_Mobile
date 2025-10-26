#!/bin/bash
################################################################################
# Plasma Mobile on Raspberry Pi 4 - Automated Installation Script
# 
# This script automates the installation of Plasma Mobile on Raspberry Pi 4
# using Raspberry Pi OS (64-bit) Lite as the base system.
#
# Prerequisites:
#   - Fresh Raspberry Pi OS (64-bit) Lite installation
#   - Internet connection (Ethernet recommended)
#   - Sudo privileges
#
# Usage:
#   wget https://raw.githubusercontent.com/YOUR_USERNAME/plasma-mobile-rpi4/main/install.sh
#   chmod +x install.sh
#   ./install.sh
#
# Or one-liner:
#   curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/plasma-mobile-rpi4/main/install.sh | bash
#
# Version: 1.0
# Date: 2025-10-25
# Tested: Raspberry Pi 4B (4GB), Raspberry Pi OS Lite 64-bit
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Error handler
error_exit() {
    log_error "$1"
    exit 1
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    error_exit "Please do not run this script as root. Run as normal user with sudo privileges."
fi

# Check if sudo is available
if ! command -v sudo &> /dev/null; then
    error_exit "sudo is required but not found. Please install sudo first."
fi

# Banner
echo "################################################################################"
echo "#                                                                              #"
echo "#           Plasma Mobile on Raspberry Pi 4 - Auto Installer                  #"
echo "#                                                                              #"
echo "#  This script will install Plasma Mobile on your Raspberry Pi 4              #"
echo "#  Total time: ~30-45 minutes depending on internet speed                     #"
echo "#                                                                              #"
echo "################################################################################"
echo ""

# Confirm before proceeding
read -p "Do you want to continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Installation cancelled."
    exit 0
fi

################################################################################
# Step 1: System Information
################################################################################
log_info "Gathering system information..."

# Check if running on Raspberry Pi
if [ ! -f /proc/device-tree/model ]; then
    log_warning "Unable to detect Raspberry Pi model"
else
    PI_MODEL=$(cat /proc/device-tree/model)
    log_info "Detected: $PI_MODEL"
    
    if [[ ! "$PI_MODEL" =~ "Raspberry Pi 4" ]]; then
        log_warning "This script is designed for Raspberry Pi 4. Your device: $PI_MODEL"
        read -p "Continue anyway? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 0
        fi
    fi
fi

# Check architecture
ARCH=$(uname -m)
log_info "Architecture: $ARCH"

if [[ "$ARCH" != "aarch64" ]]; then
    log_warning "This script requires ARM64 architecture. Detected: $ARCH"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

# Check Debian version
if [ -f /etc/os-release ]; then
    . /etc/os-release
    log_info "OS: $PRETTY_NAME"
fi

################################################################################
# Step 2: Network Connectivity Check
################################################################################
log_info "Checking network connectivity..."

if ! ping -c 1 8.8.8.8 &> /dev/null; then
    error_exit "No internet connection detected. Please connect to internet and try again."
fi

log_success "Network connectivity confirmed"

################################################################################
# Step 3: Disable IPv6 (Critical for package downloads)
################################################################################
log_info "Configuring IPv6 settings..."

# Check if already configured
if grep -q "net.ipv6.conf.all.disable_ipv6" /etc/sysctl.conf; then
    log_info "IPv6 already disabled in sysctl.conf"
else
    log_info "Disabling IPv6 to prevent download issues..."
    
    # Backup original sysctl.conf
    sudo cp /etc/sysctl.conf /etc/sysctl.conf.backup
    
    # Add IPv6 disable configuration
    echo "" | sudo tee -a /etc/sysctl.conf > /dev/null
    echo "# Disable IPv6 for Plasma Mobile installation" | sudo tee -a /etc/sysctl.conf > /dev/null
    echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf > /dev/null
    echo "net.ipv6.conf.default.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf > /dev/null
    echo "net.ipv6.conf.lo.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf > /dev/null
    
    # Apply changes
    sudo sysctl -p > /dev/null
    
    log_success "IPv6 disabled successfully"
fi

################################################################################
# Step 4: System Update
################################################################################
log_info "Updating system packages (this may take 5-10 minutes)..."

# Update package lists
sudo apt-get update -y || error_exit "Failed to update package lists"

# Upgrade existing packages
log_info "Upgrading system packages..."
sudo apt-get -o Acquire::ForceIPv4=true full-upgrade -y || error_exit "Failed to upgrade packages"

log_success "System updated successfully"

################################################################################
# Step 5: Install Plasma Mobile Packages
################################################################################
log_info "Installing Plasma Mobile (this may take 15-25 minutes)..."
log_warning "You may see warnings about 'delayed items' - this is normal!"

# Define packages to install
PLASMA_PACKAGES=(
    plasma-mobile
    plasma-mobile-tweaks
    plasma-settings
    plasma-phonebook
    plasma-dialer
    spacebar
    angelfish
    okular-mobile
    kscreen
)

# Install Plasma Mobile packages with IPv4 forcing
sudo apt-get -o Acquire::ForceIPv4=true install -y "${PLASMA_PACKAGES[@]}" || {
    log_error "Some packages failed to install. Retrying..."
    sudo apt-get -o Acquire::ForceIPv4=true install -y --fix-missing "${PLASMA_PACKAGES[@]}" || \
        error_exit "Failed to install Plasma Mobile packages"
}

log_success "Plasma Mobile packages installed"

################################################################################
# Step 6: Install SDDM Display Manager
################################################################################
log_info "Installing SDDM display manager..."

sudo apt-get -o Acquire::ForceIPv4=true install -y sddm || error_exit "Failed to install SDDM"

log_success "SDDM installed"

################################################################################
# Step 7: Configure System to Boot into Graphical Mode
################################################################################
log_info "Configuring graphical boot..."

# Enable SDDM service
sudo systemctl enable sddm || error_exit "Failed to enable SDDM"

# Set default target to graphical
sudo systemctl set-default graphical.target || error_exit "Failed to set graphical target"

log_success "Graphical boot configured"

################################################################################
# Step 8: Optional Configurations
################################################################################
log_info "Applying optional configurations..."

# Increase GPU memory for better performance
if [ -f /boot/firmware/config.txt ]; then
    CONFIG_FILE="/boot/firmware/config.txt"
elif [ -f /boot/config.txt ]; then
    CONFIG_FILE="/boot/config.txt"
else
    log_warning "Could not find config.txt"
    CONFIG_FILE=""
fi

if [ -n "$CONFIG_FILE" ]; then
    if ! grep -q "gpu_mem" "$CONFIG_FILE"; then
        log_info "Setting GPU memory to 256MB..."
        sudo cp "$CONFIG_FILE" "${CONFIG_FILE}.backup"
        echo "" | sudo tee -a "$CONFIG_FILE" > /dev/null
        echo "# Plasma Mobile GPU configuration" | sudo tee -a "$CONFIG_FILE" > /dev/null
        echo "gpu_mem=256" | sudo tee -a "$CONFIG_FILE" > /dev/null
        log_success "GPU memory configured"
    fi
fi

################################################################################
# Step 9: Verification
################################################################################
log_info "Verifying installation..."

# Check if plasma-mobile package is installed
if dpkg -l | grep -q "plasma-mobile"; then
    log_success "Plasma Mobile package verified"
else
    error_exit "Plasma Mobile package not found"
fi

# Check if SDDM is installed
if command -v sddm &> /dev/null; then
    log_success "SDDM verified"
else
    error_exit "SDDM not found"
fi

# Check if graphical target is set
if systemctl get-default | grep -q "graphical.target"; then
    log_success "Graphical target verified"
else
    error_exit "Graphical target not set correctly"
fi

################################################################################
# Step 10: Installation Complete
################################################################################
echo ""
echo "################################################################################"
echo "#                                                                              #"
echo "#                    INSTALLATION COMPLETED SUCCESSFULLY!                      #"
echo "#                                                                              #"
echo "################################################################################"
echo ""
log_success "Plasma Mobile has been installed successfully!"
echo ""
log_info "Next steps:"
echo "  1. Reboot your Raspberry Pi: sudo reboot"
echo "  2. After reboot, you will see the Plasma Mobile login screen"
echo "  3. Login with your username and password"
echo "  4. Enjoy your mobile Linux experience!"
echo ""
log_info "Optional configurations:"
echo "  - Rotate display: Edit $CONFIG_FILE and add 'display_rotate=1'"
echo "  - Install more apps: sudo apt search <app-name>"
echo "  - Configure keyboard: Settings → Input Devices → Keyboard"
echo ""
log_info "Troubleshooting:"
echo "  - If screen is black: sudo systemctl restart sddm"
echo "  - Check logs: journalctl -xe"
echo "  - SSH access: ssh $(whoami)@$(hostname -I | awk '{print $1}')"
echo ""

# Ask if user wants to reboot now
read -p "Do you want to reboot now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_info "Rebooting in 5 seconds... Press Ctrl+C to cancel"
    sleep 5
    sudo reboot
else
    log_info "Please remember to reboot manually: sudo reboot"
fi

exit 0
