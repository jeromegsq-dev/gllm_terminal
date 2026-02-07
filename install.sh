#!/bin/bash
# RememberCommands installer - creates a symlink in Oh My Zsh custom plugins

set -e

# Validate HOME is set
if [[ -z "$HOME" ]]; then
  echo "Error: HOME environment variable is not set"
  exit 1
fi

PLUGIN_NAME="remembercommands"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Validate script directory
if [[ ! -d "$SCRIPT_DIR" ]]; then
  echo "Error: Could not determine script directory"
  exit 1
fi

ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
PLUGIN_DIR="$ZSH_CUSTOM_DIR/plugins/$PLUGIN_NAME"

# Check Oh My Zsh exists
if [[ ! -d "$ZSH_CUSTOM_DIR" ]]; then
  echo "Error: Oh My Zsh custom directory not found at $ZSH_CUSTOM_DIR"
  echo "Make sure Oh My Zsh is installed: https://ohmyz.sh"
  exit 1
fi

# Prevent overwrite
if [[ -e "$PLUGIN_DIR" ]]; then
  echo "Plugin directory already exists at $PLUGIN_DIR"
  echo "Remove it first if you want to reinstall: rm -rf $PLUGIN_DIR"
  exit 1
fi

# Create symlink
ln -s "$SCRIPT_DIR" "$PLUGIN_DIR"
echo "Installed! Symlinked $SCRIPT_DIR -> $PLUGIN_DIR"
echo ""
echo "Next steps:"
echo ""
echo "1. Add your Mistral API key to ~/.zshrc:"
echo "   export MISTRAL_API_KEY=\"your-key-here\""
echo "   https://console.mistral.ai/home?workspace_dialog=apiKeys"
echo ""
echo "2. Add 'remembercommands' to your plugins in ~/.zshrc:"
echo "   plugins=(remembercommands)"
echo "   concatenate if needed"
echo ""
echo "3. Reload your shell:"
echo "   source ~/.zshrc"
echo ""
echo "4. Try it out:"
echo "   remembercmd list all files sorted by size"
echo "   or the quicker version"
echo "   rr list all files sorted by size"
