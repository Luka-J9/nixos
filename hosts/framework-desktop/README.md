
# Framework Desktop — Local setup notes

This file documents the manual setup steps performed interactively on the host. Run commands as needed and replace `luka` with your username when appropriate.

## Steps

0. Secure Boot
Hit F2 and disable Secure Boot under Administer Security (or something similarly named, has a shield).

Additionally hit the setting that clears the the default secure boot keys.

1. Use `nix-shell` to grab tools:

```sh
nix-shell -p git sbctl _1password-gui
```

2. Clone the repo:

```sh
cd /home
git clone https://github.com/Luka-J9/nixos.git
sudo chown -R luka:users nixos/
cd nixos/
```

3. Copy `hardware-configuration.nix`

If you've changed hardware or need to refresh the detected configuration, generate a new hardware config on the target machine and copy it into the flake repo:

```sh
sudo cp /etc/nixos/hardware-configuration.nix /home/nixos/hosts/framework-desktop/hardware-configuration.nix
```

4. 1Password and agenix / SSH key handling

- Launch the 1Password GUI to access secrets as you normally do.
- If you use `agenix`/age-encrypted secrets, you might have downloaded or decrypted a private key into your home `.ssh` directory.:

```sh
sudo cp /home/luka/.ssh/agenix /root/.ssh/id_ed25519
sudo chown root:root /root/.ssh/id_ed25519
sudo chmod 600 /root/.ssh/id_ed25519
```

5. Rebuild the system (example target `desktop`):

```sh
sudo nixos-rebuild switch --recreate-lock-file --flake .#desktop
```

6. Update Git

You may need to go into 1password and enable SSH agent for access

```sh
cd /home/nixos
git remote set-url origin git@github.com:Luka-J9/nixos.git
git commit -am "hardware configuration update"
```

