# vim: set sts=2 ts=2 sw=2 expandtab :

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

  hardware.cpu.intel.updateMicrocode = true;

  networking.hostName = "ashton-nuc";
  boot.loader.grub.device = "/dev/nvme0n1";

  # Open ports in the firewall.
  networking.firewall.allowPing = true;

  networking.firewall.interfaces.trusted = {
    allowedTCPPorts = [
      22    # SSH
    ];

    allowedUDPPorts = [
    ];

    allowedUDPPortRanges = [
    ];
  };

  # VAAPI
  # https://nixos.wiki/wiki/Accelerated_Video_Playback
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
}
