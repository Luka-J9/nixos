{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = {

    home.packages = with pkgs; [
      git
      nixd
      scala
      scalafmt
      scalafix
      scala-cli
      sbt
      mill
      graalvmPackages.graalvm-ce
      metals
      bloop

      direnv
      devenv

      nixfmt

      gleam

      jq
    ];
    programs.vscode = {
      enable = true;
      profiles.default.extensions = with pkgs.vscode-extensions; [
        bazelbuild.vscode-bazel
        vadimcn.vscode-lldb
        fill-labs.dependi
        mkhl.direnv
        bierner.docs-view
        usernamehw.errorlens
        tamasfe.even-better-toml
        oderwat.indent-rainbow
        xyz.local-history
        pkief.material-icon-theme
        jnoortheen.nix-ide
        rust-lang.rust-analyzer
        scalameta.metals
        scala-lang.scala
        baccata.scaladex-search
        gleam.gleam
      ];
      profiles.default.userSettings = {
        "files.autoSave" = "off";
        "files.watcherExclude" = {
          "**/.bloop" = true;
          "**/.metals" = true;
          "**/.ammonite" = true;
        };
        "github.copilot.nextEditSuggestions.enabled" = true;
      };
    };
  };
}
