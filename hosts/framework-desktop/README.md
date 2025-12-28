
# Framework Desktop — Local setup notes

This file documents the manual setup steps performed interactively on the host. Run commands as needed and replace `luka` with your username when appropriate.

## Steps

1. Clone the repo (example):

```sh
git clone https://github.com/Luka-J9/nixos.git
cd nixos/
```

If you used `sudo` to clone into a directory owned by root, fix ownership:

```sh
sudo chown -R luka:users nixos/
```


2. Use `nix-shell` to grab tools (example includes `_1password-gui`):

```sh
nix-shell -p git sbctl _1password-gui
```


3. Regenerate `hardware-configuration.nix` (when hardware changes)

If you've changed hardware or need to refresh the detected configuration, generate a new hardware config on the target machine and copy it into the flake repo:

```sh
# On the target machine (generates /etc/nixos/hardware-configuration.nix)
sudo nixos-generate-config --root /

# Review the generated file at /etc/nixos/hardware-configuration.nix
# Then copy it into the repo (adjust path as needed):
sudo cp /etc/nixos/hardware-configuration.nix /home/nixos/hosts/framework-desktop/hardware-configuration.nix

# Commit the change from the repo working tree:
git add hosts/framework-desktop/hardware-configuration.nix
git commit -m "Regenerate hardware-configuration.nix"
```

4. Rebuild the system (example target `desktop`):

```sh
sudo nixos-rebuild switch --recreate-lock-file --flake .#desktop
```

5. Create Secure Boot keys with `sbctl`:

```sh
sudo sbctl create-keys
```

6. 1Password and agenix / SSH key handling

- Launch the 1Password GUI to access secrets as you normally do.
- If you use `agenix`/age-encrypted secrets, you might have downloaded or decrypted a private key into your home `.ssh` directory. Example steps used interactively:

```sh
# (example — adjust filenames)
mkdir -p /home/luka/.ssh
# move/download/decrypt the file into your home .ssh
mv agenix /home/luka/.ssh/agenix
chmod 700 /home/luka/.ssh

# copy a decrypted key into root if needed (only when intended):
sudo cp /home/luka/.ssh/agenix /root/.ssh/id_ed25519
sudo chown root:root /root/.ssh/id_ed25519
sudo chmod 600 /root/.ssh/id_ed25519
```

Note: copying keys to `/root` should only be done when you understand the consequences. Replace `agenix` with the actual filename of your private key.

## Notes & safety

- Replace `luka` with your username where appropriate.
- Prefer to avoid `sudo` when cloning as a regular user; fix permissions instead.
- Keep private keys secure and set correct permissions (`600`) and ownership (`root:root`) when placed under `/root/.ssh`.

If you want, I can commit this README update, run any of the commands here, or expand the steps with screenshots/age commands — tell me which next.

