{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = {
    wayland.windowManager.hyprland.enable = true;
    home.sessionVariables.NIXOS_OZONE_WL = "1";
    programs.kitty.enable = true;
  };
}
