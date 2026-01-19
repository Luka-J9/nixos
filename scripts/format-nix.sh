#!/usr/bin/env bash

# Find all .nix files excluding the .history directory and format them with nixfmt
find . -name "*.nix" -type f -not -path "./.history/*" | while read -r file; do
    echo "Formatting $file"
    nixfmt "$file"
done

echo "All .nix files formatted successfully!"
