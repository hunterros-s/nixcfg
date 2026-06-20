{ lib, pkgs, ... }:

let
  # On Arch/non-NixOS, use the system terminal so it uses the system GPU stack.
  # Nix-built Alacritty can fail without non-nixos-gpu setup.
  alacrittyExe = "/usr/bin/alacritty";
  btopExe = lib.getExe pkgs.btop;
  pavucontrolExe = lib.getExe pkgs.pavucontrol;
  overskrideExe = lib.getExe pkgs.overskride;
in
{
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    btop
    font-awesome
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    networkmanager
    overskride
    pavucontrol
  ];

  programs.waybar = {
    enable = true;
    package = pkgs.waybar;

    settings.mainBar = {
      layer = "top";
      position = "top";
      spacing = 16;
      height = 24;

      modules-left = [ "clock" ];
      modules-center = [ "niri/window" ];
      modules-right = [
        "pulseaudio"
        "network"
        "bluetooth"
        "group/cpu"
        "group/gpu"
        "memory"
      ];

      clock = {
        format = "{:%a %b %e %I:%M %p}";
        tooltip = false;
      };

      "niri/window" = {
        format = "{title}";
      };

      network = {
        format = "{icon} {essid} ({signalStrength}%)";
        format-icons = {
          wifi = [
            "󰤯"
            "󰤟"
            "󰤢"
            "󰤥"
            "󰤨"
          ];
          ethernet = [ "󰈀" ];
          disconnected = [ "󰤭" ];
        };
        tooltip = true;
        tooltip-format = "SSID: {essid}\nStrength: {signalStrength}%\nIP: {ipaddr}";
        tooltip-format-disconnected = "Disconnected";
        on-click = "${alacrittyExe} -e ${pkgs.networkmanager}/bin/nmtui";
      };

      bluetooth = {
        format = " ({num_connections} connected)";
        on-click = overskrideExe;
        tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
        tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
        tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
        tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
      };

      pulseaudio = {
        scroll-step = 5;
        format = "{icon}  {volume}%";
        format-bluetooth = " {icon}";
        format-muted = "";
        format-icons = {
          "default" = [
            ""
            ""
            ""
          ];
        };
        tooltip = true;
        tooltip-format = "Volume: {volume}%\nMicrophone: {format_source}";
        on-click = pavucontrolExe;
      };

      memory = {
        format = "RAM {used:0.1f}GB";
        on-click = "${alacrittyExe} -e ${btopExe}";
      };

      "group/cpu" = {
        orientation = "horizontal";
        modules = [
          "cpu"
          "temperature#cpu"
        ];
      };

      cpu = {
        format = "CPU {usage}%";
        on-click = "${alacrittyExe} -e ${btopExe}";
      };

      "temperature#cpu" = {
        hwmon-path = "/sys/class/hwmon/hwmon2/temp1_input";
        critical-threshold = 80;
        format = " {temperatureC}°C";
        on-click = "${alacrittyExe} -e ${btopExe}";
      };

      "group/gpu" = {
        orientation = "horizontal";
        modules = [
          "custom/gpu-util"
          "temperature#gpu"
        ];
      };

      "custom/gpu-util" = {
        exec = "cat /sys/class/drm/card1/device/gpu_busy_percent";
        format = "GPU {}%";
        interval = 1;
        on-click = "${alacrittyExe} -e ${btopExe}";
      };

      "temperature#gpu" = {
        hwmon-path = "/sys/class/hwmon/hwmon1/temp1_input";
        critical-threshold = 80;
        format = " {temperatureC}°C";
        on-click = "${alacrittyExe} -e ${btopExe}";
      };
    };

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", "Font Awesome 6 Free", "Symbols Nerd Font", "sans-serif";
        font-size: 14px;
        border: none;
        border-radius: 0;
      }

      window#waybar {
        background-color: rgba(0, 0, 0, 0.65);
        color: #ffffff;
      }

      #clock,
      #pulseaudio,
      #network,
      #bluetooth,
      #cpu,
      #memory,
      #temperature {
        margin: 0px 4px;
      }

      .modules-left {
        margin-left: 12px;
      }

      .modules-right {
        margin-right: 12px;
      }
    '';
  };
}
