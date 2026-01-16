{pkgs, lib, ...}: {
  config = {
    wayland.windowManager.hyprland = {
      enable = true;

      plugins = [
        #inputs.hyprland-plugins.packages."${pkgs.system}".hyprpaper
      ];
    };
  };
}