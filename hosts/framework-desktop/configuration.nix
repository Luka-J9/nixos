# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  mainUser = "luka";
in
{
  imports = [
    inputs.home-manager.nixosModules.default
    ./hardware-configuration.nix
    ../../modules/1password/1password.nix
    ../../modules/steam/steam.nix
    ../../modules/ollama/ollama.nix
    ../../modules/pipewire/pipewire.nix
    ../../modules/netbird/netbird.nix
    ../../modules/hyprland/hyprland.nix
  ];

  users.users = {
    "${mainUser}" = {
      isNormalUser = true;
      description = "Luka";
      home = "/home/${mainUser}";
      hashedPasswordFile = config.age.secrets.hashed-profile-password.path;
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
    };
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  my.onepassword = {
    enable = true;
    username = mainUser; 
  };

  age = {
    secrets = {
      hashed-profile-password.file = ./secrets/hashed-profile-password.age;
    };
    identityPaths = [ "/root/.ssh/id_ed25519" ];
  };

  home-manager = {
    extraSpecialArgs = {
      inherit inputs;
    };
    users = {
      "${mainUser}" = import ./home.nix;
    };
  };

  # Unified Boot Configuration
  boot = {
    # Lanzaboote & UEFI setup
    loader = {
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };

    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
      autoGenerateKeys.enable = true;
      autoEnrollKeys = {
        enable = true;
        autoReboot = true;
      };
    };

    # Kernel choices
    kernelPackages = pkgs.linuxPackages_latest;

    # Silent boot and Plymouth theme
    plymouth = {
      enable = true;
      theme = "rings";
      themePackages = with pkgs; [
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "rings" ];
        })
      ];
    };

    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];
  };

  hardware.bluetooth.enable = true;
  networking.hostName = "framework-desktop"; # Define your hostname.
  networking.networkmanager.wifi.backend = "iwd"; # TPM support somehow breaks this
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.getty.autologinUser = "${mainUser}";

  programs.bash.loginShellInit = ''
    if [ "$(tty)" = "/dev/tty1" ]; then
      exec uwsm start hyprland-uwsm.desktop
    fi
  '';

  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.hyprlock.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;
  services.gnome.gcr-ssh-agent.enable = true; # Enable the new SSH agent
  services.gvfs.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    lon
    sbctl
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.trusted-users = [
    "root"
    "luka"
  ];

  system.stateVersion = "25.05";
}
