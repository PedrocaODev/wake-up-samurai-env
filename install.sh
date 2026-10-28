#!/usr/bin/env sh
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="$HOME"
HYPRLAND_TARGET="$TARGET_DIR/.config/hypr/hyprland.lua"
MANAGED_HYPRLAND="$DOTFILES_DIR/hypr/.config/hypr/hyprland.lua"

if [ -L "$HYPRLAND_TARGET" ] && [ "$(readlink -f "$HYPRLAND_TARGET")" = "$(readlink -f "$MANAGED_HYPRLAND")" ]; then
    : # Already owned by this repository; do not back it up again.
elif [ -e "$HYPRLAND_TARGET" ] || [ -L "$HYPRLAND_TARGET" ]; then
    backup_timestamp="${BACKUP_TIMESTAMP:-$(date +%Y%m%d%H%M%S)}"
    backup="$HYPRLAND_TARGET.backup.$backup_timestamp"
    suffix=1
    while [ -e "$backup" ] || [ -L "$backup" ]; do
        backup="$HYPRLAND_TARGET.backup.$backup_timestamp.$suffix"
        suffix=$((suffix + 1))
    done
    mv -- "$HYPRLAND_TARGET" "$backup"
fi

if command -v stow >/dev/null 2>&1; then
    echo "Stowing packages with GNU Stow..."
    stow -d "$DOTFILES_DIR" -t "$TARGET_DIR" alacritty herdr nvim pi hypr waybar foot pavucontrol
else
    echo "GNU Stow not found; symlinking manually..."
    mkdir -p "$TARGET_DIR/.config/alacritty/themes" \
             "$TARGET_DIR/.config/herdr" \
             "$TARGET_DIR/.config/nvim/colors" \
             "$TARGET_DIR/.config/nvim/lua/plugins" \
             "$TARGET_DIR/.pi/agent/themes" \
             "$TARGET_DIR/.config/hypr" \
             "$TARGET_DIR/.config/waybar" \
             "$TARGET_DIR/.config/foot"

    ln -sf "$DOTFILES_DIR/alacritty/.config/alacritty/alacritty.toml" "$TARGET_DIR/.config/alacritty/alacritty.toml"
    ln -sf "$DOTFILES_DIR/alacritty/.config/alacritty/themes/wake-up-samurai.toml" "$TARGET_DIR/.config/alacritty/themes/wake-up-samurai.toml"
    ln -sf "$DOTFILES_DIR/herdr/.config/herdr/config.toml" "$TARGET_DIR/.config/herdr/config.toml"
    ln -sf "$DOTFILES_DIR/nvim/.config/nvim/colors/wake-up-samurai.lua" "$TARGET_DIR/.config/nvim/colors/wake-up-samurai.lua"
    ln -sf "$DOTFILES_DIR/nvim/.config/nvim/lua/plugins/colorscheme.lua" "$TARGET_DIR/.config/nvim/lua/plugins/colorscheme.lua"
    ln -sf "$DOTFILES_DIR/pi/.pi/agent/settings.json" "$TARGET_DIR/.pi/agent/settings.json"
    ln -sf "$DOTFILES_DIR/pi/.pi/agent/themes/wake-up-samurai.json" "$TARGET_DIR/.pi/agent/themes/wake-up-samurai.json"
    ln -sf "$DOTFILES_DIR/hypr/.config/hypr/hyprland.lua" "$TARGET_DIR/.config/hypr/hyprland.lua"
    ln -sf "$DOTFILES_DIR/hypr/.config/hypr/waybar-output.sh" "$TARGET_DIR/.config/hypr/waybar-output.sh"
    ln -sf "$DOTFILES_DIR/waybar/.config/waybar/config.jsonc" "$TARGET_DIR/.config/waybar/config.jsonc"
    ln -sf "$DOTFILES_DIR/waybar/.config/waybar/style.css" "$TARGET_DIR/.config/waybar/style.css"
    ln -sf "$DOTFILES_DIR/foot/.config/foot/foot.ini" "$TARGET_DIR/.config/foot/foot.ini"
    ln -sf "$DOTFILES_DIR/pavucontrol/.config/pavucontrol.ini" "$TARGET_DIR/.config/pavucontrol.ini"
fi

echo "Wake Up Samurai dotfiles installed successfully."
