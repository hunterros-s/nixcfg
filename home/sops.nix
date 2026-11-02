{ pkgs, config, ... }:
{
  home.packages = [
    # Pin the age key path; sops' macOS default lives under ~/Library.
    (pkgs.writeShellScriptBin "sops" ''
      export SOPS_AGE_KEY_FILE="${config.home.homeDirectory}/.config/sops/age/keys.txt"
      exec ${pkgs.sops}/bin/sops "$@"
    '')
    pkgs.age
  ];
}
