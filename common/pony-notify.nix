{ config, pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "pony-notify" ''
      #!/usr/bin/env bash
      set -euo pipefail

      CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/pony-notify"
      IMG="''${CACHE_DIR}/pony.png"
      TMP="''${CACHE_DIR}/pony.$$.tmp"   # Unique temp file per invocation

      mkdir -p "''${CACHE_DIR}"

      TITLE="''${1:-Pony time!}"
      BODY="''${2:-You deserve a pony.}"

      fetch_pony() {
        local url
        url="$(
          ${pkgs.curl}/bin/curl -fsSL "https://theponyapi.com/api/v1/pony/random" \
            | ${pkgs.jq}/bin/jq -r '.pony.representations.medium'
        )" || return 1

        # Download to unique temporary file
        if ! ${pkgs.curl}/bin/curl -fsSL "''${url}" -o "''${TMP}"; then
          rm -f "''${TMP}" || true
          return 1
        fi

        # Sanity-check: file must not be empty
        if [ ! -s "''${TMP}" ]; then
          rm -f "''${TMP}" || true
          return 1
        fi

        # Atomically replace cached pony
        mv -f "''${TMP}" "''${IMG}"
      }

      show_cached() {
        ${pkgs.dunst}/bin/dunstify \
          -i "''${IMG}" \
          -a "pony" \
          -r 1337 \
          "''${TITLE}" "''${BODY}"
      }

      if [ -f "''${IMG}" ]; then
        # Cached pony exists — show immediately
        show_cached

        # Try to refresh cache in background
        ( fetch_pony >/dev/null 2>&1 || true ) &

      else
        # No cache — fetch synchronously
        if fetch_pony; then
          show_cached
        else
          # API down → text fallback
          ${pkgs.dunst}/bin/dunstify -a "pony" -r 1337 "''${TITLE}" "''${BODY}"
        fi
      fi
    '')
  ];
}

