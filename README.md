# Wake Up Samurai dotfiles

Portable Hyprland and Waybar configuration for the Wake Up Samurai desktop.

## Prerequisites

- Hyprland with the Lua configuration entrypoint support used by this repository.
- Waybar 0.15 installed on the system. This repository supplies configuration and CSS; it does not install another Waybar version.
- Native tray applets: `nm-applet` and `blueman-applet`.
- For complete Bluetooth and audio integration, approved changes are required in the sibling `~/nixos-config` repository:
  - `hardware.bluetooth.enable`;
  - `services.blueman.enable`;
  - the `pavucontrol` package.

This repository does not modify `~/nixos-config` without explicit approval. Until those changes are approved and applied, native Bluetooth, Blueman, and `pavucontrol` integration is a prerequisite boundary, not a completed claim.

## Setup

From this repository, run:

```sh
./install.sh
```

The installer uses GNU Stow when it is available and otherwise creates the same managed links manually. Before Stow runs, an unmanaged `~/.config/hypr/hyprland.lua` is moved to a unique timestamped backup. Stow then replaces it with the complete repository-managed Hyprland entrypoint. A link already owned by this repository is recognized as managed and is not backed up again as a user file. Unrelated files are not part of the deployment.

After deployment, start or reload the Hyprland session. The installed Waybar runtime loads `~/.config/waybar/config.jsonc` and `style.css`.

## Waybar output ownership

The integration runs exactly one exclusive 36px top bar on one selected output. The ordered `PREFERRED_OUTPUTS` array in `hypr/.config/hypr/hyprland.lua` is editable. Selection precedence is:

1. The first connected output in `PREFERRED_OUTPUTS`.
2. The largest connected external output by pixel area. Equal areas use the lowest output name.
3. `eDP-1` when no external output is available.

Selection runs at Hyprland startup and after `monitor.added` or `monitor.removed`. Workspace and window events do not trigger reselection. An unchanged selection leaves the owned Waybar process running. A changed selection terminates and waits for only the Waybar process launched by this integration, then starts the replacement on the selected output. It does not use a broad `pkill waybar`.

The process state and lock live in a private per-user runtime directory under `XDG_RUNTIME_DIR`, with a securely created `mktemp` fallback when that directory is unavailable. State writes are atomic. Monitor selection uses shell parsing and requires neither `jq` nor `socat`. Palette synchronization uses no custom generator.

## Modules and applets

- Left island: all Hyprland workspaces and the focused-window title.
- Center island: MPRIS status and controls plus an informational `HH:MM` clock.
- Right island: native tray, CPU, memory, disk drawer, audio, backlight, network, Bluetooth, privacy, and battery.
- Inactive workspaces use Japanese numerals. The active workspace uses `侍`. Urgent styling is static.

Hyprland startup launches `nm-applet` and `blueman-applet` only when they are not already running. Waybar displays them through its native tray. Moving the bar to another output restarts Waybar only; it does not launch duplicate applets.

Network, Bluetooth, and audio actions use `nm-connection-editor`, `blueman-manager`, and `pavucontrol`. Their availability depends on the installed system packages and the NixOS prerequisite boundary above.
