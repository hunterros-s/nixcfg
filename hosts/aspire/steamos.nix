{ inputs, pkgs, ... }:
{
  imports = [
    inputs.jovian-nixos.nixosModules.default
  ];

  # Controller-first HTPC: boot straight into the Steam Deck UI. The session is
  # gamescope running Steam with `-steamos3 -gamepadui` (Jovian's patched
  # gamescope-session), which is what makes the Steam UI show its WiFi and
  # Bluetooth panels. `autoStart` wires up SDDM auto-login for `hunter` and
  # relogs if the session dies, so no keyboard is ever needed at boot.
  jovian.steam = {
    enable = true;
    autoStart = true;
    user = "hunter";
    # No desktop environment; "Switch to Desktop" just relaunches Gaming Mode.
    desktopSession = "gamescope-wayland";
  };

  # Jovian vendors Valve's gamescope 3.16.26 tag to match SteamOS, but keeps
  # nixpkgs' gamescope patches (which target the version our nixpkgs ships,
  # 3.16.25). On top of nixos-26.05 that patch set fails to apply to the
  # 3.16.26 source, so pin the vendored source back to 3.16.25 — the exact
  # tree the patches in our nixpkgs lock were written for.
  nixpkgs.overlays = [
    (final: prev: let
      gamescope = prev.gamescope.overrideAttrs (old: {
        version = "3.16.25";
        src = final.fetchFromGitHub {
          owner = "ValveSoftware";
          repo = "gamescope";
          rev = "3.16.25";
          fetchSubmodules = true;
          hash = "sha256-KPIUoHMzArqEVbhS8hrvzQUV906MydBPm5ZmV/CVS3A=";
        };
      });
    in
    {
      inherit gamescope;
      # Jovian builds a separate WSI (Wayland shared interface) helper from
      # the same source, so rebuild it from the pinned one as well.
      gamescope-wsi = gamescope.override {
        enableExecutable = false;
        enableWsi = true;
      };
    })
  ];

  # The Deck UI's Bluetooth panel talks to BlueZ (WiFi settings already work
  # through NetworkManager, enabled in ./nixos.nix).
  hardware.bluetooth.enable = true;

  # Audio for the TV / soundbar, plus Bluetooth audio device support.
  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;
  };
}