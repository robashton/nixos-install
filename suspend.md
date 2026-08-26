# Re-enabling Suspend on Lid Close - ashton-recoil

## Background

Suspend was previously disabled on this laptop due to system hangs. A workaround (`fake-laptop-sleep.nix`) was implemented that:
- Ignores lid events in logind
- Uses acpid to lock sessions and turn off displays via DPMS when lid closes
- Sets CPU governor to powersave

This workaround avoided the hangs but meant the laptop stayed running with lid closed (no actual suspend).

## Attempt 1: PSR Disable (FAILED)

**Theory:** The hangs were caused by DMCUB (Display MicroController Unit B) errors on the AMD GPU, related to PSR (Panel Self Refresh). Disabling PSR via `amdgpu.dcdebugmask=0x10` should make suspend safe.

**What we did:**
- Switched from `fake-laptop-sleep.nix` to `laptop-suspend.nix`
- Already had kernel param `amdgpu.dcdebugmask=0x10` to disable PSR

**Result:** System froze on lid close. PSR wasn't the (only) problem.

## Attempt 2: NVIDIA Module Unload (FAILED)

**Theory:** The hybrid AMD+NVIDIA setup is the issue. NVIDIA's dynamic power management (`NVreg_DynamicPowerManagement=0x02`) doesn't play nice with suspend. The nvidia modules need to be unloaded before suspend and reloaded after resume.

**What we added to configuration.nix:**
```nix
# NVIDIA suspend workaround - unload modules before suspend, reload after resume
systemd.services.nvidia-suspend = {
  description = "Unload NVIDIA modules before suspend";
  before = [ "sleep.target" ];
  wantedBy = [ "sleep.target" ];
  serviceConfig = {
    Type = "oneshot";
    ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.kmod}/bin/modprobe -r nvidia_uvm nvidia_drm nvidia_modeset nvidia 2>/dev/null || true'";
  };
};

systemd.services.nvidia-resume = {
  description = "Reload NVIDIA modules after resume";
  after = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
  wantedBy = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
  serviceConfig = {
    Type = "oneshot";
    ExecStart = "${pkgs.kmod}/bin/modprobe nvidia_drm";
  };
};
```

**Result:** System froze on lid close. Logs from boot -1 (06:39-06:52) show normal operation ending abruptly with no sleep.target ever reached - the freeze happened so fast that systemd couldn't even log the suspend attempt. The nvidia module unload approach didn't help (or wasn't reached in time).

**Log analysis (2026-01-16):**
- Boot -1 lasted ~13 minutes (06:39:08 to 06:52:41)
- Last log entries show normal operation (Discord, Home Manager, aucc-cpu-monitor)
- NO suspend/sleep.target entries at all - freeze happened before systemd could log
- This suggests the freeze occurs very early in the suspend process

## Attempt 3: Use NixOS nvidia powerManagement (SUCCESS)

**Investigation findings (2026-01-16 07:15):**
- `nvidia_drm` module has 3 users - cannot be unloaded while X is running
- Our custom nvidia-suspend service fails silently (modules in use)
- `/proc/driver/nvidia/suspend` exists - nvidia driver has built-in suspend support
- NixOS has `hardware.nvidia.powerManagement.enable` which uses official `nvidia-sleep.sh`

**The official nvidia-sleep.sh approach:**
1. Switches to VT 63 before suspend
2. Writes "suspend" to `/proc/driver/nvidia/suspend` (driver handles the rest)
3. On resume, writes "resume" to `/proc/driver/nvidia/suspend`
4. Switches back to original VT

This is MUCH better than trying to unload modules.

**What to change in configuration.nix:**

1. ADD this line:
```nix
hardware.nvidia.powerManagement.enable = true;
```

2. REMOVE our custom nvidia-suspend/nvidia-resume services (lines 480-500)

**Changes applied (2026-01-16 07:17):**
- Added `hardware.nvidia.powerManagement.enable = true;` after line 122
- Removed custom nvidia-suspend/nvidia-resume systemd services

**Result: SUCCESS (2026-01-16)**

System suspended and resumed correctly using `systemctl suspend`.

**To verify services are correct after rebuild:**
```bash
systemctl cat nvidia-suspend.service  # Should show nvidia-sleep.sh
systemctl cat nvidia-resume.service   # Should show nvidia-sleep.sh
```

## If Attempt 3 Fails

Options to try next:
1. **Add finegrained power management** - `hardware.nvidia.powerManagement.finegrained = true;`
2. **Disable nvidia dynamic power entirely** - change `NVreg_DynamicPowerManagement=0x02` to `=0x00`
3. **Try nvidia-persistenced disable** - add `hardware.nvidia.nvidiaPersistenced = false;`
4. **Check amdgpu PSR is really disabled** - `cat /sys/kernel/debug/dri/1/eDP-1/psr_state`
5. **Revert to fake-laptop-sleep.nix** - give up on real suspend

## Current Configuration

**configuration.nix imports:**
```nix
./../../common/laptop-suspend.nix  # real suspend enabled
```

**NVIDIA settings:**
```nix
hardware.nvidia.powerManagement.enable = true;  # official suspend/resume scripts
hardware.nvidia.nvidiaPersistenced = true;
hardware.nvidia.open = true;
boot.extraModprobeConfig = "options nvidia NVreg_DynamicPowerManagement=0x02";
```

**Kernel params:**
```nix
boot.kernelParams = [ "acpi_backlight=native" "s2idle=platform" "usbcore.autosuspend=-1" "amdgpu.dcdebugmask=0x10" "amdgpu.gpu_recovery=1" ];
```

## To Revert (give up)

Change line 16 in configuration.nix from:
```nix
./../../common/laptop-suspend.nix
```
To:
```nix
./../../common/fake-laptop-sleep.nix
```

And set:
```nix
hardware.nvidia.powerManagement.enable = false;
```
