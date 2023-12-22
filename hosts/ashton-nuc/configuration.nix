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
    ];

  fonts = {
    fontconfig = {
      antialias = true;
    };
  };

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

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowPing = true;

  services.xserver.layout = "us";
  services.xserver.autorun = false;


#  services.xserver.videoDrivers = lib.mkForce [];
#  services.drivers = [
#    ({ driverName = ''modesetting" BusID "PCI:0:2:0'';
#    name = "intel";
#    modules = [pkgs.xorg.xf86videomodesetting];
#  })
#  ];

  services.xserver.videoDrivers = [ "admgpu" ];

  boot.kernelModules = [ "intel-drm" ];

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

  nixpkgs.config.allowUnfree = true;
#  nixpkgs.config.packageOverrides = pkgs: {
#    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
#  };

  # VAAPI
  # https://nixos.wiki/wiki/Accelerated_Video_Playback
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      vaapiIntel
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
  services.xserver.xkbOptions = "altwin:swap_alt_win, ctrl:swapcaps";
}
