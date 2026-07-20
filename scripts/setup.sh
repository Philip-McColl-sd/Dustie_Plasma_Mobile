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
# Step 8: Set Plasma Mobile Lock Screen as Default Login
################################################################################
log_info "Configuring Plasma Mobile lock screen as the login screen..."

# Make the Plasma Mobile lock screen the system-wide "login/welcome" screen.
# Effect: skip SDDM's plain desktop-style greeter; boot straight into the
# session and immediately show the phone-style lock screen instead. PIN/
# password is still required (security unchanged) - only the screen you
# authenticate on changes. Relogin=true means every logout goes straight
# back to the lock screen too, not the old greeter.
TARGET_USER="$(whoami)"

sudo mkdir -p /etc/sddm.conf.d
sudo tee /etc/sddm.conf.d/autologin.conf > /dev/null <<EOF
[Autologin]
User=${TARGET_USER}
Session=plasma-mobile.desktop
Relogin=true
EOF

# Lock the session ~2s after every login/boot, so the mobile lock screen
# (org.kde.plasma.mobileshell LockScreen.qml) is what the user actually
# sees and unlocks, every time. The 2s delay is a cheap guard to let the
# compositor/lock daemon come up before the lock call fires.
mkdir -p "$HOME/.config/autostart"
cat > "$HOME/.config/autostart/lock-on-login.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Lock on login
Exec=/bin/sh -c "sleep 2 && loginctl lock-session"
X-KDE-autostart-phase=2
NoDisplay=true
EOF

log_success "Plasma Mobile lock screen configured as default login"

################################################################################
# Step 9: Add "Switch Session" Button to the Logout Screen
################################################################################
log_info "Installing Switch Session button..."

# Adds a "Switch Session" button to the phone's power/logout screen that
# reaches the real SDDM greeter (session/DE picker) instead of the phone
# lock screen. Builds on the autologin setup from Step 8.

# 9.1 One-shot helper: hides autologin.conf and forces sddm to reload it.
#    Two non-obvious facts, both confirmed live:
#    - SDDM still reads a file inside /etc/sddm.conf.d/ even if you just
#      rename its extension (e.g. .conf.disabled) -- it must be moved
#      fully OUT of that directory.
#    - SDDM's daemon process reads config ONCE at startup and caches it.
#      A plain logout/display cycle within the same long-running sddm
#      process reuses the cached config and autologins anyway. Only a
#      full `systemctl restart sddm` makes it re-read the file, so this
#      helper schedules that restart a few seconds out (detached, since
#      this whole process/session gets torn down by the logout that
#      follows immediately after it runs).
sudo tee /usr/local/bin/plasma-mobile-disable-autologin-once.sh > /dev/null <<'EOF'
#!/bin/sh
mkdir -p /root/sddm-conf-backup
if [ -f /etc/sddm.conf.d/autologin.conf ]; then
    mv /etc/sddm.conf.d/autologin.conf /root/sddm-conf-backup/autologin.conf
fi
systemd-run --on-active=6s --description="Restart sddm to pick up disabled autologin" /usr/bin/systemctl restart sddm
EOF
sudo chmod 755 /usr/local/bin/plasma-mobile-disable-autologin-once.sh

# 9.2 The button is triggered from the GUI (no terminal to type a password
#    into), so it needs passwordless sudo for just this one helper script.
echo "${TARGET_USER} ALL=(root) NOPASSWD: /usr/local/bin/plasma-mobile-disable-autologin-once.sh" | \
    sudo tee /etc/sudoers.d/plasma-mobile-switch-session > /dev/null
sudo chmod 0440 /etc/sudoers.d/plasma-mobile-switch-session
sudo visudo -c -f /etc/sudoers.d/plasma-mobile-switch-session || error_exit "Invalid sudoers rule for switch-session"

# 9.3 Restore autologin automatically once a session starts normally again
#    (extends the lock-on-login.desktop from Step 8).
cat > "$HOME/.config/autostart/lock-on-login.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Lock on login
Exec=/bin/sh -c "sleep 2 && loginctl lock-session; if [ -f /root/sddm-conf-backup/autologin.conf ]; then sudo -n mv /root/sddm-conf-backup/autologin.conf /etc/sddm.conf.d/autologin.conf; fi"
X-KDE-autostart-phase=2
NoDisplay=true
EOF

# 9.4 Replace the logout screen's "switch user" button. The stock button
#    calls sessionManagement.switchUser(), which spawns a SECOND full
#    Wayland session concurrently with the first -- two compositors
#    fighting over this Pi's single GPU is what froze the display. This
#    version does a normal sequential logout instead (never two sessions
#    alive at once), after disabling autologin so the logout actually
#    lands on the real greeter.
LOGOUT_QML="/usr/share/plasma/look-and-feel/org.kde.breeze.mobile/contents/logout/Logout.qml"
if [ ! -f "$LOGOUT_QML" ]; then
    error_exit "Logout.qml not found at $LOGOUT_QML - is plasma-mobile fully installed?"
fi

if [ ! -f "${LOGOUT_QML}.backup" ]; then
    sudo cp "$LOGOUT_QML" "${LOGOUT_QML}.backup"
fi

sudo tee "$LOGOUT_QML" > /dev/null <<'EOF'
/*
 *   SPDX-FileCopyrightText: 2014 Aleix Pol Gonzalez <aleixpol@blue-systems.com>
 *   SPDX-FileCopyrightText: 2020 Linus Jahn <lnj@kaidan.im>
 *   SPDX-FileCopyrightText: 2020 Marco Martin <mart@kde.org
 *   SPDX-FileCopyrightText: 2022 Seshan Ravikumar <seshan10@me.com>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.8 as Controls

import org.kde.kirigami 2.20 as Kirigami
import org.kde.coreaddons 1.0 as KCoreAddons

import org.kde.plasma.private.sessions 2.0
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings
import org.kde.plasma.plasma5support as Plasma5Support

Item {
    id: root

    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
    Kirigami.Theme.inherit: false
    signal logoutRequested()
    signal haltRequested()
    signal suspendRequested(int spdMethod)
    signal rebootRequested()
    signal rebootRequested2(int opt)
    signal cancelRequested()
    signal lockScreenRequested()

    Controls.Action {
        onTriggered: root.cancelRequested()
        shortcut: "Escape"
    }

    SessionManagement {
        id: sessionManagement
    }

    // Runs plasma-mobile-disable-autologin-once.sh (passwordless sudo) so the
    // next SDDM display shows the real greeter/session-picker instead of
    // autologin silently re-entering plasma-mobile. Only logs out once this
    // finishes, so there is never a second concurrent Wayland session fighting
    // the first one for the GPU (that dual-session race is what froze the
    // display when this button used to call sessionManagement.switchUser()).
    Plasma5Support.DataSource {
        id: disableAutologinSource
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            disconnectSource(sourceName);
            closeAnim.closeToBlack = true;
            closeAnim.execute(root.logoutRequested);
        }
        function run() {
            connectSource("sudo -n /usr/local/bin/plasma-mobile-disable-autologin-once.sh");
        }
    }

    Rectangle {
        id: blackOverlay
        anchors.fill: parent
        color: "black"
        opacity: 0
        z: opacity > 0 ? 1 : 0
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: Kirigami.Theme.backgroundColor
        opacity: 0
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            closeAnim.execute(root.cancelRequested);
        }
    }

    Component.onCompleted: openAnim.restart()
    onVisibleChanged: {
        if (visible) {
            openAnim.restart()
        }
    }

    ParallelAnimation {
        id: openAnim
        running: true
        OpacityAnimator {
            target: buttons
            from: 0
            to: 1
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
        OpacityAnimator {
            target: background
            from: 0
            to: 0.6
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }

    SequentialAnimation {
        id: closeAnim
        running: false

        property bool closeToBlack: false
        property var callback
        function execute(call) {
            callback = call;
            closeAnim.restart();
        }
        ParallelAnimation {
            OpacityAnimator {
                target: buttons
                from: 1
                to: 0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
            OpacityAnimator {
                target: background
                from: 0.6
                to: 0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
            OpacityAnimator {
                target: blackOverlay
                from: 0
                to: closeAnim.closeToBlack ? 1 : 0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
        ScriptAction {
            script: {
                if (closeAnim.callback) {
                    closeAnim.callback();
                }
                buttons.opacity = 1;
                background.opacity = 0.6;
            }
        }
    }

    Item {
        id: buttons
        anchors.fill: parent
        opacity: 0

        ColumnLayout {
            anchors.centerIn: parent
            spacing: Kirigami.Units.gridUnit

            ActionButton {
                iconSource: "system-reboot"
                text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Restart")
                onClicked: {
                    closeAnim.closeToBlack = true;
                    closeAnim.execute(root.rebootRequested);
                }
            }

            ActionButton {
                iconSource: "system-shutdown"
                text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Shut Down")
                onClicked: {
                    closeAnim.closeToBlack = true;
                    closeAnim.execute(root.haltRequested);
                }
            }

            ActionButton {
                iconSource: "system-log-out"
                text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Log Out")
                visible: ShellSettings.Settings.allowLogout
                onClicked: {
                    closeAnim.closeToBlack = true;
                    closeAnim.execute(root.logoutRequested);
                }
            }

            ActionButton {
                iconSource: "system-switch-user"
                text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Switch Session")
                visible: ShellSettings.Settings.allowLogout
                onClicked: {
                    disableAutologinSource.run();
                }
            }
        }

        ActionButton {
            anchors {
                bottom: parent.bottom
                bottomMargin: Kirigami.Units.gridUnit
                horizontalCenter: parent.horizontalCenter
            }
            iconSource: "dialog-cancel"
            text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Cancel")
            onClicked: {
                closeAnim.closeToBlack = false;
                closeAnim.execute(root.cancelRequested);
            }
        }
    }
}
EOF

log_success "Switch Session button installed"

################################################################################
# Step 10: Optional Configurations
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
# Step 11: Verification
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

# Check if lock-screen-as-login is configured
if [ -f /etc/sddm.conf.d/autologin.conf ]; then
    log_success "Plasma Mobile lock screen login verified"
else
    log_warning "Lock screen login config not found (non-fatal)"
fi

# Check if the Switch Session button was installed
if [ -f /usr/local/bin/plasma-mobile-disable-autologin-once.sh ] && \
   grep -q "Switch Session" "$LOGOUT_QML" 2>/dev/null; then
    log_success "Switch Session button verified"
else
    log_warning "Switch Session button not found (non-fatal)"
fi

################################################################################
# Step 12: Installation Complete
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
echo "  2. After reboot, you will boot straight into the Plasma Mobile lock screen"
echo "  3. Unlock with your username and password"
echo "  4. Use power menu → 'Switch Session' to reach the SDDM greeter/session picker"
echo "  5. Enjoy your mobile Linux experience!"
echo ""
log_info "Optional configurations:"
echo "  - Rotate display: Edit $CONFIG_FILE and add 'display_rotate=1'"
echo "  - Install more apps: sudo apt search <app-name>"
echo "  - Configure keyboard: Settings → Input Devices → Keyboard"
echo "  - Undo lock-screen-as-login: sudo rm /etc/sddm.conf.d/autologin.conf ~/.config/autostart/lock-on-login.desktop"
echo "  - Undo Switch Session button: sudo cp ${LOGOUT_QML}.backup ${LOGOUT_QML}; sudo rm /usr/local/bin/plasma-mobile-disable-autologin-once.sh /etc/sudoers.d/plasma-mobile-switch-session"
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
