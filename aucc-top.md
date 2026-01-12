# AUCC CPU Monitor + Lightbar Setup

## Overview

Use keyboard backlight (via `aucc`) and the underside lightbar (via `ite_8291_lb`) to display CPU usage with color gradients.

## Hardware

| Device | USB ID | Controller | Purpose |
|--------|--------|------------|---------|
| ITE 8291 | 048d:600b | aucc | Keyboard backlight |
| ITE 8233 | 048d:7001 | ite_8291_lb | Underside lightbar |

**Laptop**: PCSpecialist Recoil 16 AMD Pro (Tongfang X6FR558Y chassis)

## Changes Made

### 1. User Permissions

Added `input` group to user's `extraGroups` for USB device access.

### 2. Kernel Modules

```nix
boot.extraModulePackages = with config.boot.kernelPackages; [
  acpi_call
  tuxedo-keyboard  # provides ite_8291_lb for lightbar
];

boot.kernelModules = [ ... "ite_8291_lb" ];
```

### 3. Udev Rules

```nix
services.udev.extraRules = ''
  # Keyboard LED controller - TAG+="uaccess" grants session-based access (works at boot)
  SUBSYSTEM=="usb", ATTR{idVendor}=="048d", ATTR{idProduct}=="600b", TAG+="uaccess"
  # Lightbar LED controller
  SUBSYSTEM=="usb", ATTR{idVendor}=="048d", ATTR{idProduct}=="7001", TAG+="uaccess"
  # Make lightbar sysfs writable
  SUBSYSTEM=="leds", KERNEL=="rgb:lightbar", RUN+="chmod 0666 /sys/class/leds/rgb:lightbar/brightness /sys/class/leds/rgb:lightbar/multi_intensity"
  ...
'';
```

**Note**: Using `TAG+="uaccess"` instead of `MODE/GROUP` integrates with systemd-logind and grants access to the logged-in user at their seat. This is more reliable than group-based permissions, especially for systemd user services that start early in the login process.

### 4. CPU Monitor Service

Systemd user timer runs every 2 seconds, setting both keyboard and lightbar based on CPU usage:

| CPU % | Keyboard | Lightbar | Brightness |
|-------|----------|----------|------------|
| 0-20  | green/darkgreen | green | 25% |
| 20-40 | green/darkgreen | green | 50% |
| 40-60 | yellow/orange | yellow | 75% |
| 60-80 | orange/red | orange | 75% |
| 80-100 | red/orange | red | 100% |

### 5. Manual Control Scripts

- `fn-kb-up`: Keyboard brightness 4 + lightbar white at 100%
- `fn-kb-down`: Keyboard brightness 1 + lightbar off

## Lightbar Control Reference

```bash
# Turn off
echo 0 > /sys/class/leds/rgb:lightbar/brightness

# Set color (RGB values 0-255)
echo "255 0 0" > /sys/class/leds/rgb:lightbar/multi_intensity  # red
echo "0 255 0" > /sys/class/leds/rgb:lightbar/multi_intensity  # green
echo "0 0 255" > /sys/class/leds/rgb:lightbar/multi_intensity  # blue

# Set brightness (0-100)
echo 50 > /sys/class/leds/rgb:lightbar/brightness
```

## Manual Testing

```bash
# Test keyboard (after adding to input group)
aucc -H green darkgreen -b 2

# Test lightbar
echo "255 0 0" > /sys/class/leds/rgb:lightbar/multi_intensity
echo 100 > /sys/class/leds/rgb:lightbar/brightness

# Run CPU monitor manually
aucc-cpu-monitor

# Check service status
systemctl --user status aucc-cpu-monitor.timer
```

## Rebuild

```bash
sudo nixos-rebuild switch
```

Then log out/in (or reboot) for group membership and modules to take effect.

## Research Notes (for troubleshooting/resumption)

### Hardware Discovery

```bash
# Two ITE USB devices on this laptop:
lsusb | grep 048d
# Bus 005 Device 003: ID 048d:600b ITE Device(8291) - KEYBOARD
# Bus 005 Device 005: ID 048d:7001 ITE Device(8233) - LIGHTBAR
```

### What Works

- **Keyboard (048d:600b)**: Controlled by `aucc` from `avell-unofficial-control-center`
  - Required overlay to patch product_id from 0xce00 to 0x600b
  - Udev rule for GROUP="input" allows non-root access

- **Lightbar (048d:7001)**: Controlled by `ite_8291_lb` module from `tuxedo-keyboard` package
  - Module depends on `led_class_multicolor` (auto-loaded)
  - Creates `/sys/class/leds/rgb:lightbar/` with `brightness` (0-100) and `multi_intensity` (R G B, 0-255 each)
  - Verify with: `modinfo ite_8291_lb` shows alias `hid:b0003g*v0000048Dp00007001`

### What Doesn't Work

- **qc71_laptop module**: Loads and creates `/sys/class/leds/qc71_laptop::lightbar/` but writing to it doesn't actually control the lightbar on this specific Recoil 16. The `ite_8291_lb` module is the correct one.

### Module Loading

```bash
# Check if modules are loaded
lsmod | grep -E "ite_8291|tuxedo|qc71"

# Manually load for testing (before rebuild)
sudo modprobe led_class_multicolor
sudo insmod /path/to/ite_8291_lb.ko

# Find the module in nix store
nix-build '<nixpkgs>' -A linuxKernel.packages.linux_6_12.tuxedo-keyboard
find /nix/store/*tuxedo* -name "ite_8291_lb.ko*"
```

### Sysfs Paths

```bash
# Lightbar
/sys/class/leds/rgb:lightbar/brightness        # 0-100
/sys/class/leds/rgb:lightbar/multi_intensity   # "R G B" (0-255 each)
/sys/class/leds/rgb:lightbar/multi_index       # "red green blue"

# Keyboard (via aucc, not sysfs)
aucc -H <color1> <color2> -b <1-4>
aucc -c <color> -b <1-4>
aucc -d  # disable
```

### If Lightbar Misbehaves After Reboot

1. Check module loaded: `lsmod | grep ite_8291_lb`
2. Check sysfs exists: `ls /sys/class/leds/rgb:lightbar/`
3. Check permissions: `ls -la /sys/class/leds/rgb:lightbar/brightness`
4. Try manual control: `echo 0 | sudo tee /sys/class/leds/rgb:lightbar/brightness`
5. If rainbow pulsing, the module may not have loaded - check `dmesg | grep ite`

### NixOS Package Names

```nix
# Keyboard
pkgs.avell-unofficial-control-center  # provides 'aucc' command

# Lightbar module
config.boot.kernelPackages.tuxedo-keyboard  # provides ite_8291_lb.ko
```

## Sources

- [rodgomesc/avell-unofficial-control-center](https://github.com/rodgomesc/avell-unofficial-control-center) - Keyboard control
- [TUXEDO Computers tuxedo-keyboard](https://github.com/tuxedocomputers/tuxedo-keyboard) - Lightbar module (ite_8291_lb)
- [pobrn/qc71_laptop](https://github.com/pobrn/qc71_laptop) - Alternative lightbar control (less compatible)
- [Tongfang GK7C compatibility](https://github.com/pobrn/qc71_laptop/issues/6)
