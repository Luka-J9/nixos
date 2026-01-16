{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages."${pkgs.system}".default;
  };
}
