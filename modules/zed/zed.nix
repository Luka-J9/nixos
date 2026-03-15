{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = {
    home.packages = with pkgs; [
      zed-editor
      nil
    ];
    programs.zed-editor = {
      enable = true;
      extensions = [
        "nix"
        "toml"
        "rust"
        "scala"
        "catppuccin"
      ];
      userTasks = [
        {
          label = "Run main with sbt";
          command = "sbt";
          args = [ "run" ];
          reveal = "no_focus";
          tags = [ "scala-main" ];
        }
      ];
      userSettings = {
        vim_mode = false;
        lsp = {
          metals = {
            settings = {
              inlayHints = {
                inferredTypes = {
                  enable = true;
                };
                namedParameters = {
                  enable = true;
                };
                implicitArguments = {
                  enable = false;
                };
                implicitConversions = {
                  enable = false;
                };
                typeParameters = {
                  enable = true;
                };
                hintsInPatternMatch = {
                  enable = true;
                };
              };
              superMethodLensesEnabled = true;
            };
            binary = {
              arguments = [
                "-Dmetals.http=on"
              ];
              path = lib.getExe pkgs.metals;
            };
            initialization_options = {
              isHttpEnabled = true;
            };
          };
        };
        inlay_hints = {
          enabled = true;
          show_type_hints = true;
          show_parameter_hints = true;
          show_other_hints = true;
          show_background = false;
          edit_debounce_ms = 700;
          scroll_debounce_ms = 50;
        };
      };
    };
  };
}