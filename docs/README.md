# Plasma Mobile on Raspberry Pi 4 - Complete Installation Guide

**The definitive step-by-step manual for installing Plasma Mobile on Raspberry Pi 4**

## Summary
This guide documents the proven installation method for Plasma Mobile on a Raspberry Pi 4B using Raspberry Pi OS (64-bit) Lite as the base system. After 2 years of research and testing, this is the ONLY method that works reliably.

## Why This Method Works

**The Problem:**
- Ubuntu Server does NOT have plasma-mobile packages
- Manjaro ARM does NOT have a pre-built Plasma Mobile image for RPi4
- Mobian does NOT officially support Raspberry Pi 4
- postmarketOS requires building from source (complex)

**The Solution:**
- Raspberry Pi OS is based on Debian Bookworm
- Debian Bookworm HAS plasma-mobile packages in its repositories
- We can install a minimal OS and add Plasma Mobile on top

---

## Prerequisites

### Hardware Required:
- Raspberry Pi 4B (4GB+ RAM recommended)
- MicroSD card (16GB minimum, 32GB+ recommended)
- Power supply for Raspberry Pi 4
- Ethernet cable (for initial setup) OR WiFi credentials
- Another computer (for flashing the SD card)

### Software Required:
- [Raspberry Pi Imager](https://www.raspberrypi.com/software/)
- SSH client (built into Linux/Mac/Windows)

---

## Step 1: Download and Flash Raspberry Pi OS

### 1.1 Download Raspberry Pi OS
- Use **Raspberry Pi OS Lite (64-bit)**
- NOT the full desktop version
- 64-bit for better ARM64 performance

### 1.2 Flash with Raspberry Pi Imager

**Important Configuration:**
When Raspberry Pi Imager asks "Would you like to apply OS customization settings?" - click **EDIT SETTINGS**

**Configure ONLY these settings:**
- ✅ **Set username and password** (write them down!)
- ✅ **Enable SSH** (under Services tab)
- ❌ **Skip WiFi configuration** (configure later)
- ❌ **Skip hostname** (use default)
- ❌ **Skip locale settings** (configure later)

**Why minimal settings?** Too many pre-configurations can cause first-boot to hang.

### 1.3 First Boot
1. Insert SD card into Raspberry Pi 4
2. Connect ethernet cable (recommended) or have WiFi credentials ready
3. Power on the Pi
  
4. !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   **IMPORTANT:** When you see `completed socket interaction for boot stage final` - **JUST PRESS ENTER**!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   - The system is waiting for user input
   - This is normal behavior, not a hang

---

## Step 2: Initial Setup and SSH Access

### 2.1 Log In Locally
- Username: (whatever you set during flash)
- Password: (whatever you set during flash)

### 2.2 Find IP Address
```bash
hostname -I
```
Note the IP address (e.g., `192.168.1.50`)

### 2.3 Connect via SSH (from your laptop)
```bash
ssh username@###.###.#.## (e.g., ssh username@192.168.1.50)
```
Or try:
```bash
ssh username@raspberrypi.local
```

**Benefit:** Now you can copy/paste commands easily!

---

## Step 3: Configure WiFi (If Not Using Ethernet)

### Method 1: Using raspi-config (Easiest and it worked like a charm)
```bash
sudo raspi-config
```
1. Select "1 System Options"
2. Select "S1 Wireless LAN"
3. Enter your WiFi SSID
4. Enter your WiFi password
5. Exit and reboot if prompted

### Method 2: Manual Configuration
```bash
sudo nano /etc/wpa_supplicant/wpa_supplicant.conf
```

Add at the end:
```
network={
    ssid="YourWiFiName"
    psk="YourWiFiPassword"
}
```

Save (CTRL+X, Y, Enter) and restart networking (It was not needed):
```bash
sudo systemctl restart dhcpcd
```

---

## Step 4: Update System

```bash
sudo apt update && sudo apt full-upgrade -y
```

This may take 5-10 minutes. Wait for it to complete.

---

## Step 5: Install Plasma Mobile

```bash
sudo apt install -y plasma-mobile plasma-mobile-tweaks plasma-settings plasma-phonebook plasma-dialer spacebar angelfish okular-mobile kscreen
```

**What these packages do:**
- `plasma-mobile` - Main mobile UI shell
- `plasma-mobile-tweaks` - Touch-optimized improvements
- `plasma-settings` - Settings application
- `plasma-phonebook` - Contact management
- `plasma-dialer` - Phone dialer application
- `spacebar` - SMS/messaging app
- `angelfish` - Mobile web browser
- `okular-mobile` - Document viewer
- `kscreen` - Display management

This installation will take 10-20 minutes depending on your internet speed.

---

## Step 6: Configure Boot to Plasma Mobile

```bash
sudo systemctl set-default graphical.target
```

This tells the system to boot into graphical mode (Plasma Mobile) instead of text console.

---

## Step 7: Reboot

```bash
sudo reboot
```

The system will restart and boot directly into Plasma Mobile!

---

## Step 8: Connect Cellular Modem (Optional) — Waveshare SIM7600G-H 4G HAT

Adds cellular voice/data hardware via the Waveshare SIM7600G-H LTE HAT. This
procedure is confirmed working for network registration, packet-service
attach, and a successful voice call.

### 8.1 Physical Setup (do all of this BEFORE powering anything on)

1. **Insert the SIM** fully, correct orientation, until it clicks/seats
   completely.
   - The modem only checks for a SIM at its own power-on — a hot-swap while
     it's running will **not** be detected. This must happen before step 8.2.

2. **Firmly click both antennas** onto the HAT:
   - **MAIN** is required (TX+RX)
   - **AUX** is optional but recommended (RX diversity)
   - Press straight down until you feel/hear the u.FL connector seat. A loose
     MAIN antenna gives good-looking signal readings but silent attach
     failures (weak uplink, fine downlink) — this is the single biggest
     source of wasted troubleshooting time.

3. **Seat the HAT firmly** on the Pi's GPIO header.

### 8.2 Power On (once, cleanly)

4. Power the Pi, then power the modem (hold the PWR button ~2-3s).
   Don't touch the SIM or antennas again after this point — if you do, you
   must repeat a full power cycle. Hot-adjustments don't get picked up.

### 8.3 Verify Registration

5. Wait ~30-60s, then check:
   ```bash
   mmcli -L
   mmcli -m 0
   ```
   Look for:
   ```
   state: registered
   registration: home
   packet service state: attached
   ```
   Getting stuck on "searching" for 90s+ almost never resolves itself by
   waiting longer or poking it with AT commands — the fix is always a clean
   power cycle with SIM/antenna properly seated, not live reconfiguration.

### 8.4 Test a Voice Call

6. Once registered and attached, dial with:
   ```bash
   sudo mmcli -m 0 --voice-create-call="number=+56XXXXXXXXX"
   ```
   (needs `sudo` — PolicyKit blocks the Voice interface for a regular user by
   default)

   Watch call state via:
   ```bash
   mmcli --call=<path>
   ```
   Expected progression: `dialing` -> `ringing-out` -> `answered`

   If it stays stuck in `dialing` and self-terminates after ~30s, that's a
   registration/attach problem, not a dialing problem — go back to 8.2-8.3.

   **Note:** this only gets you call signaling (ring/connect/hangup). Actual
   audio needs the HAT's SPK+/SPK-/MIC+/MIC- pins wired to a real
   speaker/mic — not covered by this procedure.

### 8.5 What Not To Do

- Don't chase registration issues with live `AT+COPS` / `AT+CNMP` mode
  switching while troubleshooting — it's easy to leave the modem in a bad
  manually-locked state, which makes things worse. If it's stuck, power
  cycle instead of reconfiguring.
- `mmcli -m X --command=...` needs ModemManager restarted in debug mode:
  ```bash
  sudo systemctl stop ModemManager
  sudo /usr/sbin/ModemManager --debug &
  ```
  Otherwise you get `Unauthorized: debug mode`. Remember to restore the
  normal service afterward:
  ```bash
  sudo systemctl start ModemManager
  ```

### 8.6 Still Open

Data/internet setup (NetworkManager GSM connection + APN) is not yet
configured. The registered/attached state from 8.3 is the prerequisite,
which is now reliably achievable via the procedure above.

---

## Post-Installation Configuration

### Setting Up Keyboard Layout
If you need to change keyboard layout (e.g., for Spanish keyboard):
1. Open Plasma Mobile Settings
2. Navigate to Input Devices → Keyboard
3. Select your keyboard layout

### Performance Optimization
For better performance, you can adjust GPU memory in `/boot/firmware/config.txt`:
```bash
sudo nano /boot/firmware/config.txt
```

Add or modify:
```
gpu_mem=256
```

### Installing Additional Apps
You can install more applications from Debian repositories:
```bash
sudo apt search <app-name>
sudo apt install <app-name>
```

---

## Troubleshooting

### Issue: Boot Hangs at "completed socket interaction"
**Solution:** Just press ENTER. The system is waiting for user input.

### Issue: Can't connect to WiFi with nmtui
**Solution:** Raspberry Pi OS Lite doesn't use NetworkManager. Use `raspi-config` instead.

### Issue: No GUI after reboot
**Solution:** Check if services started properly:
```bash
sudo systemctl status sddm
```

Restart display manager:
```bash
sudo systemctl restart sddm
```

### Issue: Touch screen not working
**Solution:** Most USB touchscreens should work. If not, check:
```bash
dmesg | grep -i touch
```

### Issue: Plasma Mobile is slow
**Solutions:**
- Make sure you're using a fast SD card (Class 10/A1 or better)
- Consider using a Pi 4 with 4GB+ RAM
- Increase GPU memory allocation
- Consider using an SSD instead of SD card

### Issue: SIM7600G-H modem stuck "searching" and never registers
**Solution:** Power cycle with the SIM and both antennas properly seated
(see Step 8.1-8.2). Waiting longer or sending AT commands rarely helps —
a hot SIM swap or a loose MAIN antenna won't be detected until a fresh
power-on.

### Issue: Voice call stays in "dialing" and self-terminates (~30s)
**Solution:** This is a registration/attach problem, not a dialing problem.
Re-check `mmcli -m 0` shows `state: registered` and `packet service state:
attached` (Step 8.3) before retrying the call.

### Issue: `mmcli -m X --command=...` returns "Unauthorized: debug mode"
**Solution:** ModemManager needs to be running in debug mode for that
command:
```bash
sudo systemctl stop ModemManager
sudo /usr/sbin/ModemManager --debug &
```
Restore the normal service afterward with `sudo systemctl start ModemManager`.

---

## What Worked vs What Didn't

### ✅ What WORKED:
- **Raspberry Pi OS (64-bit) Lite + manual plasma-mobile installation**
- Debian Bookworm has all necessary packages
- SSH access for easier command entry
- Minimal flash configuration to avoid boot issues

### ❌ What DIDN'T Work:
- **Ubuntu Server** - No plasma-mobile packages available
- **Manjaro ARM** - No pre-built Plasma Mobile image for RPi4
- **Mobian** - Doesn't support Raspberry Pi 4
- **postmarketOS pre-built images** - Don't exist for RPi4 (requires building from source)
- **Raspberry Pi OS with full pre-configuration** - Caused boot hangs

---

## Why Debian/Raspberry Pi OS Works

The key difference is that **Debian includes plasma-mobile packages in its repositories**, while Ubuntu does not.

You can verify package availability:
- Debian Bookworm: https://packages.debian.org/bookworm/plasma-mobile
- Ubuntu: No equivalent package

Since Raspberry Pi OS is based on Debian Bookworm, it has access to all Debian packages, including plasma-mobile.

---

## Credits and Resources

### Official Documentation:
- [Plasma Mobile Website](https://plasma-mobile.org/)
- [KDE Community Wiki](https://community.kde.org/)
- [Debian Plasma Mobile Packages](https://packages.debian.org/search?keywords=plasma-mobile)
- [Raspberry Pi Documentation](https://www.raspberrypi.com/documentation/)

### Alternative Options (Advanced Users):
- **postmarketOS** - Build your own image using pmbootstrap
- **Manjaro ARM KDE** - Install base system, then manually add plasma-mobile packages

---

## Final Notes

This installation gives you:
- ✅ A working mobile Linux interface on Raspberry Pi 4
- ✅ Touch-optimized UI
- ✅ Mobile apps (browser, dialer, messages, etc.)
- ✅ Access to full Debian package repositories
- ✅ Regular security updates via `apt`

**Limitations:**
- Not all hardware features may work perfectly (depends on your specific setup)
- Performance depends heavily on SD card speed and RAM amount
- Some mobile-specific features (GPS, cellular) require additional hardware —
  cellular voice/registration is covered in Step 8 (Waveshare SIM7600G-H
  4G HAT); mobile data (APN/NetworkManager GSM connection) is still open

---

## Changelog

**2026-07-20:** Added Step 8 — Cellular Modem (Waveshare SIM7600G-H 4G HAT)
- Documented physical setup, power-on sequence, registration check, and a
  confirmed-working voice call procedure
- Added related troubleshooting entries and updated Limitations
- Data/internet (APN) setup remains open for a future update

**2025-10-25:** Initial guide created after successful installation
- Documented the working solution: Raspberry Pi OS + apt install
- Added troubleshooting for common issues
- Explained why other distributions didn't work

---

**Generated:** October 25, 2025  
**Tested on:** Raspberry Pi 4B  
**OS Version:** Raspberry Pi OS (64-bit) Lite, based on Debian Bookworm  
**Plasma Mobile Version:** Available in Debian Bookworm repositories
