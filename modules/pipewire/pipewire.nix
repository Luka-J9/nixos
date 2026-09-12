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
  };
}
