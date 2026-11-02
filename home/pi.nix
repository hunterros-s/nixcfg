{
  pkgs,
  inputs,
  lib,
  ...
}:
let
  authSeed = lib.genAttrs [ "opencode-go" ] (name: {
    type = "api_key";
    key = "!sops -d --extract '[\"${name}\"]' ${../secrets/pi.yaml}";
  });

  # pi writes to these files itself, so merge instead of symlinking.
  mergeInto = file: filter: src: ''
    target="$HOME/.pi/agent/${file}"
    mkdir -p "$(dirname "$target")"
    [ -f "$target" ] || echo '{}' > "$target"
    tmp="$(mktemp "$target.XXXXXX")"
    ${lib.getExe pkgs.jq} -s '${filter}' "$target" ${src} > "$tmp"
    chmod 600 "$tmp"
    mv "$tmp" "$target"
  '';
in
{
  home.packages = [ inputs.pi.packages.${pkgs.stdenv.hostPlatform.system}.default ];

  home.sessionVariables = {
    PI_SKIP_VERSION_CHECK = "1";
    PI_TELEMETRY = "0";
  };

  home.activation.pi = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    ${mergeInto "settings.json" ".[0] * .[1]" ./pi/settings.json}
    ${mergeInto "auth.json" ".[0] + .[1]" (
      (pkgs.formats.json { }).generate "pi-auth-seed.json" authSeed
    )}
  '';
}
