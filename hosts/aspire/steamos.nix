{ inputs, pkgs, ... }:
let
  vanillaGamescope =
    (import inputs.nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
    }).gamescope;
  # Steam's remote-play decoder is a 32-bit binary: it loads a 32-bit VA-API
  # driver from /run/opengl-driver-32, so both arches of the Intel i965 driver
  # must be present for hardware decoding to work on this laptop's iGPU.
  pkgsi686Linux = import inputs.nixpkgs {
    system = "i686-linux";
    config.allowUnfree = true;
  };
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

  # Intel iGPU VA-API driver (legacy i965, Kaby Lake) for Steam hardware
  # decoding of remote-play streams — 64-bit and the 32-bit copy Steam's
  # decoder actually loads.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-vaapi-driver
    ];
    extraPackages32 = with pkgsi686Linux; [
      intel-vaapi-driver
      libva
    ];
  };
}
