{ inputs, pkgs, ... }:
let
  # Our nixpkgs' own, un-overlaid gamescope derivation. Jovian vendors Valve's
  # gamescope tag to match SteamOS (see their overlay.nix), which keeps nixpkgs'
  # gamescope patches — written for the version *our* nixpkgs ships — applied to
  # a different source tree, so the patch hunks fail. On a non-Deck HTPC the
  # stock compositor is exactly right, so instead of pinning a version by hand,
  # re-point Jovian's vendored src/version at our nixpkgs' own gamescope.
  # Because both version *and* source come from our nixpkgs, this stays
  # correct through every `nix flake update` and even branch upgrades.
  vanillaGamescope =
    (import inputs.nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
    }).gamescope;
in
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

  nixpkgs.overlays = [
    (
      final: prev:
      let
        gamescope = prev.gamescope.overrideAttrs {
          src = vanillaGamescope.src;
          version = vanillaGamescope.version;
        };
      in
      {
        inherit gamescope;
        # Jovian builds a separate WSI (Wayland shared interface) helper from
        # the same source; rebuild it from the un-vendored package too.
        gamescope-wsi = gamescope.override {
          enableExecutable = false;
          enableWsi = true;
        };
      }
    )
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

  environment.systemPackages = with pkgs; [
    moonlight-qt
  ];
}
