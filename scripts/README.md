# Nix Formatting Scripts

This directory contains scripts for formatting Nix files in the project.

## format-nix.sh

This script formats all `.nix` files in the project while excluding files in the `.history` directory.

### Usage

```bash
./scripts/format-nix.sh
```

### Features

- Automatically finds all `.nix` files in the project
- Excludes files in the `.history` directory
- Uses `nixfmt` to format each file
- Provides feedback on which files are being formatted

### Requirements

- `nixfmt` command must be available in the system
- Bash shell

### Implementation Details

The script uses `find` command with the following pattern:
```bash
find . -name "*.nix" -type f -not -path "./.history/*"
```

This ensures all Nix files are found while excluding those in the `.history` directory.
