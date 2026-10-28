# samurai-desktop-documentation Specification

## Purpose

Define the documentation needed to install, understand, and safely operate the Wake Up Samurai Hyprland and Waybar integration while recording its cross-repository boundary and deferred desktop work.

## ADDED Requirements

### Requirement: Document prerequisites and setup in README

`README` MUST document the prerequisites for the integration, including the installed Waybar runtime, the native tray applets, and the blocking NixOS prerequisite boundary. It MUST identify that complete integration requires approved changes in `~/nixos-config` for `hardware.bluetooth.enable`, `services.blueman.enable`, and `pavucontrol`.

#### Scenario: A user reads the setup documentation

Given a user is preparing a compatible system
When the user reads `README`
Then the required Waybar and tray prerequisites are stated
And the required `~/nixos-config` options and package are named
And complete integration is marked as requiring approved sibling-repository changes.

### Requirement: Document safe Stow deployment in README

`README` MUST describe deployment through the repository's Stow installer patterns. It MUST state that an unmanaged `~/.config/hypr/hyprland.lua` is backed up with a timestamp before Stow replaces it with the complete repository-managed Hyprland entrypoint, and that repeated deployment does not back up an already-owned link as a user file.

#### Scenario: A user follows deployment instructions

Given a user wants to deploy the dotfiles
When the user follows the `README` deployment section
Then the backup-before-Stow order is documented
And the full Hyprland entrypoint replacement is documented
And repeat-deployment ownership and idempotence are documented.

### Requirement: Document Waybar ownership and output selection

`README` MUST document that exactly one Waybar bar is placed on one selected output. It MUST describe the precedence of the editable ordered preference array, largest external output by pixel area with output-name tie-break, and `eDP-1` fallback. It MUST state that only monitor add and monitor remove events trigger reselection, that unchanged selections do not restart Waybar, and that a changed selection restarts only the integration-owned Waybar process without a broad `pkill waybar`.

#### Scenario: A user needs to understand bar relocation

Given a user reads the Waybar behavior section of `README`
When the user checks how output selection works
Then the preference, external-output, tie-break, and `eDP-1` fallback order is stated
And the monitor-event triggers and owned-process restart boundary are stated.

### Requirement: Document applet startup and tray behavior

`README` MUST state that Hyprland startup launches `nm-applet` and `blueman-applet`, that Waybar displays them through its native tray, and that output relocation restarts Waybar without launching duplicate applets.

#### Scenario: A user reads tray lifecycle instructions

Given the desktop integration is installed
When the user reads the tray section of `README`
Then the Hyprland applet startup path is identified
And native Waybar tray ownership is identified
And the Waybar-only restart behavior is described without duplicate applet startup.

### Requirement: Track deferred desktop work in the roadmap

`docs/roadmap.md` MUST list wallpaper, Wofi theming, notifications, lock/idle behavior, Powerlevel10k, and GTK/Qt integration as deferred or future work. The roadmap MUST NOT imply that this change implements those items or authorize their implementation within this change.

#### Scenario: Deferred work is reviewed

Given a user opens `docs/roadmap.md`
When the user reviews the desktop roadmap
Then wallpaper, Wofi theming, notifications, lock/idle behavior, Powerlevel10k, and GTK/Qt integration are listed as deferred or future work
And none of those items is presented as implemented by the current integration.

### Requirement: Document the no-extra-dependency constraints

The documentation MUST preserve the confirmed implementation constraints that monitor selection does not require `jq` or `socat` and that palette synchronization does not require a custom generator.

#### Scenario: A user checks integration dependencies

Given a user reads the implementation notes in the desktop documentation
When the user checks monitor selection and palette maintenance constraints
Then the documentation states that `jq` and `socat` are not required for monitor selection
And it states that no custom palette generator is introduced.
