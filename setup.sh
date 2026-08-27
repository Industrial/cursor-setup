#!/usr/bin/env bash
# Setup script for projects consuming ai-coding-harness as a submodule
#
# Usage:
#   1. Add submodule: git submodule add https://github.com/Industrial/cursor-setup .cursor
#   2. Run this script: .cursor/setup.sh
#
# This creates necessary symlinks and updates devenv.yaml

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

echo "Setting up AI coding harness..."

# Create .claude symlink if it doesn't exist
if [[ ! -e .claude ]] && [[ -d .cursor/.claude ]]; then
    ln -s .cursor/.claude .claude
    echo "✓ Created .claude symlink"
elif [[ -L .claude ]]; then
    echo "• .claude symlink already exists"
else
    echo "⚠ .claude exists but is not a symlink; skipping"
fi

# Check devenv.yaml imports
if [[ -f devenv.yaml ]]; then
    if grep -q '.cursor/nix' devenv.yaml 2>/dev/null; then
        echo "• devenv.yaml already imports .cursor/nix"
    else
        echo "⚠ Add to devenv.yaml imports:"
        echo "    imports:"
        echo "      - .cursor/nix"
    fi
else
    echo "⚠ No devenv.yaml found; create one with:"
    echo "    imports:"
    echo "      - .cursor/nix"
fi

# Ensure .devenv/profile exists (run devenv shell once)
if [[ ! -d .devenv/profile ]]; then
    echo "⚠ Run 'devenv shell' once to create .devenv/profile"
fi

echo "Done."
