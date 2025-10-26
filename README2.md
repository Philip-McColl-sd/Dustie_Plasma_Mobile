## Bluetooth Audio Quality Issues

### Problem
After connecting Bluetooth headphones/speakers, you experience:
- Poor audio quality (sounds like phone call quality)
- No hardware volume control from the device
- Only app volume control works

### Cause
The Bluetooth device paired with only **headset profiles** (HSP/HFP for phone calls) instead of **A2DP profiles** (for high-quality music).

### How to Check
```bash
# Check current Bluetooth profiles
pactl list cards | grep -A30 "bluez_card"
```

If you only see:
- `headset-head-unit`
- `headset-head-unit-cvsd`

And NO:
- `a2dp-sink-sbc`
- `a2dp-sink-aac`

Then you have this problem.

### Solution

**1. Remove and re-pair the device:**
```bash
bluetoothctl
devices  # Note your device MAC address
remove XX:XX:XX:XX:XX:XX
scan on  # Wait for device to appear
pair XX:XX:XX:XX:XX:XX
trust XX:XX:XX:XX:XX:XX
connect XX:XX:XX:XX:XX:XX
quit
```

**2. Verify A2DP profiles now exist:**
```bash
pactl list cards | grep -A30 "bluez_card"
```

**3. If still missing A2DP, install codecs:**
```bash
sudo apt install -y pulseaudio-module-bluetooth libsbc1 libldac
systemctl --user restart pipewire pipewire-pulse wireplumber
```

Then re-pair the device again.

### Expected Result
After re-pairing, you should have:
- ✅ High quality audio (A2DP)
- ✅ Hardware volume control from device
- ✅ Multiple profile options in audio settings