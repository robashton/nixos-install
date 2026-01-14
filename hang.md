# Hard Lock Investigation - ashton-recoil

## Status: DIAGNOSIS COMPLETE - READY FOR FIX

## Symptoms
- Machine hard locks
- Suspected trigger: trackpad usage (likely coincidental - actual cause is GPU)

## System Info
- Kernel: 6.12.60
- GPUs: AMD Radeon (iGPU at 06:00.0) + NVIDIA RTX 5080 (dGPU at 01:00.0)
- Current drivers: amdgpu + nvidia (PRIME offload mode)

## Root Cause Found

**DMCUB (Display MicroController Unit B) errors on AMD GPU:**
```
Jan 14 06:39:22 kernel: amdgpu 0000:06:00.0: [drm] *ERROR* dc_dmub_srv_log_diagnostic_data: DMCUB error - collecting diagnostic data
```

DMCUB is AMD's display controller firmware. These errors are known to cause hard locks, particularly:
- During panel refresh operations
- Power state transitions (PSR - Panel Self Refresh)
- Display mode changes

The trackpad correlation may be coincidental, or trackpad input may trigger display activity that exposes the bug.

## Recommended Fixes

### Option 1: Disable PSR (Panel Self Refresh) - MOST LIKELY FIX
Add kernel parameter: `amdgpu.dcdebugmask=0x10`

### Option 2: Increase DMCUB timeout
Add kernel parameter: `amdgpu.dc=0` (disables display core - NOT recommended, breaks features)

### Option 3: Both PSR disable + extra debug
Add: `amdgpu.dcdebugmask=0x10 amdgpu.gpu_recovery=1`

## Changes to Make

Edit `configuration.nix` line 105, add to `boot.kernelParams`:
- `amdgpu.dcdebugmask=0x10` - disables PSR which is the most common DMCUB hang trigger

## Current kernelParams (line 105)
```nix
boot.kernelParams = [ "acpi_backlight=native" "s2idle=platform" "usbcore.autosuspend=-1"  ];
```

## Proposed kernelParams
```nix
boot.kernelParams = [ "acpi_backlight=native" "s2idle=platform" "usbcore.autosuspend=-1" "amdgpu.dcdebugmask=0x10" "amdgpu.gpu_recovery=1" ];
```

## Next Steps
- [x] Apply the kernel parameter fix (DONE)
- [ ] Rebuild NixOS: `sudo nixos-rebuild switch --flake .#ashton-recoil`
- [ ] Test for hangs

## Other Notes
- RDSEED32 CPU bug (harmless)
- USB HID endpoint warnings on ports 5-1.1, 5-1.3 (likely unrelated)
