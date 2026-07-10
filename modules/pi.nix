{
  home =
    {
      pkgs,
      config,
      inputs,
      ...
    }:
    let
      system = pkgs.stdenv.hostPlatform.system;
      piCorner = "${config.home.homeDirectory}/.pi/npm";

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
    };

  nixos = {
    nix.settings = {
      extra-substituters = [ "https://cache.numtide.com" ];
      extra-trusted-public-keys = [
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      ];
    };
  };
}
