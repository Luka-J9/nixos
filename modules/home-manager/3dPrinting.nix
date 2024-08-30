{ config, pkgs, ... }:
{
  config = {
    home.packages = with pkgs; [ prusa-slicer ];
  };
}
