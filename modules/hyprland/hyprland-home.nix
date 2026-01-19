{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  toggle-mic = pkgs.writeShellApplication {
    name = "toggle-mic";
    runtimeInputs = [
      pkgs.wireplumber
      pkgs.hyprland
    ]; # Provides wpctl and hyprctl
    text = builtins.readFile ./scripts/toggle-mic.sh;
  };
in
{
  imports = [
    inputs.stylix.homeModules.stylix
  ];

  # Enable the service properly (replaces manual exec-once)
  services.gnome-keyring.enable = true;

  stylix = {
    enable = true;
    image = ./wallpapers/shorewallpaper-ultrawide.png;
    polarity = "dark";

    targets.vscode = {
      enable = false;
    };
    targets.obsidian = {
      enable = false;
    };

    opacity = {
      desktop = 0.6;
      terminal = 0.9;
    };

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
      sizes = {
        applications = 11;
        terminal = 14;
      };
    };

    icons = {
      enable = true;
      package = pkgs.papirus-icon-theme;
      dark = "Papirus-Dark";
      light = "Papirus-Light";
    };

    targets.hyprland.enable = true;
    targets.hyprland.hyprpaper.enable = true;
    targets.waybar.enable = true;
    targets.rofi.enable = true;
  };

  programs.rofi.enable = true;
  programs.hyprshot.enable = true;
  programs.waybar.enable = true;
  services.swaync.enable = true;
  services.hyprpaper.enable = true;
  services.blueman-applet.enable = true;

  home.file = {
    ".config/waybar" = {
      source = ./waybar;
      recursive = true;
    };
  };

  home.packages = with pkgs; [
    toggle-mic
    pavucontrol # audiocontrol
    material-symbols
    font-awesome # For the Font Awesome glyphs
    nerd-fonts.symbols-only # The "Master" icon font for 2026
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    blueman
    libappindicator-gtk3 # Required for modern tray icon support
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;
    settings = {
      "$mainMod" = "SUPER";
      "$terminal" = "ghostty";
      "$filemanager" = "thunar";
      "$browser" = "chromium";
      "$code" = "code";
      "$menu" = "rofi -show drun";

      exec-once = [
        "uwsm finalize SSH_AUTH_SOCK"
        "hyprlock && uwsm app -- signal-desktop --start-in-tray --password-store=\"gnome-libsecret\""
        "uwsm app -- waybar"
        "uwsm app -- 1password --silent"
        "uwsm app -- discord --start-minimized"
      ];

      env = [
        "ELECTRON_OZONE_PLATFORM_HINT,auto"
      ];

      misc = {
        # Allows SwayNC to focus the window when a notification is clicked
        focus_on_activate = true;
      };

      bind = [
        "$mainMod, Return, exec, $terminal"
        "$mainMod, e, exec, $filemanager"
        "$mainMod, b, exec, $browser"
        "$mainMod, v, exec, $code"
        "$mainMod, o, exec, $menu"
        "$mainMod, q, killactive"
        "$mainMod, f, togglefloating"
        "$mainMod, m, fullscreen, 1"
        "$mainMod, s, togglefloating"
        "$mainMod, t, fullscreen, 0"
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, XF86KbdBrightnessDown, exec, ${pkgs.hyprshot}/bin/hyprshot -m window" # F5
        "$mainMod, XF86LaunchB, exec, ${pkgs.hyprshot}/bin/hyprshot -m region" # F4
        "$mainMod, Tab, cyclenext,"
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"
        "$mainMod, P, pseudo"
        "$mainMod, J, layoutmsg, togglesplit"
        "$mainMod, L, exec, hyprlock"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        "$mainMod, Delete, exec, ${toggle-mic}/bin/toggle-mic"
      ];

      binde = [
        ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-"
      ];

      dwindle = {
        pseudotile = true;
        force_split = 2;
        preserve_split = true;
        single_window_aspect_ratio = "5 4";
      };

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      windowrule = [
        "tag +game, match:initial_class ^(steam_app_\\d+)$"
        "fullscreen 1, match:tag game"
        "immediate on, match:tag game"
        "workspace 9, match:tag game"
      ];

      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 5;
          passes = 3;
        };
      };

      animations = {
        enabled = true;
        animation = [
          "windows, 1, 5, default"
          "fade, 1, 5, default"
          "workspaces, 1, 5, default"
        ];
      };

      monitor = [
        "HDMI-A-1,preferred,auto,1"
      ];
    };
  };

  programs.hyprlock = {
    enable = true;

    settings = {
      # BACKGROUND
      background = {
        monitor = "";
        # path = ./wallpapers/shorewallpaper-ultrawide.png;
        blur_passes = 3;
        contrast = 0.8916;
        brightness = 0.8172;
        vibrancy = 0.1696;
        vibrancy_darkness = 0.0;
      };

      # GENERAL
      general = {
        no_fade_in = false;
        no_fade_out = false;
        hide_cursor = true;
        grace = 0;
        disable_loading_bar = true;
      };

      # Profile-Photo
      image = [
        {
          monitor = "";
          path = "${./icons/profile-2.png}";
          border_size = 2;
          border_color = "rgba(255, 255, 255, 0)";
          size = 200;
          rounding = -1;
          rotate = 0;
          reload_time = -1;
          reload_cmd = "";
          position = "0, 40";
          halign = "center";
          valign = "center";
        }
      ];

      # SHAPE (The "Blurred" Box effect)
      # shape = [
      #   {
      #     monitor = "";
      #     size = "300, 60";
      #     color = "rgba(255, 255, 255, .1)";
      #     rounding = -1;
      #     border_size = 0;
      #     border_color = "rgba(253, 198, 135, 0)";
      #     rotate = 0;
      #     xray = false;
      #     position = "0, -130";
      #     halign = "center";
      #     valign = "center";
      #   }
      # ];

      # LABELS (Date, Time, User, Song)
      label = [
        # Day-Month-Date
        {
          monitor = "";
          text = "cmd[update:1000] echo -e \"$(date +\"%A, %B %d\")\"";
          color = "rgba(216, 222, 233, 0.70)";
          font_size = 25;
          font_family = "SF Pro Display Bold";
          position = "0, 350";
          halign = "center";
          valign = "center";
        }
        # Time
        {
          monitor = "";
          text = "cmd[update:1000] echo \"<span>$(date +\"%I:%M\")</span>\"";
          color = "rgba(216, 222, 233, 0.70)";
          font_size = 120;
          font_family = "SF Pro Display Bold";
          position = "0, 250";
          halign = "center";
          valign = "center";
        }
        # USER
        {
          monitor = "";
          text = "Luka Jurukovski";
          color = "rgba(216, 222, 233, 0.80)";
          # outline_thickness = 2;
          font_size = 18;
          font_family = "SF Pro Display Bold";
          position = "0, -100";
          halign = "center";
          valign = "center";
        }
      ];

      # INPUT FIELD
      "input-field" = {
        monitor = "";
        size = "300, 45";
        outline_thickness = 2;
        dots_size = 0.2;
        dots_spacing = 0.2;
        dots_center = true;
        rounding = 25;
        inner_color = lib.mkForce "rgba(255, 255, 255, 0.05)";
        font_size = 8;
        font_family = "SF Pro Display Bold";
        placeholder_text = "<i><span foreground=\"##ffffff99\">Enter Password...</span></i>";
        hide_input = false;
        fade_on_empty = false;
        position = "0, -175";
        halign = "center";
        valign = "center";
      };
    };
  };
}
