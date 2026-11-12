{ ... }:
{
  # Deliberately nixpkgs' Hyprland rather than the upstream flake. The flake
  # builds against its own nixpkgs, so its hypr* stack carried glibc 2.42 while
  # this system's mesa needed GLIBC_2.43 -- every GL client in the session then
  # failed to load a driver ("MESA-LOADER: failed to open dri ... version
  # GLIBC_2.43 not found"), which cost a wallpaper and an OpenGL context.
  # One nixpkgs means one glibc, and the release in nixpkgs is current anyway.
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };
}
