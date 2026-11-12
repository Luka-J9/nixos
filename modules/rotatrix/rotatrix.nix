{ ... }:
{
  # Rotatrix needs to read keyboard input devices to detect global hotkeys, and
  # write to /dev/uinput to suppress them.
  #
  # This enables the uinput kernel module and its static /dev/uinput node, owned
  # by group "uinput" (upstream nixpkgs rule), and tags keyboard event devices
  # with uaccess so the active seat session gets them via ACL — session-scoped,
  # so SSH/background sessions are not granted access. GROUP="input" is the
  # fallback for when uaccess doesn't fire.
  hardware.uinput.enable = true;

  services.udev.extraRules = ''
    KERNEL=="event*", SUBSYSTEM=="input", MODE="0660", GROUP="input", TAG+="uaccess"
  '';
}
