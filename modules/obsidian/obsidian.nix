{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = {
    programs.obsidian = {
      enable = true;

      vaults = {
        Personal = {
          enable = true;
        };
      };
    };
  };
}
