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

  powerManagement.enable = true;
  hardware.cpu.intel.updateMicrocode = true;

  networking.hostName = "ashton-xps";

  boot.loader.grub.device = "/dev/nvme0n1";
  
  networking.wireless.enable = true;

  services.xserver.autorun = true; 
  services.xserver.xkbOptions = "ctrl:swapcaps";
#  services.xserver.synaptics.enable = true;
  services.xserver.videoDrivers = [ "intel" "modesetting" ];

  boot.blacklistedKernelModules = [ "nouveau" ];

#  boot.extraModprobeConfig = ''
#    options bbswitch load_state=-1 unload_state=1
#    '';

  #hardware.nvidia.modesetting.enable = true;
  #hardware.nvidia.optimus_prime.enable = true;
  #hardware.nvidia.optimus_prime.nvidiaBusId = "PCI:1:0:0";
  #hardware.nvidia.optimus_prime.intelBusId = "PCI:0:2:0";

  environment.systemPackages = with pkgs; [
    xorg.xbacklight
    bumblebee
    powertop
    pmutils
  ];

  boot.kernelParams = [ "acpi_osi=!" "acpi_osi=\"Windows 2009\""];
  hardware.bumblebee.enable = true;
 # hardware.bumblebee.group = "video";
 # hardware.bumblebee.pmMethod = "bbswitch";
 # hardware.bumblebee.connectDisplay = true;

  services.xserver.libinput.enable = true;
  services.xserver.libinput.clickMethod = "buttonareas";
  services.xserver.libinput.tapping = true;
  services.xserver.libinput.disableWhileTyping = true;
  services.xserver.layout = "gb";

  # Open ports in the firewall.
  networking.firewall.allowPing = true;

  networking.firewall = {
    trustedInterfaces = [
      "arqiva0" "arqiva1" "arqiva2" "arqiva3" "arqiva4" 
      "perform0" "perform1" "perform2" "perform3" "perform4" 
    ]; 
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
}
