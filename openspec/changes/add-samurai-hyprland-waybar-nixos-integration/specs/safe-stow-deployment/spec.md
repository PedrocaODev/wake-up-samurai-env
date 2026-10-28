# safe-stow-deployment Specification

## Purpose

Define safe, repeatable Stow deployment for the repository-managed Hyprland entrypoint, including timestamped backups, full replacement, ownership detection, and protection of unrelated files.

## ADDED Requirements

### Requirement: Back up an unmanaged Hyprland entrypoint before Stow

Before Stow deploys the Hyprland package, the deployment MUST create a timestamped backup of an existing unmanaged `~/.config/hypr/hyprland.lua`. The backup name MUST avoid collisions with another backup created by the deployment. Stow MUST run only after the backup is available.

#### Scenario: An unmanaged Hyprland file exists

Given `~/.config/hypr/hyprland.lua` is an existing user-managed file
When the deployment starts
Then it creates a timestamped backup before running Stow
And the original file remains recoverable from that backup.

#### Scenario: Backup timestamps would collide

Given a backup with the generated timestamp name already exists
When the deployment creates a new backup
Then it uses a non-colliding timestamped backup name
And it does not overwrite the existing backup.

### Requirement: Replace the Hyprland entrypoint with the complete managed configuration

The deployment MUST treat `hypr/.config/hypr/hyprland.lua` as the complete repository-managed Hyprland entrypoint. After Stow succeeds, `~/.config/hypr/hyprland.lua` MUST point to that complete managed file rather than receiving a partial configuration overlay.

#### Scenario: The unmanaged entrypoint is deployed

Given an unmanaged `~/.config/hypr/hyprland.lua` exists
When the backup is complete and Stow succeeds
Then `~/.config/hypr/hyprland.lua` is the repository-managed Stow link
And the active Hyprland entrypoint is the complete repository-managed configuration.

### Requirement: Make repeated deployment idempotent

On a repeat deployment, repository-owned links MUST be recognized as already managed. The deployment MUST NOT back up those links as if they were user files, and the repeated deployment MUST leave the managed target in the same repository-owned state.

#### Scenario: The integration is deployed twice

Given the first deployment created the repository-owned Hyprland link
When the deployment runs again without a user replacement at that path
Then it does not create another backup of the repository-owned link
And the Hyprland path remains the repository-owned Stow link.

### Requirement: Leave unrelated files outside the deployment set

The deployment MUST change only the configured dotfile targets. Existing modified files outside those targets MUST remain unchanged.

#### Scenario: Unrelated user changes exist

Given a modified configuration file exists outside the Hyprland and Waybar deployment targets
When Stow deploys the integration
Then that unrelated file remains unchanged.

### Requirement: Keep the deployment boundary in this repository

The deployment MUST use the repository's existing Stow installer patterns and MUST NOT silently edit the sibling `~/nixos-config` repository. The installed Waybar runtime remains an external prerequisite; deployment MUST link its configuration without installing another Waybar version.

#### Scenario: Stow deployment is run without cross-repository approval

Given the deployment is run from this repository
And no explicit approval exists to edit `~/nixos-config`
When the Stow deployment completes
Then it changes only this repository's configured dotfile targets
And it does not edit `~/nixos-config`.
