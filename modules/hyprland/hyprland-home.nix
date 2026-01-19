{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
{
  imports = [
    inputs.stylix.homeManagerModules.stylix
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

    iconTheme = {
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
        "waybar"
        "hyprpaper"
        "1password --silent"
        "discord --start-minimized"
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
      ];

      dwindle = {
        pseudotile = true;
        force_split = 2;
        preserve_split = true;
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
      shape = [
        {
          monitor = "";
          size = "300, 60";
          color = "rgba(255, 255, 255, .1)";
          rounding = -1;
          border_size = 0;
          border_color = "rgba(253, 198, 135, 0)";
          rotate = 0;
          xray = false;
          position = "0, -130";
          halign = "center";
          valign = "center";
        }
      ];

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
          outline_thickness = 2;
          font_size = 16;
          font_family = "SF Pro Display Bold";
          position = "0, -130";
          halign = "center";
          valign = "center";
        }
        # CURRENT SONG
        # {
        #   monitor = "";
        #   text = "cmd[update:1000] echo \"$(~/.config/hypr/Scripts/songdetail.sh)\"";
        #   color = "rgba(255, 255, 255, 0.6)";
        #   font_size = 18;
        #   font_family = "JetBrains Mono Nerd, SF Pro Display Bold";
        #   position = "0, 50";
        #   halign = "center";
        #   valign = "bottom";
        # }
      ];

      # INPUT FIELD
      "input-field" = {
        monitor = "";
        size = "300, 50";
        outline_thickness = 2;
        dots_size = 0.2;
        dots_spacing = 0.2;
        dots_center = true;
        # outer_color = "rgba(0, 0, 0, 0)";
        # inner_color = "rgba(255, 255, 255, 0.1)";
        # font_color = "rgb(200, 200, 200)";s
        fade_on_empty = false;
        font_size = 12;
        font_family = "SF Pro Display Bold";
        placeholder_text = "<i><span foreground=\"##ffffff99\">Input Password</span></i>";
        rounding = 0;
        hide_input = false;
        position = "0, -210";
        halign = "center";
        valign = "center";
      };
    };
  };
}
