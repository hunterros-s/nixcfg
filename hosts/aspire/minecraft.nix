{ ... }:

{
  # Craftoria recommends Java 21 and a 5 GiB server heap. Compressed swap gives
  # the rest of this 8 GiB host some breathing room until RAM is upgraded.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  virtualisation = {
    podman = {
      enable = true;
      autoPrune.enable = true;
    };

    oci-containers = {
      backend = "podman";

      containers.craftoria = {
        image = "itzg/minecraft-server:java21";
        autoStart = true;

        # Binding specifically to the Tailscale address prevents LAN/public
        # access even independently of the firewall.
        ports = [
          "100.80.194.77:25565:25565"
          "100.80.194.77:24454:24454/udp"
        ];

        volumes = [
          "/srv/minecraft/craftoria:/data"
          "/srv/minecraft/downloads:/downloads"
        ];

        environment = {
          EULA = "TRUE";
          TYPE = "AUTO_CURSEFORGE";

          # Pin Craftoria 1.31.0. AUTO_CURSEFORGE needs the client-pack file,
          # not the separately published server-pack file.
          CF_PAGE_URL = "https://www.curseforge.com/minecraft/modpacks/craftoria/files/8127261";

          # Mirror Craftoria's official server-side exclusions.
          CF_EXCLUDE_MODS = builtins.concatStringsSep "," [
            "737481"
            "363363"
            "908741"
            "986380"
            "844662"
            "568563"
            "915902"
            "690971"
            "455508"
            "1089803"
            "925889"
            "1112793"
            "1133580"
            "1274497"
            "1254143"
            "1285475"
            "646146"
            "1351246"
            "1326436"
          ];

          MEMORY = "5G";
          MOTD = "Craftoria on aspire";
          MAX_PLAYERS = "10";
          VIEW_DISTANCE = "8";
          SIMULATION_DISTANCE = "6";
          ONLINE_MODE = "TRUE";
          TZ = "America/New_York";

          # Make the persistent files editable by hunter on the host.
          UID = "1000";
          GID = "100";
        };
      };
    };
  };

  systemd = {
    services.podman-craftoria = {
      after = [ "tailscaled.service" ];
      requires = [ "tailscaled.service" ];
    };

    tmpfiles.rules = [
      "d /srv/minecraft/craftoria 0770 hunter users - -"
      "d /srv/minecraft/downloads 0770 hunter users - -"
    ];
  };
}
