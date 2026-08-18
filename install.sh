#!/usr/bin/env sh
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="$HOME"

if command -v stow >/dev/null 2>&1; then
    echo "Stowing packages with GNU Stow..."
    stow -d "$DOTFILES_DIR" -t "$TARGET_DIR" alacritty herdr nvim pi
else
    echo "GNU Stow not found; symlinking manually..."
    mkdir -p "$TARGET_DIR/.config/alacritty/themes" \
             "$TARGET_DIR/.config/herdr" \
             "$TARGET_DIR/.config/nvim/colors" \
             "$TARGET_DIR/.config/nvim/lua/plugins" \
             "$TARGET_DIR/.pi/agent/themes"

    ln -sf "$DOTFILES_DIR/alacritty/.config/alacritty/alacritty.toml" "$TARGET_DIR/.config/alacritty/alacritty.toml"
    ln -sf "$DOTFILES_DIR/alacritty/.config/alacritty/themes/wake-up-samurai.toml" "$TARGET_DIR/.config/alacritty/themes/wake-up-samurai.toml"
    ln -sf "$DOTFILES_DIR/herdr/.config/herdr/config.toml" "$TARGET_DIR/.config/herdr/config.toml"
    ln -sf "$DOTFILES_DIR/nvim/.config/nvim/colors/wake-up-samurai.lua" "$TARGET_DIR/.config/nvim/colors/wake-up-samurai.lua"
    ln -sf "$DOTFILES_DIR/nvim/.config/nvim/lua/plugins/colorscheme.lua" "$TARGET_DIR/.config/nvim/lua/plugins/colorscheme.lua"
    ln -sf "$DOTFILES_DIR/pi/.pi/agent/settings.json" "$TARGET_DIR/.pi/agent/settings.json"
    ln -sf "$DOTFILES_DIR/pi/.pi/agent/themes/wake-up-samurai.json" "$TARGET_DIR/.pi/agent/themes/wake-up-samurai.json"
fi

echo "Wake Up Samurai dotfiles installed successfully."
