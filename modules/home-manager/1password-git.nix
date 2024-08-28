{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config._1password-git;
  isKeySet = lib.hasAttr "key" cfg.signing && cfg.signing.key != "";
in
{

  options = {
    _1password-git = {
      enable = lib.mkEnableOption "enable git with 1password settings";

      agent-conf = lib.mkOption {
        type = lib.types.path;
        description = "the path to the `agent.toml` configuration see `https://developer.1password.com/docs/ssh/agent/config/`";
      };

      email = lib.mkOption {
        type = lib.types.str;
        description = "The email used for git configuration. See `https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup`";
      };

      name = lib.mkOption {
        type = lib.types.str;
        description = "The name used for git configuration. See `https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup`";
      };

      signing.key = lib.mkOption {
        type = lib.types.str;
        description = "The public key of what was used to sign the commit";
      };

    };
  };

  config = {

    home.packages = with pkgs; [
      _1password-gui
      _1password
    ];

    home.file = {
      ".config/1Password/ssh/agent.toml" = {
        source = cfg.agent-conf;
      };
    };

    programs.ssh = {
      enable = true;
      extraConfig = ''
        Host *
            IdentityAgent ${config.home.homeDirectory}/.1password/agent.sock
      '';
    };

    programs.git = {
      enable = true;
      extraConfig = {
        init.defaultBranch = "main";
        safe.directory = "/etc/nixos";
        branch.autoSetupRebase = "always";
        push.autoSetupRemote = true;
        gpg = {
          format = "ssh";
        };
        "gpg \"ssh\"" = {
          program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
        };
        commit = {
          gpgsign = true;
        };

        user = {
          email = cfg.email;
          name = cfg.email;
          signingKey = if isKeySet then cfg.signing.key else null;
        };
      };
    };
  };

}
