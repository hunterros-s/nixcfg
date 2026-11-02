{
  pkgs,
  config,
  lib,
  ...
}:
let
  ageKeyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

  # Self-contained sops: always points at this machine's age key, without
  # exporting SOPS_AGE_KEY_FILE into every shell.
  sops = pkgs.writeShellScriptBin "sops" ''
    export SOPS_AGE_KEY_FILE=${lib.escapeShellArg ageKeyFile}
    exec ${pkgs.sops}/bin/sops "$@"
  '';
in
{
  options.my.sops = {
    package = lib.mkOption {
      type = lib.types.package;
      description = "sops wrapper configured for this machine's age key.";
    };

    ageKeyFile = lib.mkOption {
      type = lib.types.str;
      description = "Path to this machine's age private key.";
    };
  };

  config = {
    my.sops.package = sops;
    my.sops.ageKeyFile = ageKeyFile;

    home.packages = [
      sops
      pkgs.age
    ];
  };
}
