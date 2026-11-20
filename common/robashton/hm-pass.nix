{ pkgs, lib, ... }:

# pass, with its store living (encrypted) in the nixos-install-private checkout,
# and the GPG key it's encrypted to imported from that repo on activation.
let
  gpg = "${pkgs.gnupg}/bin/gpg";
  key = pkgs.ashton-private.gpg;
in
{
  programs.password-store = {
    enable = true;
    settings.PASSWORD_STORE_DIR = "$HOME/src/nixos-install-private/password-store";
  };

  # The export is passphrase-protected, so --batch can import it without a
  # pinentry; the passphrase is only asked for when the key is first used.
  # Hand-rolled entryAfter, as this file only gets nixpkgs' lib, not lib.hm.
  home.activation.importGpgKey = {
    after = [ "writeBoundary" ];
    before = [ ];
    data = ''
      if ! ${gpg} --list-secret-keys ${key.fingerprint} >/dev/null 2>&1; then
        run ${gpg} --batch --import ${key.secretKey}
      fi
      echo "${key.fingerprint}:6:" | run ${gpg} --batch --import-ownertrust
    '';
  };
}
