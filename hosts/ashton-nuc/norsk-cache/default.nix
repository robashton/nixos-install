# vim: set sts=2 ts=2 sw=2 expandtab :

# The Norsk private Nix binary cache (s3://norsk-binary-cache, eu-west-1), so that
# a `nix develop` on the jankings runner substitutes the expensive dependencies
# (onnx, cuda, ffmpeg...) instead of compiling them. Upstream docs live in the
# norsk checkout: scripts/nix/config/README.md.
#
# Two independent axes, both required:
#
# 1. The substituter + its signing key, declared HERE, at system level. It has to
#    be system level: norsk's flake.nix also declares them in nixConfig, but a
#    flake-declared substituter is ignored for users who are not in the daemon's
#    trusted-users, and the accept prompt is answered per-$HOME. The runner's
#    $HOME is wiped every job, so non-interactively that prompt defaults to "no".
#    System config is authoritative regardless of who runs the build.
#
# 2. Credentials, which are NOT here (see below). The bucket is private on purpose
#    -- some dependencies bundle licensed libraries -- so every read authenticates.
#
# Credentials, and why this box is the awkward case
# -------------------------------------------------
# Substitution runs inside the nix-daemon (root), not in the calling user's shell,
# so it is the daemon that needs AWS credentials. On the EC2 fleet the daemon just
# picks up the instance's IAM role from IMDS and there is nothing to configure.
# This box is a NUC under a desk with no instance role, so it uses the dedicated
# read-only, non-MFA IAM user `norsk-binary-cache-reader` instead. Its access key
# is written to /root/.aws/credentials imperatively by
#
#     ~/src/norsk/scripts/nix/install-cache.sh --with-daemon-creds
#
# which pulls it from SSM (/norsk/nix-cache/reader-credentials) using a human MFA
# session. It stays out of this repo deliberately: it is a secret, and anything
# referenced from a nix expression is copied into the world-readable store.
#
# That key is long-lived and not MFA-gated, so once written it keeps working
# across reboots and rebuilds with no human in the loop. The only thing that
# invalidates it is an owner running create-cache-reader-iam.sh --rotate, after
# which re-run install-cache.sh --with-daemon-creds here.
#
# The AWS_SHARED_CREDENTIALS_FILE below is what makes that file visible to the
# daemon: systemd sets no $HOME for services running as root, and without $HOME
# the AWS SDK cannot locate ~/.aws by itself. Naming the file explicitly avoids
# relying on its /etc/passwd fallback, and avoids the side effects of setting
# $HOME=/root on the daemon (which would also make it read root's nix.conf).

{ config, pkgs, lib, ... }:
{
  nix.settings = {
    extra-substituters = [ "s3://norsk-binary-cache?region=eu-west-1" ];
    extra-trusted-public-keys = [ "norsk-cache-1:KwyoUy3m88th8dXuHPbH1Q8Sa8n0ntZBGGcBZB70dSQ=" ];

    # Silences the accept prompt from norsk's flake re-declaring the two settings
    # above. Redundant for the cache itself, but the prompt is noise in CI logs.
    accept-flake-config = true;
  };

  systemd.services.nix-daemon.environment.AWS_SHARED_CREDENTIALS_FILE =
    "/root/.aws/credentials";
}
