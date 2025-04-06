{ config, lib, pkgs, ... }:
{

  programs.zed-editor = {
      enable = true;
      extensions = ["nix" "toml" "scala" "java"];

      userSettings = {
        buffer_font_size = 16;
      
        lsp = {
          rust-analyzer = {
              binary = {
                  path = lib.getExe pkgs.rust-analyzer;
                  path_lookup = true;
              };
          };
          nix = { 
              binary = { 
                  path_lookup = true; 
              }; 
          };
          metals = {
            settings = {
                inlayHints = {
                    inferredTypes = {
                        enable = true;
                    };
                };
            };
            binary = {
                path = lib.getExe pkgs.metals;
                path_lookup = true;

                arguments = [
                    "-Dmetals.http=on"
                ];
            };
            initialization_options = {
                isHttpEnabled = true;
            };
          };
      };
      terminal = {
        line_height = "comfortable";
        option_as_meta = false;
        button = false;
        shell = "system";

        toolbar = {
            title = true;
        };
        working_directory = "current_project_directory";
      };
      };

      

      # userSettings = {
      #   hour_format = "hour24";
      # };
    };

    home.file = {
        ".config/zed/tasks.json"= {
            source = ../../dotfiles/zed/tasks.json;
        };
        ".config/scripts/run-bloop-main.sh" = {
            source = ../../dotfiles/zed/run-bloop-main.sh;
            executable = true;
        };
        ".config/scripts/run-bloop-test.sh" = {
            source = ../../dotfiles/zed/run-bloop-test.sh;
            executable = true;
        };
    };
}
#   config = {
#     programs.zed-editor = {
#         enable = true;
#     };
#   };
# }
