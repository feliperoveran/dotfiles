#!/usr/bin/env bash
set -euo pipefail

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if ! command -v python3 >/dev/null 2>&1; then
  brew install python3
fi

echo "Bootstrap complete. Run: python3 scripts/install.py"
