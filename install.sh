#!/bin/bash
# Install worktrack
# curl -fsSL https://raw.githubusercontent.com/gallop-systems/worktrack/main/install.sh | bash

set -e

REPO="gallop-systems/worktrack"
INSTALL_DIR="$HOME/.local/bin"
CLONE_DIR="$HOME/Projects/worktrack"

echo "Installing worktrack..."

# Check dependencies
if ! command -v fswatch &>/dev/null; then
  echo "Installing fswatch..."
  if command -v brew &>/dev/null; then
    brew install fswatch
  else
    echo "Error: fswatch is required. Install it with your package manager."
    exit 1
  fi
fi

# Download the script
mkdir -p "$INSTALL_DIR"
curl -fsSL "https://raw.githubusercontent.com/$REPO/main/worktrack" -o "$INSTALL_DIR/worktrack"
chmod +x "$INSTALL_DIR/worktrack"

# Clone repo for `worktrack update` support
if [[ ! -d "$CLONE_DIR/.git" ]]; then
  echo "Cloning repo for update support..."
  mkdir -p "$(dirname "$CLONE_DIR")"
  git clone "git@github.com:$REPO.git" "$CLONE_DIR" 2>/dev/null || \
    git clone "https://github.com/$REPO.git" "$CLONE_DIR"
fi

# Detect shell config
SHELL_RC=""
if [[ -f "$HOME/.zshrc" ]]; then
  SHELL_RC="$HOME/.zshrc"
elif [[ -f "$HOME/.bashrc" ]]; then
  SHELL_RC="$HOME/.bashrc"
fi

# Ensure ~/.local/bin is in PATH
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
  if [[ -n "$SHELL_RC" ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
    echo "Added ~/.local/bin to PATH in $SHELL_RC"
  else
    echo "Warning: Add ~/.local/bin to your PATH manually"
  fi
fi

# Install shell hook
if [[ -n "$SHELL_RC" ]]; then
  if ! grep -q "worktrack_hook" "$SHELL_RC"; then
    cat >> "$SHELL_RC" << 'HOOK'

# worktrack shell hook - auto-start tracking on cd
worktrack_hook() {
  worktrack hook 2>/dev/null
}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd worktrack_hook
add-zsh-hook precmd worktrack_hook
HOOK
    echo "Installed shell hook in $SHELL_RC"
  else
    echo "Shell hook already installed"
  fi
fi

# Create data directory
mkdir -p "$HOME/.worktrack"

echo ""
echo "worktrack installed! Run 'source $SHELL_RC' then:"
echo "  cd /your/repo && worktrack register"
