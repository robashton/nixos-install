# Reverse SSH tunnel: dial out from this laptop to ashtonnuc.ddns.net and
# expose this machine's sshd (port 22) as port 2222 on the NUC's loopback.
#
# To reach this laptop from elsewhere: SSH into the NUC, then from there:
#     ssh -p 2222 robashton@localhost
#
# The tunnel binds to the NUC's loopback only (not 0.0.0.0), so the laptop is
# never exposed to the NUC's LAN/internet directly -- you hop through the NUC.
#
# autossh + systemd handle the resilience:
#   - waits for the network at boot (network-online.target)
#   - keeps retrying while the internet is down (AUTOSSH_GATETIME=0, Restart)
#   - detects dead connections via SSH keepalives and reconnects
{ config, pkgs, ... }:

{
  systemd.services.reverse-tunnel = {
    description = "Reverse SSH tunnel to ashtonnuc.ddns.net (exposes local sshd on NUC:2222)";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    # Give autossh a clean, writable known_hosts under /var/lib so it never
    # depends on the home-manager-managed ~/.ssh state.
    serviceConfig = {
      User = "robashton";
      Group = "users";
      StateDirectory = "reverse-tunnel";
      Environment = "AUTOSSH_GATETIME=0";  # keep retrying even if the first dial fails fast

      ExecStart = ''
        ${pkgs.autossh}/bin/autossh -M 0 -N \
          -o "ServerAliveInterval=30" \
          -o "ServerAliveCountMax=3" \
          -o "ExitOnForwardFailure=yes" \
          -o "StrictHostKeyChecking=accept-new" \
          -o "UserKnownHostsFile=/var/lib/reverse-tunnel/known_hosts" \
          -i /home/robashton/.ssh/id_ed25519 \
          -R 2222:localhost:22 \
          robashton@ashtonnuc.ddns.net
      '';

      Restart = "always";
      RestartSec = "10";
    };
  };
}
