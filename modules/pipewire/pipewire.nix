{ config, pkgs, ... }:

{
  # Disable pure PulseAudio to avoid conflicts
  services.pulseaudio.enable = false;
  
  # Real-time priority for audio processing
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # Noise canceling (rnnoise) config has been removed from here

    # Prefer the Sennheiser Profile (mic + headphone out) whenever it's plugged
    # in. Stock priorities rank the generic USB dongle's mic above it (2109 vs
    # 2100) and tie the sinks, so the fallback default was a coin flip. Matching
    # on the model rather than serial/port keeps this working across ports.
    # An explicit choice in pavucontrol still wins over priority.
    wireplumber.extraConfig."51-prefer-sennheiser" = {
      "monitor.alsa.rules" = [
        {
          matches = [ { "node.name" = "~alsa_(input|output)\\.usb-Sennheiser_Sennheiser_Profile.*"; } ];
          actions.update-props."priority.session" = 3000;
        }
      ];
    };
  };
}
