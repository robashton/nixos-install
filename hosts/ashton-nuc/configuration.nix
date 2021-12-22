#dx vim: set sts=2 ts=2 sw=2 expandtab :

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, pkgs, ... }:

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

  networking.interfaces.enp5s0.useDHCP = false;
  networking.interfaces.enp5s0.ipv4.addresses = [ {
    address = "192.168.20.100";
    prefixLength = 24;
  } ];


  hardware.cpu.intel.updateMicrocode = true;

  networking.hostName = "ashton-nuc";
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  networking.wireless.enable = true;

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
#  services.xserver.useGlamor = true;

  boot.kernelModules = [ "intel-drm" ];

  networking.firewall = {
    trustedInterfaces = [
      "arqiva0" "arqiva1" "arqiva2" "arqiva3" "arqiva4"
      "perform0" "perform1" "perform2" "perform3" "perform4"
      "dazn0" "dazn1" "dazn2" "dazn3" "dazn4" "enp5s0"
      ];
    allowedTCPPorts = [
      22    # SSH
      8080  # dev
      8443
      12000 # encoder
    ];

    allowedUDPPorts = [];

    allowedUDPPortRanges = [];

  };

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
   };


  # VAAPI
  # https://nixos.wiki/wiki/Accelerated_Video_Playback
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      vaapiIntel
#      intel-media-driver
      (pkgs.intel-media-driver.overrideAttrs (oldAttrs: {
        name = "intel-media-driver";
        postFixup = ''
          patchelf --set-rpath "$(patchelf --print-rpath $out/lib/dri/iHD_drv_video.so):${lib.makeLibraryPath [ xorg.libX11  ]}" \
            $out/lib/dri/iHD_drv_video.so
        '';
      }))
    ];
  };
  services.xserver.xkbOptions = "altwin:swap_alt_win, ctrl:swapcaps";
}
