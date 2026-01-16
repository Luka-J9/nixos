{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = {
    services.open-webui = {
      package = pkgs.open-webui;
      enable = true;
      port = 8083;
    };
  };
}