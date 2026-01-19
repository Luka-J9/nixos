{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = {
    services.ollama = {
      enable = true;
      package = pkgs.ollama-vulkan;
      environmentVariables = {
        HSA_OVERRIDE_GFX_VERSION = "11.5.0"; # Native for Radeon 8060S (Strix Halo)
        HSA_ENABLE_SDMA = "0";
      };
    };

    services.open-webui = {
      package = pkgs.open-webui;
      enable = true;
      port = 8083;
    };
  };
}
