# vpn-steve: the L2TP/IPsec link into Steve's network (172.30.0.0/24, which is
# where the buck2 cache lives). Declared here rather than clicked together in
# GNOME so that it carries its own route and needs nobody logged in; with
# alwaysOn (the jump box) it also comes up at boot and reconnects when it drops.
#
# Secrets stay out of the nix store. Create this file (root:root, mode 0600)
# on each host before switching:
#
#   /etc/nixos/secrets/vpn-steve.env
#     VPN_STEVE_PASSWORD=...   # the L2TP user password for `rob`
#     VPN_STEVE_PSK=...        # the IPsec pre-shared key
#
{ config, lib, pkgs, ... }:

let
  cfg = config.id3as.vpnSteve;
in
{
  options.id3as.vpnSteve = {
    enable = lib.mkEnableOption "the vpn-steve L2TP/IPsec connection profile";

    # Only one machine behind a given NAT can hold this L2TP session at a time
    # (the server cannot tell two tunnels from the same public IP apart), so only
    # the jump box keeps it up; elsewhere it is there for a manual `nmcli con up`.
    alwaysOn = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Autoconnect vpn-steve and keep reconnecting it when it drops.";
    };

    secretsFile = lib.mkOption {
      type = lib.types.str;
      default = "/etc/nixos/secrets/vpn-steve.env";
      description = "EnvironmentFile providing VPN_STEVE_PASSWORD and VPN_STEVE_PSK.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.networkmanager = {
      enable = true;
      plugins = [
        pkgs.networkmanager-l2tp
        pkgs.networkmanager-strongswan # For IPsec part of L2TP
      ];

      ensureProfiles = {
        environmentFiles = [ cfg.secretsFile ];
        profiles.vpn-steve = {
          connection = {
            id = "vpn-steve";
            uuid = "e1f9b9f9-9429-4ace-aeaa-55d9e938f73b";
            type = "vpn";
            autoconnect = lib.boolToString cfg.alwaysOn;
          };
          vpn = {
            service-type = "org.freedesktop.NetworkManager.l2tp";
            gateway = "85.95.46.253";
            ipsec-enabled = "yes";
            machine-auth-type = "psk";
            user-auth-type = "password";
            user = "rob";
            # 0 = stored in the profile, so no user secret agent is needed
            password-flags = "0";
            ipsec-psk-flags = "0";
          };
          vpn-secrets = {
            password = "$VPN_STEVE_PASSWORD";
            ipsec-psk = "$VPN_STEVE_PSK";
          };
          ipv4 = {
            method = "auto";
            never-default = "true";
            # The server doesn't push this; it used to be a manual `ip route add`
            route1 = "172.30.0.0/24";
          };
          ipv6 = {
            method = "auto";
            never-default = "true";
          };
        };
      };
    };

    services.strongswan = {
      enable = true;
      secrets = [
        "ipsec.d/ipsec.nm-l2tp.secrets"
      ];
    };

    # NetworkManager-l2tp runs `ipsec` outside the strongswan.service context, so it
    # never sees that service's STRONGSWAN_CONF env var and falls back to reading
    # /etc/strongswan.conf — which the services.strongswan module doesn't create.
    # Without it, charon loads no crypto plugins and aborts ("HASH_SHA1 / NONCE_GEN
    # unmet dependency", surfaced by NM as "integrity test of libstrongswan failed"),
    # so the vpn-steve L2TP/IPsec connection fails to come up.
    #
    # This strongSwan build has no standalone sha1/aes/hmac plugins; it provides all
    # crypto via the openssl plugin, so we must load plugins explicitly (load_modular
    # = no) rather than rely on the empty per-plugin conf stubs.
    environment.etc."strongswan.conf".text = ''
      charon {
        load_modular = no
        load = random nonce openssl gmp pem pkcs1 pkcs8 pubkey x509 revocation constraints kernel-netlink socket-default stroke updown resolve xauth-generic

        install_routes = no
        install_virtual_ip = no

        plugins {
          stroke {
            secrets_file = /etc/ipsec.secrets
          }
        }
      }
    '';

    # NM won't reliably re-activate a VPN profile after it drops (or after the
    # underlying link changes), so poke it back up whenever we have a network.
    systemd.services.vpn-steve-keepalive = lib.mkIf cfg.alwaysOn {
      description = "Keep the vpn-steve connection up";
      wantedBy = [ "multi-user.target" ];
      after = [ "NetworkManager.service" "NetworkManager-ensure-profiles.service" ];
      wants = [ "NetworkManager-ensure-profiles.service" ];
      path = [ pkgs.networkmanager pkgs.gnugrep ];
      script = ''
        while true; do
          if nmcli -t -f STATE general | grep -q '^connected' \
             && ! nmcli -t -f NAME connection show --active | grep -qx vpn-steve; then
            nmcli connection up vpn-steve || true
          fi
          sleep 30
        done
      '';
      serviceConfig = {
        Restart = "always";
        RestartSec = 10;
      };
    };
  };
}
