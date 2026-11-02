{
  pkgs,
  config,
  inputs,
  lib,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;

  settings = builtins.fromJSON (builtins.readFile ./pi/settings.json);
  settingsFile = (pkgs.formats.json { }).generate "pi-settings.json" settings;

  secretsFile = ../secrets/pi.yaml;
  sops = config.my.sops.package;

  sopsProviders = {
    opencode-go = "opencode-go";
  };

  authSeed = lib.mapAttrs (_: secretKey: {
    type = "api_key";
    key = "!${sops}/bin/sops -d --extract '[\"${secretKey}\"]' ${secretsFile}";
  }) sopsProviders;

  authSeedFile = (pkgs.formats.json { }).generate "pi-auth-seed.json" authSeed;
in
{
  home.packages = [ inputs.pi.packages.${system}.default ];

  home.sessionVariables = {
    PI_SKIP_VERSION_CHECK = "1";
    PI_TELEMETRY = "0";
  };

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

  home.activation.piAuth = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    set -eu
    target="$HOME/.pi/agent/auth.json"
    ${pkgs.coreutils}/bin/mkdir -p "$(${pkgs.coreutils}/bin/dirname "$target")"
    [ -f "$target" ] || printf '{}\n' > "$target"

    tmp="$(${pkgs.coreutils}/bin/mktemp "$target.XXXXXX")"
    ${pkgs.jq}/bin/jq --slurpfile add ${lib.escapeShellArg (toString authSeedFile)} '
      . as $cur
      | reduce ($add[0] | keys_unsorted[]) as $k
          ($cur; .[$k] = $add[0][$k])
    ' "$target" > "$tmp"

    ${pkgs.coreutils}/bin/chmod 600 "$tmp"
    ${pkgs.coreutils}/bin/mv "$tmp" "$target"
  '';
}
