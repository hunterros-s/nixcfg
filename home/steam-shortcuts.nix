{ inputs, pkgs, ... }:
{
  imports = [
    inputs.json2steamshortcut.homeModules.default
  ];

  # Declarative Steam "non-Steam game" shortcuts, generated from JSON by
  # json2steamshortcut instead of hand-rolling text/binary VDF. Runs as a
  # Home Manager module so rebuilds regenerate shortcuts.vdf.
  services.steam-shortcuts = {
    enable = true;
    overwriteExisting = true;
    steamUserId = 112221863;
    shortcuts = [
      {
        AppName = "Moonlight";
        Exe = "${pkgs.moonlight-qt}/bin/moonlight";
        StartDir = "${pkgs.moonlight-qt}/bin";
        Tags = [
          "Streaming"
        ];
      }
    ];
  };
}
