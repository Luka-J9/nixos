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
      loadModels = [
        "llama3.2:1b"
        "mistral:7b"
        "codellama:13b"
        "qwen3-coder:latest"
        "deepseek-r1:latest"
      ];
      environmentVariables = {
        HSA_OVERRIDE_GFX_VERSION = "11.5.0"; # Native for Radeon 8060S (Strix Halo)
        HSA_ENABLE_SDMA = "0";
      };
    };

    # nixpkgs marks posthog broken on mcp >= 2 (unstable carries 2.2.0) because
    # its test suite fails against that API. mcp is only a test input there --
    # posthog itself runs on backoff/distro/requests -- so dropping its checks
    # is enough, and it keeps open-webui on the current version rather than
    # downgrading the one that already migrated its database.
    services.open-webui = {
      package = pkgs.open-webui.override {
        python3Packages = pkgs.python3Packages.overrideScope (
          _: prev: {
            posthog = prev.posthog.overridePythonAttrs (old: {
              doCheck = false;
              meta = old.meta // {
                broken = false;
              };
            });
          }
        );
      };
      enable = true;
      port = 8084; # internal; clients use the socket-activated proxy on 8083
    };

    # Start open-webui on demand: a socket on 8083 spawns a proxy, which pulls
    # in open-webui and forwards to it. After 30 min without connections the
    # proxy exits and open-webui (StopWhenUnneeded) is stopped with it.
    systemd.sockets.open-webui-proxy = {
      wantedBy = [ "sockets.target" ];
      listenStreams = [ "127.0.0.1:8083" ];
    };

    systemd.services.open-webui-proxy = {
      requires = [ "open-webui.service" ];
      after = [ "open-webui.service" ];
      serviceConfig.ExecStart = "${config.systemd.package}/lib/systemd/systemd-socket-proxyd --exit-idle-time=30min 127.0.0.1:${toString config.services.open-webui.port}";
    };

    systemd.services.open-webui = {
      wantedBy = lib.mkForce [ ];
      unitConfig.StopWhenUnneeded = true;
      # Only report started once the HTTP server answers, so the proxy never
      # forwards into a refused connection during the slow Python startup.
      serviceConfig.ExecStartPost = "${pkgs.bash}/bin/bash -c 'until ${pkgs.curl}/bin/curl -sf http://127.0.0.1:${toString config.services.open-webui.port}/health >/dev/null; do sleep 0.5; done'";
      serviceConfig.TimeoutStartSec = 300;
    };
  };
}
