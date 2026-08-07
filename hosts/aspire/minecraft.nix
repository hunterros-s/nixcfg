{
  host,
  inputs,
  pkgs,
  lib,
  ...
}:
let
  inherit (inputs.nix-minecraft.lib) collectFilesAt;

  # Committed packwiz *metadata* for the "Everyone Creates" server pack (v1.1,
  # MC 1.21.1 / NeoForge 21.1.235) — just pack.toml, index.toml and mods/*.pw.toml.
  # fetchPackwizModpack reads them from a local path (no URL/auth), pins every
  # mod jar by hash into the Nix store, and yields the mods/ dir.
  packwizDir = ../../files/minecraft/everyone-creates;
  packwiz = lib.importTOML (packwizDir + "/pack.toml");
  mcVer = packwiz.versions.minecraft; # "1.21.1"
  nfVer = packwiz.versions.neoforge; # "21.1.235"

  # Match the pack's exact loader: pkgs.neoforgeServers.neoforge-<mc>_<nf>.
  neoforgeAttr = "neoforge-${lib.replaceStrings [ "." ] [ "_" ] mcVer}-${
    lib.replaceStrings [ "." ] [ "_" ] nfVer
  }";

  # A few mods in this pack are excluded from the CurseForge API, so packwiz
  # can't fetch them. They're still downloadable from the forge CDN directly;
  # pin each by hash and re-inject them into the modpack derivation.
  manualMod =
    {
      pname,
      version,
      url,
      hash,
    }:
    pkgs.fetchurl {
      inherit
        pname
        version
        url
        hash
        ;
    };

  # { <jar path under mods/> = fetchurl args } — the API-excluded jars, indexed
  # by their destination path so .addFiles can be generated directly.
  manualMods = {
    "mods/petrolsparts-1.21.1-1.2.10.jar" = {
      pname = "petrolsparts";
      version = "1.21.1-1.2.10";
      url = "https://edge.forgecdn.net/files/7971/635/petrolsparts-1.21.1-1.2.10.jar";
      hash = "sha256-oQ07rjkaymIQSvBnztnTIaBTuMFLOJBMr3p4thql3bM=";
    };
    "mods/petrolpark-1.21.1-1.4.36.jar" = {
      pname = "petrolpark";
      version = "1.21.1-1.4.36";
      url = "https://edge.forgecdn.net/files/8251/879/petrolpark-1.21.1-1.4.36.jar";
      hash = "sha256-woxGyoOHnQAMu7dwslVLiItKdhrnc7e7YdosqjKUxPE=";
    };
    "mods/create_oxidized-0.1.3.jar" = {
      pname = "create-oxidized";
      version = "0.1.3";
      url = "https://edge.forgecdn.net/files/6286/593/create_oxidized-0.1.3.jar";
      hash = "sha256-kiH0yqcANtBaBOg+a1eET6A7YM3vat4UkcN8D3gA0GM=";
    };
    "mods/create_train_parts-0.5.0-1.21.1-6.0.10-281.jar" = {
      pname = "create-train-parts";
      version = "0.5.0";
      url = "https://edge.forgecdn.net/files/8454/289/create_train_parts-0.5.0-1.21.1-6.0.10-281.jar";
      hash = "sha256-R751hLl8kN8pWar5xByWgkSGTHuJoEsQuaGJ8VnVzHI=";
    };
    "mods/GeophilicBackported-v1.3.3 1.21.1.jar" = {
      pname = "geophilic-backport";
      version = "1.3.3";
      url = "https://edge.forgecdn.net/files/8039/064/GeophilicBackported-v1.3.3%201.21.1.jar";
      hash = "sha256-5oae322RZg9F0OzrPbWZFho13Kytv1ULlR0seD9QljE=";
    };
  };

  # Pinned modpack: packwiz-fetched mods + re-injected API-excluded jars.
  modpack =
    (pkgs.fetchPackwizModpack {
      src = packwizDir;
      packHash = "sha256-zCsErU2CpbmSYQ/nOooyujcGY+43LvOJC4BMkxsgAPQ=";
    }).addFiles
      (lib.mapAttrs (_: m: manualMod m) manualMods);

  # The pack's config/kubejs/defaultconfigs overrides are pulled from the pinned
  # server-pack zip at build time, so none of those files need to live in git.
  serverPack = pkgs.fetchurl {
    pname = "everyone-creates-serverpack";
    version = "1.1";
    url = "https://mediafilez.forgecdn.net/files/8474/534/everyone_creates_serverpack-v1.1.zip";
    hash = "sha256-0Ms3qbGBGvURupxwDSAiZAPw7+fUyS4N3cIl7pQfRY0=";
  };

  overrides = pkgs.stdenvNoCC.mkDerivation {
    pname = "everyone-creates-overrides";
    version = "1.1";
    src = serverPack;
    dontUnpack = true;
    nativeBuildInputs = [ pkgs.unzip ];
    installPhase = ''
      mkdir -p $out
      unzip -q $src 'overrides/*' -d $out
      shopt -s dotglob
      mv $out/overrides/* $out/
      rmdir $out/overrides
    '';
  };
in
{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];
  nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

  # The pack recommends ~10 GiB heap (see manifest) but this host has 8 GiB
  # total; 6G plus compressed swap is a realistic middle ground.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  services.minecraft-servers = {
    enable = true;
    eula = true;

    # Port exposure is controlled by the host firewall (25565 on tailscale0
    # only); keep nix-minecraft from opening it globally.
    openFirewall = false;

    # Run the server directly under systemd with journal logging.
    managementSystem = {
      tmux.enable = false;
      systemd-socket.enable = true;
    };

    servers.everyone-creates = {
      enable = true;

      package = pkgs.neoforgeServers.${neoforgeAttr};

      jvmOpts = [
        "-Xms3G"
        "-Xmx6G"
      ];

      # Mod jars come read-only from the Nix store; overrides are copied into
      # the mutable server dir (/srv/minecraft/everyone-creates) so runtime
      # config stays editable on the host.
      symlinks = {
        "mods" = "${modpack}/mods";
      };

      files =
        collectFilesAt overrides "config"
        // collectFilesAt overrides "kubejs"
        // collectFilesAt overrides "defaultconfigs";

      serverProperties = {
        motd = "Everyone Creates on aspire";
        max-players = 10;
        view-distance = 8;
        simulation-distance = 6;
        online-mode = true;
      };
    };
  };

  # Only start after Tailscale is up so the service only answers on the tailnet.
  systemd.services.minecraft-server-everyone-creates = {
    after = [ "tailscaled.service" ];
    requires = [ "tailscaled.service" ];
  };
}
