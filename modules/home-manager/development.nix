{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = {

    home.packages = with pkgs; [

      cosmic-term
      bazel

      scala
      scalafmt
      scalafix
      scala-cli
      sbt
      mill
      graalvm-ce

      rustc
      rustup

      direnv
      devenv

      nixfmt-rfc-style

      gleam

      jq

    ];
    programs.vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
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
      userSettings = lib.literalExpression ''
        {
        "files.autoSave" = "off";
        }
      '';
    };
  };
}
