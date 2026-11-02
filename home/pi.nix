{
  pkgs,
  inputs,
  lib,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;

  settings = builtins.fromJSON (builtins.readFile ./pi/settings.json);
  settingsFile = (pkgs.formats.json { }).generate "pi-settings.json" settings;
in
{
  home.packages = [ inputs.pi.packages.${system}.default ];

  # Keep the privacy defaults the previous package applied.
  home.sessionVariables = {
    PI_SKIP_VERSION_CHECK = "1";
    PI_TELEMETRY = "0";
  };

  # Merge declared settings into the live file on each switch so Pi can still
  # persist runtime keys such as lastChangelogVersion. Declared keys win.
  home.activation.piSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    set -eu
    target="$HOME/.pi/agent/settings.json"
    ${pkgs.coreutils}/bin/mkdir -p "$(dirname "$target")"

    if [ ! -f "$target" ]; then
      printf '{}\n' > "$target"
    fi

    tmp="$(${pkgs.coreutils}/bin/mktemp "$target.XXXXXX")"
    ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$target" ${settingsFile} > "$tmp"
    ${pkgs.coreutils}/bin/chmod 600 "$tmp"
    ${pkgs.coreutils}/bin/mv "$tmp" "$target"
  '';
}
