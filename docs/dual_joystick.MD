# Dual KY-023 Joystick Controller for Raspberry Pi 4

A complete guide for connecting two KY-023 dual-axis joystick modules to a Raspberry Pi 4 Model B using an ADS1118/ADS1018 16-bit analog-to-digital converter via SPI interface.

![Project Status](https://img.shields.io/badge/status-active-success.svg)
![Hardware](https://img.shields.io/badge/hardware-Raspberry%20Pi%204-red.svg)
![Python](https://img.shields.io/badge/python-3.7+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## 📋 Table of Contents

- [Overview](#overview)
- [Hardware Requirements](#hardware-requirements)
- [Wiring Diagram](#wiring-diagram)
- [Software Installation](#software-installation)
- [File Transfer Methods](#file-transfer-methods)
- [Usage](#usage)
- [API Reference](#api-reference)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## 🎯 Overview

This project provides a complete Python-based solution for interfacing two analog joysticks with a Raspberry Pi 4. Since the Raspberry Pi lacks built-in analog inputs, we use an ADS1118 16-bit ADC with SPI communication.

### Features

- ✅ Dual joystick support (4 analog channels total)
- ✅ 16-bit resolution ADC readings
- ✅ Normalized output (-1.0 to +1.0)
- ✅ Configurable dead zone
- ✅ Automatic calibration routine
- ✅ Button support for both joysticks
- ✅ Directional detection (8 directions + center)
- ✅ Real-time visual monitoring
- ✅ Easy-to-use Python API

## 🔧 Hardware Requirements

| Component | Quantity | Notes |
|-----------|----------|-------|
| Raspberry Pi 4 Model B | 1 | Any RAM variant works |
| KY-023 Joystick Module | 2 | Dual-axis with button |
| ADS1118 ADC Module | 1 | 16-bit SPI (ADS1018 also compatible) |
| Jumper Wires | ~20 | Male-to-female recommended |
| Breadboard (optional) | 1 | Makes wiring easier |
| Soldering Iron | 1 | For header pins (optional) |

### Component Specifications

#### KY-023 Joystick Module
- **Axes:** 2 (X and Y)
- **Output:** Analog voltage (0-5V)
- **Button:** Tactile switch (active LOW)
- **Potentiometers:** 10kΩ each
- **Supply Voltage:** 5V
- **Pins:** VCC, GND, X-OUT (VRx), Y-OUT (VRy), SW

#### ADS1118 ADC Module
- **Resolution:** 16-bit
- **Interface:** SPI
- **Input Channels:** 4 single-ended or 2 differential
- **Input Range:** Programmable (±256mV to ±6.144V)
- **Supply Voltage:** 2V to 5.5V (3.3V recommended)
- **Sample Rate:** Up to 860 SPS

## 🔌 Wiring Diagram

### Connection Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    RASPBERRY PI 4 MODEL B                    │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Pin 1  (3.3V)  ●─────────────────────► ADC VDD             │
│  Pin 2  (5V)    ●─────────────┬────────► Joystick 1 VCC     │
│  Pin 4  (5V)    ●─────────────┴────────► Joystick 2 VCC     │
│  Pin 6  (GND)   ●────────┬──────┬──────► Common Ground      │
│  Pin 11 (GPIO17)●────────┼──────┼──────► Joystick 1 Button  │
│  Pin 13 (GPIO27)●────────┼──────┼──────► Joystick 2 Button  │
│  Pin 19 (MOSI)  ●────────┼──────┼──────► ADC DIN            │
│  Pin 21 (MISO)  ●────────┼──────┼──────► ADC DOUT           │
│  Pin 23 (SCLK)  ●────────┼──────┼──────► ADC SCLK           │
│  Pin 24 (CE0)   ●────────┼──────┼──────► ADC CS             │
│                          │      │                            │
└──────────────────────────┼──────┼────────────────────────────┘
                           │      │
        ┌──────────────────┴──────┴────────────────┐
        │                                           │
   ┌────▼─────────────────┐    ┌─────────────────▼────┐
   │  ADS1118 ADC MODULE  │    │  COMMON GROUND BUS   │
   ├──────────────────────┤    └──────────────────────┘
   │  A0 ◄─── Joy1 X-OUT  │         │      │      │
   │  A1 ◄─── Joy1 Y-OUT  │         │      │      │
   │  A2 ◄─── Joy2 X-OUT  │         │      │      │
   │  A3 ◄─── Joy2 Y-OUT  │         │      │      │
   │  GND ────────────────┼─────────┘      │      │
   └──────────────────────┘                │      │
                                           │      │
        ┌──────────────────────────────────┘      │
        │  ┌──────────────────────────────────────┘
        │  │
   ┌────▼──▼──────────┐    ┌─────────────────────┐
   │  JOYSTICK 1      │    │  JOYSTICK 2         │
   │  (KY-023)        │    │  (KY-023)           │
   ├──────────────────┤    ├─────────────────────┤
   │  VCC ──► 5V      │    │  VCC ──► 5V         │
   │  GND ──► GND     │    │  GND ──► GND        │
   │  X-OUT ──► A0    │    │  X-OUT ──► A2       │
   │  Y-OUT ──► A1    │    │  Y-OUT ──► A3       │
   │  SW ──► GPIO17   │    │  SW ──► GPIO27      │
   └──────────────────┘    └─────────────────────┘
```

### Detailed Pin Connections

#### Raspberry Pi 4 to ADC (SPI Connection)

| ADS1118 Pin | Function | Raspberry Pi Pin | BCM GPIO | Physical Pin |
|-------------|----------|------------------|----------|--------------|
| VDD         | Power    | 3.3V             | -        | 1 or 17      |
| GND         | Ground   | GND              | -        | 6, 9, 14, 20, 25, 30, 34, or 39 |
| SCLK        | SPI Clock| SPI0 SCLK        | GPIO 11  | 23           |
| DIN         | Data In  | SPI0 MOSI        | GPIO 10  | 19           |
| DOUT        | Data Out | SPI0 MISO        | GPIO 9   | 21           |
| CS          | Chip Select | SPI0 CE0      | GPIO 8   | 24           |

#### Joystick 1 Connections

| KY-023 Pin | Connection           | Notes |
|------------|----------------------|-------|
| VCC        | Raspberry Pi 5V (Pin 2 or 4) | Power supply |
| GND        | Raspberry Pi GND     | **Must be common ground** |
| X-OUT      | ADC Channel A0       | Analog X-axis output |
| Y-OUT      | ADC Channel A1       | Analog Y-axis output |
| SW         | Raspberry Pi GPIO 17 (Pin 11) | Button (active LOW) |

#### Joystick 2 Connections

| KY-023 Pin | Connection           | Notes |
|------------|----------------------|-------|
| VCC        | Raspberry Pi 5V (Pin 2 or 4) | Power supply |
| GND        | Raspberry Pi GND     | **Must be common ground** |
| X-OUT      | ADC Channel A2       | Analog X-axis output |
| Y-OUT      | ADC Channel A3       | Analog Y-axis output |
| SW         | Raspberry Pi GPIO 27 (Pin 13) | Button (active LOW) |

### ⚠️ Critical Wiring Notes

1. **Common Ground is Essential**: All GND pins (RPi, ADC, both joysticks) MUST be electrically connected together
2. **Power Supply Voltages**: 
   - Joysticks: 5V
   - ADC: 3.3V (can handle 5V inputs when configured properly)
3. **No Voltage Dividers Needed**: The ADS1118 can safely read 0-5V when configured with ±6.144V range
4. **Wire Length**: Keep wires as short as practical to minimize noise
5. **Button Pins**: Configured with internal pull-up resistors in software

### Soldering Temperature

For soldering header pins to modules:

- **With Lead Solder (60/40)**: 330-340°C (626-644°F)
- **Lead-Free Solder (SAC)**: 360-370°C (680-698°F)
- **Maximum**: Do not exceed 400°C
- **Contact Time**: 2-3 seconds per joint
- **Tip**: Use flux for better joints

## 💻 Software Installation

### Prerequisites

1. **Raspberry Pi OS** (Raspbian) installed and updated
2. **SSH enabled** (for remote access)
3. **Python 3.7+** (pre-installed on most Raspberry Pi OS versions)
4. **Internet connection** (for package installation)

### Step 1: Enable SPI Interface

```bash
# Method 1: Using raspi-config
sudo raspi-config
# Navigate to: Interface Options → SPI → Enable

# Method 2: Command line
sudo raspi-config nonint do_spi 0

# Reboot to apply changes
sudo reboot
```

### Step 2: Verify SPI is Enabled

```bash
# Check for SPI devices
ls /dev/spi*
# Should show: /dev/spidev0.0  /dev/spidev0.1

# Check if SPI module is loaded
lsmod | grep spi
# Should show: spi_bcm2835
```

### Step 3: Install System Dependencies

```bash
# Update package list
sudo apt-get update
sudo apt-get upgrade -y

# Install Python development tools
sudo apt-get install -y python3-pip python3-dev python3-rpi.gpio

# Install git (if you want to clone this repository)
sudo apt-get install -y git
```

### Step 4: Install Python Libraries

```bash
# Install required Python packages
pip3 install spidev RPi.GPIO

# Verify installation
python3 -c "import spidev; import RPi.GPIO; print('Libraries installed successfully!')"
```

### Step 5: Download Project Files

Choose one of the following methods:

#### Option A: Clone from GitHub

```bash
git clone https://github.com/yourusername/dual-joystick-controller.git
cd dual-joystick-controller
```

#### Option B: Download as ZIP

```bash
wget https://github.com/yourusername/dual-joystick-controller/archive/main.zip
unzip main.zip
cd dual-joystick-controller-main
```

#### Option C: Manual Download

Download individual files and transfer them to your Raspberry Pi (see [File Transfer Methods](#file-transfer-methods)).

### Step 6: Set Permissions

```bash
# Make Python scripts executable
chmod +x *.py *.sh

# Verify permissions
ls -l
```

### Step 7: Run Installation Script (Optional)

```bash
# Run the automated installation script
./install.sh
```

## 📦 File Transfer Methods

### Method 1: SCP (Secure Copy) - Recommended

From your computer to Raspberry Pi:

```bash
# Find your Raspberry Pi's IP address (on the RPi, run: hostname -I)

# Transfer all project files
scp *.py *.md *.txt *.sh pi@192.168.1.100:~/joystick_project/

# Or using hostname (if mDNS works)
scp *.py *.md *.txt *.sh pi@raspberrypi.local:~/joystick_project/

# Transfer single file
scp ads1118.py pi@raspberrypi.local:~/joystick_project/
```

### Method 2: USB Drive

**On your computer:**
1. Copy all project files to a USB drive

**On Raspberry Pi (via SSH):**

```bash
# Find USB device
lsblk

# Create mount point
sudo mkdir -p /mnt/usb

# Mount USB drive (adjust device name if needed)
sudo mount /dev/sda1 /mnt/usb

# Create project directory
mkdir -p ~/joystick_project

# Copy files from USB
sudo cp -r /mnt/usb/* ~/joystick_project/

# Fix ownership
sudo chown -R $USER:$USER ~/joystick_project/

# Make executable
chmod +x ~/joystick_project/*.py ~/joystick_project/*.sh

# Unmount USB
sudo umount /mnt/usb

# Verify files
ls -l ~/joystick_project/
```

### Method 3: SFTP

```bash
# Connect via SFTP
sftp pi@raspberrypi.local

# Navigate and upload
sftp> cd joystick_project
sftp> put ads1118.py
sftp> put joystick.py
sftp> put *.py
sftp> quit
```

### Method 4: RSYNC

```bash
# Sync entire directory with progress
rsync -avz --progress /path/to/files/ pi@raspberrypi.local:~/joystick_project/
```

### Method 5: GUI Tools

- **Windows**: [WinSCP](https://winscp.net/)
- **Cross-platform**: [FileZilla](https://filezilla-project.org/)

Connection details:
- Protocol: SFTP or SCP
- Host: `raspberrypi.local` or IP address
- Port: 22
- Username: `pi` (or your username)
- Password: Your Raspberry Pi password

## 🚀 Usage

### Quick Start Test

```bash
# Run simple continuous readout
python3 quick_test.py
```

Expected output:
```
Joy1: X:+0.02 Y:-0.01 Btn:N Dir:center      | Joy2: X:-0.03 Y:+0.00 Btn:N Dir:center
```

### Full Visual Test

```bash
# Run full test with ASCII visualization
python3 dual_joystick_test.py
```

This displays:
- Real-time ASCII art joystick visualization
- Normalized X/Y values (-1.0 to +1.0)
- Button state
- Directional detection
- Updates at 20Hz

### Test Individual Components

#### Test ADC Only

```bash
python3 ads1118.py
```

#### Test Single Joystick

```bash
python3 joystick.py
```

### Basic Python Usage

```python
#!/usr/bin/env python3
from ads1118 import ADS1118
from joystick import Joystick
import RPi.GPIO as GPIO
import time

# Initialize ADC
adc = ADS1118(bus=0, device=0)

# Initialize both joysticks
joy1 = Joystick(adc, x_channel=0, y_channel=1, button_pin=17, name="Joy1")
joy2 = Joystick(adc, x_channel=2, y_channel=3, button_pin=27, name="Joy2")

try:
    while True:
        # Read normalized values (-1.0 to +1.0)
        pos1 = joy1.read_normalized()
        pos2 = joy2.read_normalized()
        
        # Get directional input
        dir1 = joy1.get_direction()
        dir2 = joy2.get_direction()
        
        print(f"Joy1: X={pos1['x']:+.2f} Y={pos1['y']:+.2f} "
              f"Button={'PRESSED' if pos1['button'] else 'Released'} "
              f"Direction={dir1}")
        
        time.sleep(0.1)
        
except KeyboardInterrupt:
    print("\nExiting...")
finally:
    GPIO.cleanup()
    adc.close()
```

### Calibration

For best results, calibrate each joystick:

```python
# Calibration process (5 seconds)
joy1.calibrate(duration=5)
joy2.calibrate(duration=5)
```

During calibration:
1. Leave joystick centered for 2 seconds
2. Move joystick to all extremes (up, down, left, right, diagonals)
3. System records min/max/center values

### Advanced Configuration

```python
# Adjust dead zone (default 0.1 = 10%)
joy1.deadzone = 0.15  # Increase dead zone

# Custom gain setting for ADC
voltage = adc.read_adc_single_ended(
    channel=0, 
    gain=ADS1118.PGA_4_096V  # Use ±4.096V range
)

# Read raw voltage values
raw = joy1.read_raw()
print(f"X: {raw['x']:.3f}V, Y: {raw['y']:.3f}V")

# Read internal temperature
temp = adc.read_temperature()
print(f"ADC Temperature: {temp:.2f}°C")
```

## 📚 API Reference

### ADS1118 Class

#### Constructor

```python
ADS1118(bus=0, device=0, max_speed_hz=1000000)
```

**Parameters:**
- `bus` (int): SPI bus number (usually 0)
- `device` (int): SPI device number (0 for CE0, 1 for CE1)
- `max_speed_hz` (int): SPI clock speed in Hz (default 1MHz)

#### Methods

##### `read_adc_single_ended(channel, gain=PGA_6_144V)`

Read single-ended voltage from ADC channel.

**Parameters:**
- `channel` (int): ADC channel (0-3)
- `gain` (int): PGA gain setting (default ±6.144V range)

**Returns:** `float` - Voltage in volts

**Gain Options:**
- `ADS1118.PGA_6_144V` - ±6.144V range
- `ADS1118.PGA_4_096V` - ±4.096V range
- `ADS1118.PGA_2_048V` - ±2.048V range
- `ADS1118.PGA_1_024V` - ±1.024V range
- `ADS1118.PGA_0_512V` - ±0.512V range
- `ADS1118.PGA_0_256V` - ±0.256V range

##### `read_temperature()`

Read internal temperature sensor.

**Returns:** `float` - Temperature in Celsius

##### `close()`

Close SPI connection.

### Joystick Class

#### Constructor

```python
Joystick(adc, x_channel, y_channel, button_pin, name="Joystick")
```

**Parameters:**
- `adc` (ADS1118): ADS1118 instance
- `x_channel` (int): ADC channel for X-axis (0-3)
- `y_channel` (int): ADC channel for Y-axis (0-3)
- `button_pin` (int): GPIO pin number (BCM mode) for button
- `name` (str): Identifier string for this joystick

#### Methods

##### `read_raw()`

Read raw voltage values.

**Returns:** `dict` with keys:
- `'x'` (float): X-axis voltage (0-5V)
- `'y'` (float): Y-axis voltage (0-5V)
- `'button'` (bool): True if pressed, False if released

##### `read_normalized()`

Read normalized position values.

**Returns:** `dict` with keys:
- `'x'` (float): X position (-1.0 to +1.0)
- `'y'` (float): Y position (-1.0 to +1.0)
- `'button'` (bool): True if pressed, False if released

##### `get_direction()`

Get simplified directional input.

**Returns:** `str` - One of:
- `'center'`
- `'up'`, `'down'`, `'left'`, `'right'`
- `'up-left'`, `'up-right'`, `'down-left'`, `'down-right'`

##### `calibrate(duration=5)`

Run calibration routine.

**Parameters:**
- `duration` (int): Duration in seconds to move joystick

#### Attributes

- `deadzone` (float): Dead zone percentage (0.0 to 1.0, default 0.1)
- `x_min`, `x_max`, `x_center` (float): X-axis calibration values
- `y_min`, `y_max`, `y_center` (float): Y-axis calibration values

## 🔧 Troubleshooting

### Hardware Issues

#### Problem: No SPI devices found

```bash
ls /dev/spi*
# Error: No such file or directory
```

**Solution:**
1. Enable SPI: `sudo raspi-config` → Interface Options → SPI → Enable
2. Reboot: `sudo reboot`
3. Verify: `lsmod | grep spi_bcm2835`

#### Problem: Joystick readings are all zero

**Possible Causes & Solutions:**

1. **ADC not powered**
   - Check VDD connection to 3.3V
   - Verify GND connection

2. **SPI not connected properly**
   - Verify SCLK, MOSI, MISO, CS connections
   - Check for loose wires

3. **Wrong SPI device**
   ```python
   # Try different device number
   adc = ADS1118(bus=0, device=1)  # Try CE1 instead of CE0
   ```

4. **SPI speed too high**
   ```python
   adc = ADS1118(bus=0, device=0, max_speed_hz=500000)  # Reduce speed
   ```

#### Problem: Joystick values are noisy/unstable

**Solutions:**

1. **Add capacitors** (0.1µF ceramic) between VCC and GND on each joystick
2. **Use shorter wires** or twisted pair cables
3. **Ensure common ground** - verify with multimeter continuity test
4. **Increase dead zone**:
   ```python
   joy1.deadzone = 0.15  # Increase from 0.1 to 0.15
   ```
5. **Lower ADC sample rate**:
   ```python
   # In ads1118.py, change DR_128SPS to DR_64SPS
   ```

#### Problem: Joystick doesn't return to center (0, 0)

**Solution:**
Run calibration:
```python
joy1.calibrate(duration=5)
```

Or manually set center values:
```python
joy1.x_center = 2.5  # Adjust to actual center voltage
joy1.y_center = 2.5
```

#### Problem: Button not responding

**Checks:**
1. Verify GPIO pin connection
2. Check button wire continuity
3. Test button manually:
   ```python
   import RPi.GPIO as GPIO
   GPIO.setmode(GPIO.BCM)
   GPIO.setup(17, GPIO.IN, pull_up_down=GPIO.PUD_UP)
   print(GPIO.input(17))  # Should change when pressed
   ```

#### Problem: Values are inverted

**Solution:**
Invert in software:
```python
pos = joy1.read_normalized()
x = -pos['x']  # Invert X
y = -pos['y']  # Invert Y
```

### Software Issues

#### Problem: "ModuleNotFoundError: No module named 'spidev'"

**Solution:**
```bash
pip3 install spidev
# or
sudo apt-get install python3-spidev
```

#### Problem: "Permission denied" accessing GPIO or SPI

**Solutions:**

1. Run with sudo:
   ```bash
   sudo python3 dual_joystick_test.py
   ```

2. Add user to groups:
   ```bash
   sudo usermod -a -G spi,gpio $USER
   # Log out and back in
   ```

3. Set udev rules (permanent fix):
   ```bash
   sudo nano /etc/udev/rules.d/50-spi.rules
   ```
   Add:
   ```
   SUBSYSTEM=="spidev", GROUP="spi", MODE="0660"
   SUBSYSTEM=="gpio", GROUP="gpio", MODE="0660"
   ```
   Then:
   ```bash
   sudo udevadm control --reload-rules
   sudo udevadm trigger
   ```

#### Problem: "RuntimeError: No access to /dev/mem"

**Solution:**
This is a GPIO permissions issue. Run with sudo or fix permissions as above.

#### Problem: "ImportError: No module named RPi.GPIO"

**Solution:**
```bash
sudo apt-get install python3-rpi.gpio
# or
pip3 install RPi.GPIO
```

### Connection Issues (SSH/File Transfer)

#### Problem: "Connection refused" or "Host not found"

**Solutions:**

1. **Enable SSH on Raspberry Pi:**
   - Physical access: `sudo raspi-config` → Interface Options → SSH → Enable
   - Or create empty file named `ssh` in boot partition

2. **Find correct IP address:**
   ```bash
   # On Raspberry Pi:
   hostname -I
   
   # On your computer:
   ping raspberrypi.local
   # or scan network
   sudo nmap -sn 192.168.1.0/24
   ```

3. **Try different hostnames:**
   ```bash
   ssh pi@raspberrypi.local
   ssh pi@raspberrypi
   ssh pi@192.168.1.XXX  # Use actual IP
   ```

4. **Check if SSH service is running:**
   ```bash
   # On Raspberry Pi:
   sudo systemctl status ssh
   sudo systemctl start ssh
   sudo systemctl enable ssh
   ```

#### Problem: "Permission denied (publickey)"

**Solution:**
Password authentication might be disabled. Try:
```bash
ssh -o PreferredAuthentications=password pi@raspberrypi.local
```

### Common Ground Issues

#### How to verify common ground:

```bash
# Using multimeter (continuity mode):
# 1. Touch one probe to ADC GND
# 2. Touch other probe to Joystick GND
# 3. Should beep/show ~0Ω resistance

# Visual check:
# All GND wires should connect to the same point
# (either same RPi pin or breadboard ground rail)
```

**Why it matters:**
- ADC measures voltage relative to its GND
- If joystick has different GND reference, measurements are meaningless
- Similar to measuring building heights from different elevations

## 🎮 Application Examples

### Game Controller

```python
import pygame
from ads1118 import ADS1118
from joystick import Joystick
import RPi.GPIO as GPIO

pygame.init()
screen = pygame.display.set_mode((800, 600))

adc = ADS1118(bus=0, device=0)
joy = Joystick(adc, 0, 1, 17, "Player1")

player_x, player_y = 400, 300
speed = 5

running = True
while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
    
    # Read joystick
    pos = joy.read_normalized()
    
    # Move player
    player_x += pos['x'] * speed
    player_y -= pos['y'] * speed  # Invert Y for screen coordinates
    
    # Draw
    screen.fill((0, 0, 0))
    pygame.draw.circle(screen, (255, 255, 255), (int(player_x), int(player_y)), 20)
    pygame.display.flip()

GPIO.cleanup()
adc.close()
pygame.quit()
```

### Robot Control

```python
from ads1118 import ADS1118
from joystick import Joystick
import RPi.GPIO as GPIO

# Motor control pins
MOTOR_LEFT_FWD = 23
MOTOR_LEFT_REV = 24
MOTOR_RIGHT_FWD = 25
MOTOR_RIGHT_REV = 12

# Setup motors
GPIO.setmode(GPIO.BCM)
GPIO.setup([MOTOR_LEFT_FWD, MOTOR_LEFT_REV, 
            MOTOR_RIGHT_FWD, MOTOR_RIGHT_REV], GPIO.OUT)

left_fwd = GPIO.PWM(MOTOR_LEFT_FWD, 100)
left_rev = GPIO.PWM(MOTOR_LEFT_REV, 100)
right_fwd = GPIO.PWM(MOTOR_RIGHT_FWD, 100)
right_rev = GPIO.PWM(MOTOR_RIGHT_REV, 100)

# Initialize joystick
adc = ADS1118(bus=0, device=0)
joy = Joystick(adc, 0, 1, 17, "Drive")

try:
    left_fwd.start(0)
    left_rev.start(0)
    right_fwd.start(0)
    right_rev.start(0)
    
    while True:
        pos = joy.read_normalized()
        
        # Tank drive: Y = forward/back, X = left/right turn
        forward = pos['y']
        turn = pos['x']
        
        left_speed = (forward + turn) * 100
        right_speed = (forward - turn) * 100
        
        # Set motor speeds
        if left_speed > 0:
            left_fwd.ChangeDutyCycle(abs(left_speed))
            left_rev.ChangeDutyCycle(0)
        else:
            left_fwd.ChangeDutyCycle(0)
            left_rev.ChangeDutyCycle(abs(left_speed))
            
        if right_speed > 0:
            right_fwd.ChangeDutyCycle(abs(right_speed))
            right_rev.ChangeDutyCycle(0)
        else:
            right_fwd.ChangeDutyCycle(0)
            right_rev.ChangeDutyCycle(abs(right_speed))

except KeyboardInterrupt:
    pass
finally:
    # Stop motors
    left_fwd.stop()
    left_rev.stop()
    right_fwd.stop()
    right_rev.stop()
    GPIO.cleanup()
    adc.close()
```

### Camera Pan/Tilt Control

```python
from ads1118 import ADS1118
from joystick import Joystick
import RPi.GPIO as GPIO
from time import sleep

# Servo control with pigpio
import pigpio

pi = pigpio.pi()
PAN_PIN = 18
TILT_PIN = 13

# Servo range: 500-2500 microseconds
pan_pos = 1500
tilt_pos = 1500

adc = ADS1118(bus=0, device=0)
joy = Joystick(adc, 0, 1, 17, "Camera")

try:
    while True:
        pos = joy.read_normalized()
        
        # Adjust servo positions
        pan_pos += pos['x'] * 10
        tilt_pos += pos['y'] * 10
        
        # Clamp values
        pan_pos = max(500, min(2500, pan_pos))
        tilt_pos = max(500, min(2500, tilt_pos))
        
        # Set servo positions
        pi.set_servo_pulsewidth(PAN_PIN, pan_pos)
        pi.set_servo_pulsewidth(TILT_PIN, tilt_pos)
        
        sleep(0.02)  # 50Hz update

except KeyboardInterrupt:
    pass
finally:
    pi.set_servo_pulsewidth(PAN_PIN, 0)
    pi.set_servo_pulsewidth(TILT_PIN, 0)
    pi.stop()
    GPIO.cleanup()
    adc.close()
```

## 📊 Performance Characteristics

| Parameter | Value |
|-----------|-------|
| ADC Resolution | 16-bit (65,536 levels) |
| Voltage Accuracy | ±0.1V typical |
| Sample Rate | Up to 860 SPS (configurable) |
| Update Rate | ~20-50 Hz typical in Python |
| Latency | <20ms typical |
| Dead Zone | 10% default (configurable) |
| Button Debounce | Hardware (no software debounce needed) |

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. **Report Bugs**: Open an issue with detailed description
2. **Suggest Features**: Open an issue with [Feature Request] tag
3. **Submit Pull Requests**: Fork, create branch, make changes, submit PR
4. **Improve Documentation**: Fix typos, add examples, clarify instructions

### Development Setup

```bash
git clone https://github.com/yourusername/dual-joystick-controller.git
cd dual-joystick-controller

# Create virtual environment (optional)
python3 -m venv venv
source venv/bin/activate

# Install in development mode
pip3 install -e .
```

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024 [Your Name]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 🔗 Related Resources

### Documentation
- [Raspberry Pi GPIO Documentation](https://www.raspberrypi.com/documentation/computers/raspberry-pi.html)
- [ADS1118 Datasheet (PDF)](https://www.ti.com/lit/ds/symlink/ads1118.pdf)
- [SPI Protocol on Raspberry Pi](https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#serial-peripheral-interface-spi)
- [RPi.GPIO Documentation](https://sourceforge.net/p/raspberry-gpio-python/wiki/Home/)

### Similar Projects
- [Adafruit CircuitPython ADC Library](https://github.com/adafruit/Adafruit_CircuitPython_ADS1x15)
- [RPi Joystick Examples](https://github.com/search?q=raspberry+pi+joystick)

### Hardware Suppliers
- [Raspberry Pi Official Store](https://www.raspberrypi.com/products/)
- [Adafruit](https://www.adafruit.com/)
- [SparkFun](https://www.sparkfun.com/)
- [Electropeak](https://electropeak.com/)

## 📧 Support

For questions, issues, or suggestions:

- **GitHub Issues**: [Create an issue](https://github.com/yourusername/dual-joystick-controller/issues)
- **Email**: your.email@example.com
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/dual-joystick-controller/discussions)

## ✨ Acknowledgments

- Texas Instruments for the ADS1118 ADC chip
- Raspberry Pi Foundation for excellent documentation
- Joy-IT for the KY-023 joystick modules
- Open-source community for inspiration and support

## 📅 Version History

- **v1.0.0** (2024-11-22): Initial release
  - Dual joystick support
  - ADS1118 driver implementation
  - Calibration routines
  - Example applications
  - Complete documentation

---

**Made with ❤️ for the Raspberry Pi community**

**⭐ If you find this project helpful, please star it on GitHub!**
