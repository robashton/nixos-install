#dx vim: set sts=2 ts=2 sw=2 expandtab :

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

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

  hardware.cpu.intel.updateMicrocode = true;

  networking.hostName = "ashton-nuc";
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  networking.wireless.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowPing = true;
  services.xserver.layout = "us";
  services.xserver.autorun = false; 
  services.xserver.videoDrivers = [ "amdgpu" ];

  boot.kernelPatches = [
    { name = "amdgpu-config";
      patch = null;
      extraConfig = ''
        DRM_AMD_DC_DCN1_0 y
      '';
    }
];

  networking.firewall = {
    trustedInterfaces = [
      "arqiva0" "arqiva1" "arqiva2" "arqiva3" "arqiva4" ]; 
    allowedTCPPorts = [
      22    # SSH
      8080  # dev
    ];

    allowedUDPPorts = [];

    allowedUDPPortRanges = [];

  };



  # VAAPI
  # https://nixos.wiki/wiki/Accelerated_Video_Playback
  hardware.opengl = {
    enable = true;
    driSupport = true;
    extraPackages = with pkgs; [
      vaapiIntel
#      intel-media-driver
      (pkgs.intel-media-driver.overrideAttrs (oldAttrs: {
        name = "intel-media-driver";
        postFixup = ''
          patchelf --set-rpath "$(patchelf --print-rpath $out/lib/dri/iHD_drv_video.so):${stdenv.lib.makeLibraryPath [ xorg.libX11  ]}" \
            $out/lib/dri/iHD_drv_video.so
        '';
      }))
    ];
  };
  services.xserver.xkbOptions = "altwin:swap_alt_win, ctrl:swapcaps";
}
