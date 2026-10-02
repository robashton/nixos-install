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

  services.strongswan = {
    enable = true;
    secrets = [
      "ipsec.d/ipsec.nm-l2tp.secrets"
    ];
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
