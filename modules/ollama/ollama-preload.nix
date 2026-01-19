{
  config,
  pkgs,
  lib,
  ...
}:

let
  defaultModels = [
    "llama3.2:1b"
    "qwen3-coder:latest"
    "deepseek-r1:latest"
  ];
in
{
  options.home.ollamaPreload = {
    models = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = defaultModels;
      description = "List of Ollama models to preload";
    };
  };

  config = lib.mkIf (config.home.ollamaPreload != null) (
    let
      modelsToPreload = config.home.ollamaPreload.models;
    in
    {
      systemd.user.services.ollama-preload = {
        Unit = {
          Description = "Preload Ollama models";
          After = [ "network.target" ];
        };
        Service = {
          Type = "oneshot";
          ExecStart = map (model: "${pkgs.ollama}/bin/ollama pull ${model}") modelsToPreload;
          Restart = "on-failure";
          RestartSec = 5;
          StandardOutput = "journal";
          StandardError = "journal";
        };
        Install.WantedBy = [ "default.target" ];
      };
      systemd.user.enable = true;
    }
  );
}
