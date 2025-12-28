{ config, pkgs, ... }:

{
  home.username = "luka";
  home.homeDirectory = "/home/luka";

  nixpkgs.config = {
    allowUnfree = true;
  };

  imports = [
    ../../modules/vscode/vscode.nix
    ../../modules/1password/1password.nix
    ../../modules/signal/signal.nix
    ../../modules/chromium/chromium.nix
    ../../modules/discord/discord.nix
    ../../modules/gnome/gnome-home.nix
  ];

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # gnome overrides for wallpaper and face (can be customized)
  home.gnome = {
    wallpaper = ../../modules/gnome/wallpapers/shorewallpaper-ultrawide.png;
    face = ../../modules/gnome/icons/profile.png;
  };
}
