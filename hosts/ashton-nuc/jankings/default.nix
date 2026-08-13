# vim: set sts=2 ts=2 sw=2 expandtab :

# The GitHub Actions runner's service user. This used to be created imperatively by
# the useradd in /home/jankings/runner/install.sh, which now falls into its "user
# already exists" branch and does nothing.
#
# The uid and gid are pinned to what install.sh happened to allocate, because
# /home/jankings/runner-state carries the runner registrations and was restored from
# a backup that stores ownership numerically. Changing them orphans those files.

{ config, pkgs, lib, ... }:
 {

  users.groups.jankings = {
    gid = 2002;
  };

  users.users.jankings = {
    isNormalUser = true;
    uid = 1006;
    group = "jankings";
    extraGroups = [ "docker" "disk" ];
    createHome = true;
    home = "/home/jankings";
  };
}
