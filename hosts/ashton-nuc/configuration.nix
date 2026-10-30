# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, pkgs , ... }:

{

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # Common things
      ./../../common
      ./../../common/vpn-steve.nix


      # Hardware & user specific things
      ./robashton

      # The CI runner's service user
      ./jankings

      # The norsk private binary cache the runner builds against
      ./norsk-cache
    ];

  # This box is headless: an SSH jump host and a GitHub Actions runner. No X,
  # no GNOME, no browsers, no Steam. See common/desktop.nix.
  id3as.desktop.enable = false;

  # Steve gets passwordless sudo on this box only (wheel is NOPASSWD in
  # common); common/steve stays non-admin on every other host.
  users.users.steve.extraGroups = [ "wheel" ];

  # Plugged right into the router now
  networking.interfaces.enp5s0.useDHCP = true;
  # networking.interfaces.enp5s0.ipv4.addresses = [ {
  #   address = "192.168.20.100";
  #   prefixLength = 24;
  # } ];


  hardware.cpu.intel.updateMicrocode = true;

  # Silent hard hangs (2026-10-20, 2026-10-25): nothing in the journal, no
  # panic, NMI watchdog quiet. Hades Canyon (NUC8i7HVK) is known for freezing
  # in deep C-states, so cap the idle state.
  boot.kernelParams = [ "intel_idle.max_cstate=1" ];

  # If it does lock up, panic rather than sit there: efi-pstore keeps the
  # dmesg across the reboot (systemd-pstore drops it in /var/lib/systemd/pstore),
  # and kernel.panic reboots after 10s.
  boot.kernel.sysctl = {
    "kernel.panic" = 10;
    "kernel.panic_on_oops" = 1;
    "kernel.softlockup_panic" = 1;
    "kernel.hardlockup_panic" = 1;
  };

  # And the hardware watchdog for when the kernel cannot even manage that.
  systemd.settings.Manager.RuntimeWatchdogSec = "30s";

  networking.hostName = "ashton-nuc";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  networking.wireless.enable = true;


  # " I only want this for l2tp
  networking.networkmanager = {
    enable = true;
    unmanaged = [
      "wlp6s0"
    ];

  };

  # Always-on L2TP/IPsec link to Steve, for the buck2 cache. See common/vpn-steve.nix.
  id3as.vpnSteve.enable = true;

  # NM will only bring a VPN up on top of a connection it manages itself, so the
  # wired link (eno1, despite the enp5s0 references above) belongs to NM rather
  # than dhcpcd. The client-id is the one dhcpcd sent (0xff, IAID = last 4 MAC
  # bytes, then its DUID) so the router keeps handing out the same lease and the
  # port forward behind ashtonnuc.ddns.net keeps working.
  networking.dhcpcd.denyInterfaces = [ "eno1" ];
  networking.networkmanager.ensureProfiles.profiles.eno1 = {
    connection = {
      id = "eno1";
      type = "ethernet";
      interface-name = "eno1";
      autoconnect = "true";
      autoconnect-priority = "100";
    };
    ipv4 = {
      method = "auto";
      dhcp-client-id = "ff:03:8c:f1:37:00:01:00:01:2e:e5:b1:c3:54:b2:03:8c:f1:37";
    };
    ipv6.method = "auto";
  };

  # Open ports in the firewall.
  networking.firewall.allowPing = true;

  networking.firewall = {
    trustedInterfaces = [ "enp5s0" ];
    allowedTCPPorts = [
      22    # SSH
      8080  # dev
      8443
    ];

    allowedUDPPorts = [];

    allowedUDPPortRanges = [];

  };

  # No nvidia hardware in this box (Intel HD 630 + AMD Vega M), so the
  # toolkit enabled in common/ just trips an assertion here.
  hardware.nvidia-container-toolkit.enable = lib.mkForce false;

  # common/ leaves docker socket-activated (fine on laptops), but here the CI
  # runner and moq relay have to come back by themselves after a watchdog reboot.
  virtualisation.docker.enableOnBoot = lib.mkForce true;

  # Root is the whole disk now (444G), so docker uses the default /var/lib/docker.
  # The old data-root = "/home/docker" was a workaround for the 118G root, and went
  # away with the separate home partition.
  virtualisation.docker.daemon.settings = {
    # Explicit because the default flips to false at stateVersion 25.11, which would
    # kill running containers on a daemon restart.
    live-restore = true;
  };

  nixpkgs.config.allowUnfree = true;
#  nixpkgs.config.packageOverrides = pkgs: {
#    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
#  };

  # VAAPI. Kept because the CI runner does video work; enable32Bit is gone with
  # Steam, since nothing headless wants a 32-bit mesa stack.
  # https://nixos.wiki/wiki/Accelerated_Video_Playback
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-vaapi-driver
      (pkgs.intel-media-driver.overrideAttrs (oldAttrs: {
        name = "intel-media-driver";
        postFixup = ''
          patchelf --set-rpath "$(patchelf --print-rpath $out/lib/dri/iHD_drv_video.so):${lib.makeLibraryPath [ xorg.libX11  ]}" \
            $out/lib/dri/iHD_drv_video.so
        '';
      }))
    ];
  };
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

  # Set per-host rather than in common/, which is shared with ashton-recoil and
  # ashton-studio — they have their own install histories.
  system.stateVersion = "25.11";
}
