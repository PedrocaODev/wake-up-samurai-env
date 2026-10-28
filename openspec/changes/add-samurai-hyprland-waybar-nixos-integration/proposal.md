## Why

Create portable Wake Up Samurai Hyprland and Waybar dotfiles that can be deployed safely across compatible systems while keeping the main Waybar placement stable as monitors change. The integration also documents the boundary between this repository and the sibling NixOS configuration.

## What Changes

- Add portable Hyprland and Waybar dotfiles for the Wake Up Samurai setup.
- Provide a three-island top Waybar on exactly one dynamically selected main output:
  - use the configured ordered output preference;
  - otherwise use the largest external output;
  - otherwise fall back to `eDP-1`;
  - relocate the bar when monitor events change the selected output.
- Preserve workspace, title, media, status, tray, and privacy behavior across the three islands.
- Use the native tray with `nm-applet` and Blueman.
- Deploy with safe timestamped backups and Stow.
- Update `README` and add `docs/roadmap.md`.
- Explicitly handle the NixOS Bluetooth, Blueman, and `pavucontrol` work that belongs in the sibling `~/nixos-config` repository, without expanding this repository's code scope.
- Defer wallpaper, Wofi theme, notifications, lock/idle, Powerlevel10k, and GTK/Qt integration.

## Capabilities

### New Capabilities

- `portable-hyprland-waybar-dotfiles`: Portable Wake Up Samurai Hyprland and Waybar configuration with the specified three-island layout and behavior.
- `dynamic-main-output-waybar`: Selects one main output by ordered preference, largest external fallback, or `eDP-1`, and relocates Waybar on monitor events.
- `native-tray-network-bluetooth`: Provides native tray integration for `nm-applet` and Blueman, with the related NixOS Bluetooth/Blueman/`pavucontrol` boundary documented.
- `safe-stow-deployment`: Creates timestamped backups before deploying dotfiles through Stow.
- `samurai-desktop-documentation`: Documents setup in `README` and tracks deferred and future work in `docs/roadmap.md`.

### Modified Capabilities

- None. `openspec/specs` contains no existing capabilities.

## Impact

- Adds the planned OpenSpec-scoped dotfile, deployment, and documentation work without touching unrelated existing changes.
- A portion of the required NixOS integration belongs to `~/nixos-config`, not this repository. Any cross-repository edits require explicit scope and approval; this proposal does not authorize changing that sibling repository.
- Hyprland and Waybar configuration, monitor-event handling, tray dependencies, Stow deployment, backups, and setup documentation are affected. Deferred desktop integrations remain out of scope.
