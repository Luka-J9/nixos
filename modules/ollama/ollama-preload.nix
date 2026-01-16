{ config, pkgs, lib, ... }:

let
  # default list of models
  defaultModels = [
    "llama3.2:1b"
    "qwen3-coder:latest"
    "deepseek-r1:latest"
  ];
in
{
  options.home-manager.users.ollamaPreload = {
    models = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = defaultModels;
      description = "List of Ollama models to preload";
    };
  };

  config = lib.mkIf (config.home-manager.users.ollamaPreload != null) (let
      modelsToPreload = config.home-manager.users.ollamaPreload.models;
      pullCommands = pkgs.lib.concatStringsSep "\n" (map (model: "${pkgs.ollama}/bin/ollama pull ${model}") modelsToPreload);
    in
    {
      systemd.user.services.ollama-preload = {
        Unit = {
          Description = "Preload Ollama models";
          After = [ "network.target" ];
        };
        Service = {
          Type = "oneshot";
          ExecStart = ''
            ${pullCommands}
          '';
          Restart = "on-failure";
          RestartSec = 5;
        };
        Install.WantedBy = [ "default.target" ];
      };
      systemd.user.enable = true;
    }
  );
}
