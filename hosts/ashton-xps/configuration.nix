#dx vim: set sts=2 ts=2 sw=2 expandtab :

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:
let
    nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
  '';

    nvidia-env = pkgs.writeShellScriptBin "nvidia-env" ''
      export NVIDIA_DRIVERS=${pkgs.linuxPackages.nvidia_x11}
  '';
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # Common things
      ./../../common

      # Hardware & user specific things
      ./robashton
    ];

  powerManagement.enable = true;
  hardware.cpu.intel.updateMicrocode = true;

  networking.hostName = "ashton-xps";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.extraModprobeConfig = ''
    options snd-hda-intel enable_msi=1
  '';

  networking.interfaces.enp56s0u2.useDHCP = true;
#  networking.interfaces.enp56s0u2.ipv4.addresses = [ {
#    address = "192.168.20.101";
#    prefixLength = 24;
#  } ];

#  networking.wireless.enable = true;

  networking.networkmanager = {
    enable = true;
#    default = "wlp0s20f3";
    unmanaged = [];

  };

  services.strongswan = {
    enable = true;
    secrets = [
      "ipsec.d/ipsec.nm-l2tp.secrets"
    ];
  };


  services.xserver.autorun = true;
  services.xserver.xkbOptions = "ctrl:swapcaps";
#  services.xserver.synaptics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  boot.kernelModules = [ "nvidia-uvm" "nvidia-drm" ];

  boot.blacklistedKernelModules = [ "nouveau" ];

#  boot.extraModprobeConfig = ''
#    options bbswitch load_state=-1 unload_state=1
#    '';

  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.prime.offload.enable = true;
  hardware.nvidia.prime.nvidiaBusId = "PCI:1:0:0";
  hardware.nvidia.nvidiaPersistenced = true;
  hardware.nvidia.prime.intelBusId = "PCI:0:2:0";

  environment.systemPackages = with pkgs; [
    nvidia-offload
    nvidia-env
    xorg.xbacklight
    #bumblebee
    powertop
    pmutils
    linuxPackages.nvidia_x11
    vdpauinfo
  ];

  boot.kernelParams = [ "acpi_osi=Linux" "net.naming-scheme=v239" ];  # "acpi_osi=\"Windows 2009\""];

  services.xserver.libinput.enable = true;
  #services.xserver.libinput.clickMethod = "buttonareas";
  services.xserver.libinput.tapping = true;
  services.xserver.libinput.disableWhileTyping = true;
  services.xserver.layout = "gb";

  # Open ports in the firewall.
  networking.firewall.allowPing = true;

  nixpkgs.config.allowUnfree = true;

  networking.firewall = {
    trustedInterfaces = [ "enp56s0u2" "enp56s0u1"  ];
    allowedTCPPorts = [
      22    # SSH
      6791
      8080  # dev
      3000
      8800
      8801
      8802
      8803
      8804
    ];

    allowedUDPPorts = [
      32005
      6791
      8800
      8801
      8802
      8803
      8804
    ];

    allowedUDPPortRanges = [ ];


  };

  # VAAPI
  # https://nixos.wiki/wiki/Accelerated_Video_Playback
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      vaapiIntel
      libvdpau-va-gl
      vaapiVdpau
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
}
