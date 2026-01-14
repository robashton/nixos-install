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

Systemd user timer runs every 2 seconds, setting keyboard and lightbar colors based on CPU usage. Brightness is user-controlled via hotkeys.

| CPU % | Keyboard | Lightbar |
|-------|----------|----------|
| 0-20  | blue/green | cyan |
| 20-40 | teal/lightgreen | teal |
| 40-60 | purple/yellow | lavender |
| 60-80 | purple/orange | magenta |
| 80-100 | violet/red | pink-red |

Lightbar brightness preference stored in `$XDG_RUNTIME_DIR/lightbar-brightness` (default: 50%). Keyboard brightness is hardware-controlled.

### 5. Manual Control Scripts

- `fn-lightbar-up`: Increment lightbar brightness (+25% up to 100%), saves preference
- `fn-lightbar-down`: Decrement lightbar brightness (-25% down to 0%), saves preference

Lightbar brightness preference persists in `$XDG_RUNTIME_DIR/lightbar-brightness`.

**Note:** Keyboard brightness is hardware-controlled via Fn keys and cannot be read or set by software.

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

---

## Changes (2026-01): Improved Color Scheme & Brightness Control

### Available AUCC Colors

```
red, green, blue, teal, pink, purple, white, yellow, orange, olive,
maroon, brown, gray, skyblue, navy, crimson, darkgreen, lightgreen, gold, violet
```

### New Color Scheme

**Previous:** Monochrome gradients (green/darkgreen, etc.) - not visually appealing.

**New concept:** Blue + green at idle, adding red as CPU increases:
- One color layer: green → lightgreen → yellow → orange → red
- Other color layer: blue → teal → purple → purple → violet

**CPU → Color Mapping (brightness is user-controlled, not CPU-controlled):**

| CPU % | Keyboard (`-H color1 color2`) | Lightbar RGB |
|-------|-------------------------------|--------------|
| 0-20  | blue / green                  | 0, 200, 255 (cyan) |
| 20-40 | teal / lightgreen             | 64, 180, 200 (teal) |
| 40-60 | purple / yellow               | 160, 140, 180 (lavender) |
| 60-80 | purple / orange               | 200, 80, 140 (magenta) |
| 80-100 | violet / red                 | 255, 40, 100 (pink-red) |

### Brightness Control

**Design:** CPU monitor controls colors based on CPU load. Brightness is user-controlled separately.

**Keyboard brightness:** Hardware-controlled via `Fn+KbBrightnessUp/Down` keys. These are handled by the keyboard's embedded controller and don't reach the OS.

**Lightbar brightness:** Software-controlled via `Mod+PgUp/PgDown` hotkeys.

**Preference file:** `$XDG_RUNTIME_DIR/lightbar-brightness`
- Format: single number (e.g., `50`)
- Default if no file: 50%

**Hotkeys:**
- `Fn+KbBrightnessUp/Down`: Keyboard brightness (hardware, invisible to OS)
- `Mod+PgUp`: Lightbar brightness up (0→25→50→75→100)
- `Mod+PgDown`: Lightbar brightness down

**Behavior:**
- User adjusts lightbar brightness with Mod+PgUp/PgDown → preference saved to file
- CPU monitor reads preference file, applies lightbar brightness while changing colors based on CPU load
- Lightbar brightness persists across CPU monitor runs until user changes it

---

## Changes (2026-01-14): Flickering Fix & Instant Brightness Apply

### Problems

1. **Flickering**: The CPU monitor ran every 2 seconds and unconditionally called `aucc` and wrote to lightbar sysfs, even when nothing changed. This caused visible flickering as the hardware was constantly being reset.

2. **Brightness not applying immediately**: The `fn-kb-up`/`fn-kb-down` scripts only saved the preference to file - they didn't apply it to hardware. Users had to wait up to 2 seconds for the next CPU monitor run.

3. **Lightbar brightness not working from hotkeys**: When xmonad spawns the fn-kb scripts, they run in a different environment where direct sysfs writes may fail silently (permission/context differences vs systemd user services).

### Solution: State Tracking + Instant Apply Service

**Architecture:**

```
$XDG_RUNTIME_DIR/
├── kb-brightness    # User preference: "KB_LEVEL LB_BRIGHT" (e.g., "2 50")
└── kb-state         # Last applied state: "COLOR1 COLOR2 R G B KB LB"
```

**State file format:** `COLOR1 COLOR2 RGB_R RGB_G RGB_B KB_LEVEL LB_BRIGHT`
- Example: `blue green 0 200 255 2 50`

**Two systemd user services:**

1. **`aucc-cpu-monitor.service`** (timer-triggered every 2s)
   - Calculates CPU usage (1s sample)
   - Determines colors based on CPU bracket
   - Reads brightness from preference file
   - Compares new state to old state
   - **Only writes to hardware if state changed** (prevents flickering)
   - Updates state file

2. **`aucc-apply-brightness.service`** (triggered by fn-kb scripts)
   - Reads colors from state file (or defaults)
   - Reads brightness from preference file
   - Applies immediately (no CPU calculation, no delay)
   - Updates state file with new brightness

**Hotkey flow:**
```
User presses Fn+KbBrightnessUp
  → fn-kb-up script runs
  → Updates kb-brightness file with new values
  → Triggers aucc-apply-brightness.service
  → Service applies new brightness with current colors instantly
  → Shows notification
```

**CPU monitor flow:**
```
Timer fires every 2s
  → aucc-cpu-monitor.service runs
  → Samples CPU for 1 second
  → Builds new state string (colors + brightness)
  → Compares to previous state in kb-state file
  → If different: apply to hardware, update state file
  → If same: do nothing (no flickering)
```

### Why Systemd Services for Hardware Access

The fn-kb scripts are spawned by xmonad which may have a different environment than systemd user services. Direct sysfs writes (`echo X > /sys/...`) were failing silently from the xmonad context but working fine from systemd services.

By keeping all hardware access in systemd user services:
- Consistent environment and permissions
- `TAG+="uaccess"` udev rules work reliably
- Errors are logged properly if they occur

### Files Changed

- `fn-kb-up` / `fn-kb-down`: Now just update preference file and trigger `aucc-apply-brightness.service`
- `aucc-cpu-monitor` service: Added state tracking, only updates hardware when state changes
- New `aucc-apply-brightness` service: Instant apply without CPU calculation

### Debugging

```bash
# Check current state
cat $XDG_RUNTIME_DIR/kb-brightness
cat $XDG_RUNTIME_DIR/kb-state

# Manually trigger instant apply
systemctl --user start aucc-apply-brightness.service

# Check service logs
journalctl --user -u aucc-cpu-monitor.service -f
journalctl --user -u aucc-apply-brightness.service -f

# Force state refresh (delete state file, next CPU monitor run will reapply)
rm $XDG_RUNTIME_DIR/lighting-state
```

---

## Changes (2026-01-14): Keyboard Brightness is Hardware-Controlled

### Discovery

The keyboard brightness Fn keys (`Fn+KbBrightnessUp`/`Fn+KbBrightnessDown`) are handled entirely by the keyboard's embedded controller (ITE 8291) at the firmware level. They never reach X11/the OS.

**Investigation performed:**
- `xev` showed no key events when pressing Fn+KbBrightness keys
- No ACPI/WMI interface exists for keyboard backlight on this chassis
- The `tuxedo_keyboard` module won't load (laptop not recognized as TUXEDO device)
- The `ite_8291` HID driver exists but exposes no readable interface
- `aucc` uses direct USB control transfers - write-only, no read-back capability

**Implication:** Software cannot read the current keyboard brightness, and any `aucc -b X` call will overwrite whatever the user set via hardware Fn keys.

### Solution: Separate Control

**Keyboard brightness:** Hardware-controlled only (Fn keys). Software no longer touches it.

**Lightbar brightness:** Software-controlled via `Mod+PgUp`/`Mod+PgDown` hotkeys.

**Colors:** Both keyboard and lightbar colors are software-controlled based on CPU usage.

### New Architecture

```
$XDG_RUNTIME_DIR/
├── lightbar-brightness   # Lightbar brightness only (e.g., "50")
└── lighting-state        # Last applied state: "COLOR1 COLOR2 R G B LB_BRIGHT"
```

**State file format:** `COLOR1 COLOR2 RGB_R RGB_G RGB_B LB_BRIGHT`
- Example: `blue green 0 200 255 50`

### Hotkeys

| Keys | Action |
|------|--------|
| `Fn+KbBrightnessUp/Down` | Keyboard brightness (hardware, not visible to OS) |
| `Mod+PgUp` | Lightbar brightness up (+25%, max 100%) |
| `Mod+PgDown` | Lightbar brightness down (-25%, min 0%) |

### Scripts Renamed

- `fn-kb-up` → `fn-lightbar-up` (lightbar only)
- `fn-kb-down` → `fn-lightbar-down` (lightbar only)

### aucc Calls

```bash
# Old (fought with hardware Fn keys):
aucc -H $COLOR1 $COLOR2 -b $KB_LEVEL

# New (colors only, brightness left to hardware):
aucc -H $COLOR1 $COLOR2
```

### Debugging

```bash
# Check current state
cat $XDG_RUNTIME_DIR/lightbar-brightness
cat $XDG_RUNTIME_DIR/lighting-state

# Test lightbar brightness manually
echo 100 > /sys/class/leds/rgb:lightbar/brightness
echo 25 > /sys/class/leds/rgb:lightbar/brightness

# Trigger lightbar brightness apply
systemctl --user start aucc-apply-brightness.service

# Check logs
journalctl --user -u aucc-cpu-monitor.service -f
journalctl --user -u aucc-apply-brightness.service -f
```
