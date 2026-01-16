{
  config,
  lib,
  pkgs,
  pkgs-stable,
  ...
}:

{
  config = {
    services.ollama = {
      enable = true;
      package = pkgs-stable.ollama-rocm;
    };
    
    services.open-webui = {
      package = pkgs-stable.open-webui;
      enable = true;
      port = 8083;
    };
    
  };
}