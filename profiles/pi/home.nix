{
  pkgs,
  config,
  inputs,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  piCorner = "${config.home.homeDirectory}/.pi/npm"; # writable extension home

  pi = pkgs.symlinkJoin {
    name = "pi";
    paths = [ inputs.llm-agents.packages.${system}.pi ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/pi \
        --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.nodejs_24 ]} \
        --set NPM_CONFIG_PREFIX ${piCorner}
    '';
  };
in
{
  home.packages = [ pi ];
}
