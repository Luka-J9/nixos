{ pkgs, ... }:

{
  # Enable GNOME
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Remove decorations for QT applications
  environment.sessionVariables = {
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
  };

  # Excluding some GNOME applications from the default install
  environment.gnome.excludePackages =
    (with pkgs; [
      gedit
      gnome-connections
      gnome-console
      gnome-photos
      gnome-tour
      snapshot
      baobab
      cheese
      epiphany
      evince
      gnome-calendar
      geary
      gnome-calendar
      gnome-disk-utility
      gnome-font-viewer
      gnome-system-monitor
      simple-scan
      yelp
    ])
    ++ (with pkgs.gnome; [
      atomix
      gnome-characters
      gnome-clocks
      gnome-contacts
      gnome-logs
      gnome-maps
      gnome-music
      gnome-shell-extensions
      hitori # sudoku game
      iagno # go game
      tali # poker game
    ]);

  # List of Gnome specific packages
  environment.systemPackages = with pkgs; [
    gnome-tweaks
    pomodoro
    gnomeExtensions.auto-move-windows
    gnomeExtensions.blur-my-shell
    gnomeExtensions.clipboard-history
    gnomeExtensions.dash-to-dock
    gnomeExtensions.just-perfection
    gnomeExtensions.pop-shell
    gnomeExtensions.space-bar
    gnomeExtensions.unblank
    gnomeExtensions.user-themes
    gnomeExtensions.window-is-ready-remover
    gnomeExtensions.appindicator
  ];
}
