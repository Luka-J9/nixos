{
  config,
  lib,
  pkgs,
  ...
}:

{

  config = {
    home.packages = with pkgs; [
      _1password-gui
      _1password-cli
    ];

    home.file = {
      ".config/1Password/ssh/agent.toml" = {
        source = ./agent.toml;
      };
    };

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "*" = {
          forwardAgent = false;
          serverAliveInterval = 0;
          serverAliveCountMax = 3;
          compression = false;
          addKeysToAgent = "no";
          hashKnownHosts = false;
          userKnownHostsFile = "~/.ssh/known_hosts";
          controlMaster = "no";
          controlPath = "~/.ssh/master-%r@%n:%p";
          controlPersist = "no";
          identityAgent = "${config.home.homeDirectory}/.1password/agent.sock";
        };
      };
    };

    programs.git = {
      enable = true;
      settings = {
        init.defaultBranch = "main";
        branch.autoSetupRebase = "always";
        push.autoSetupRemote = true;
        gpg = {
          format = "ssh";
          ssh = {
            program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
          };
        };
        commit = {
          gpgsign = true;
        };

        user = {
          email = "development@lukaj9.com";
          name = "Luka-J9";
          signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID2WORLWmi4hPbsANjBpP1a9oTHxgG4CeKvwOGwKy+h0";
        };
      };
    };
  };

}
