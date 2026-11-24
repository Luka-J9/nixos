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
    ../../modules/rotatrix/rotatrix.nix
    ../../modules/strata/strata.nix
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
        "input" # rotatrix: read keyboard event devices
        "uinput" # rotatrix: write synthetic input via /dev/uinput
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
    # Without this, a single unmanaged file in the way (' ... would be
    # clobbered') aborts the whole activation at boot, and the desktop quietly
    # keeps running the previous generation's user units instead.
    backupFileExtension = "hm-bak";

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
      # Skip the menu; hold Space during boot to get it back.
      timeout = 0;
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
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];
  };

  hardware.bluetooth.enable = true;

  # Firmware/BIOS updates via LVFS: `fwupdmgr refresh && fwupdmgr update`
  services.fwupd.enable = true;

  networking.hostName = "framework-desktop"; # Define your hostname.
  networking.networkmanager.wifi.backend = "iwd"; # TPM support somehow breaks this
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # iwd sometimes starts before udev finishes registering wlan0 (mt7925e), leaving
  # the radio powered but with no station device, so NetworkManager sees wifi stuck
  # as "unavailable" until iwd is restarted. Wait for the netdev before starting iwd.
  systemd.services.iwd = {
    after = [ "sys-subsystem-net-devices-wlan0.device" ];
    wants = [ "sys-subsystem-net-devices-wlan0.device" ];
  };

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
  # Keep tty1 blank: it sits behind Hyprland and is briefly revealed on
  # logout/shutdown before Plymouth's shutdown splash takes over.
  services.getty.extraArgs = [
    "--skip-login"
    "--noissue"
  ];
  # getty@ is Type=idle: it holds off exec'ing until every boot job is done or
  # 5s pass. NetworkManager-wait-online runs in the background for longer, so
  # autologin (and thus Hyprland) always lost the full 5s.
  # Set on the getty@ template so it merges into NixOS's own overrides.conf
  # (which carries the ExecStart). A getty@tty1 drop-in also named
  # overrides.conf masks that one and getty falls back to /usr/bin/agetty.
  systemd.services."getty@".serviceConfig.Type = "simple";

  # Let unpatched binaries (e.g. VS Code marketplace extensions) run without an FHS sandbox
  programs.nix-ld.enable = true;

  # uwsm is chatty on stdout; send it to the journal (journalctl -t uwsm-start)
  # instead of leaving it printed on tty1.
  programs.bash.loginShellInit = ''
    if [ "$(tty)" = "/dev/tty1" ]; then
      clear
      setterm --cursor off
      exec systemd-cat -t uwsm-start uwsm start hyprland-uwsm.desktop
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
