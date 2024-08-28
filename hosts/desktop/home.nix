{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "lukaj";
  home.homeDirectory = "/home/lukaj";

  nixpkgs.config = {
    allowUnfree = true;
  };

  imports = [
  ../../modules/home-manager/development.nix
  ];

    home.file.".face" = {
    source = ../icons/profile.png;
    };


  # The following was determined by executing `dconf watch /` and manually encoding what was found
  dconf.settings = {
    "org/gnome/shell" = {
      favorite-apps = [
        "chromium-browser.desktop"
        "code.desktop"
        "vesktop.desktop"
        "steam.desktop"
        "signal-desktop.desktop"
        "1password.desktop"
        "kitty.desktop"
      ];
      enabled-extensions = [
        "dash-to-dock@micxgx.gmail.com"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
        "blur-my-shell@aunetx"
        "clipboard-history@alexsaveau.dev"
        "space-bar@luchrioh"
        "unblank@sun.wxg@gmail.com"
        "just-perfection-desktop@just-perfection"
        "pop-shell@system76.com"
        "windowIsReady_Remover@nunofarruca@gmail.com"
      ];
    };
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
    "org/gnome/mutter" = {
      edge-tiling = true;
    };
    "org/gnome/settings-deamon/plugins/power" = {
      power-button-action = "interactive";
    };
    "org/gnome/desktop/interface" = {
      clock-format = "12h";
      monospace-font-name = "JetBrainsMonoNL Nerd Font Propo Medium 10";
      font-name = "Noto Sans Bold 11 @wght=700";
      document-font-name = "Noto Sans 11";
    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      apply-custom-theme = true;
      custom-theme-shrink = true;
    };

    #Background
    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "${../wallpapers/shorewallpaper-ultrawide.png}";
      picture-uri-dark = "${../wallpapers/shorewallpaper-ultrawide.png}";
      primary-color = "#000000000000";
      secondary-color = "#000000000000";
    };

  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    cantarell-fonts
    hack-font
    inter
    jetbrains-mono
    liberation_ttf
    monaspace
    noto-fonts
    ubuntu_font_family
    (nerdfonts.override {
      fonts = [
        "FiraCode"
        "DroidSansMono"
        "JetBrainsMono"
      ];
    })
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/lukaj/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

}
