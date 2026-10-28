# native-tray-network-bluetooth Specification

## Purpose

Define native tray applet startup, network and Bluetooth module behavior, audio controls, and the approved NixOS prerequisite boundary for the desktop integration.

## ADDED Requirements

### Requirement: Use the native Waybar tray

The right Waybar island MUST use Waybar's native tray module. The tray MUST expose the menus and controls provided by the session's `nm-applet` and `blueman-applet` instances.

#### Scenario: Applets are running in the session

Given `nm-applet` and `blueman-applet` are running
When the right island is rendered
Then both applets appear through the native Waybar tray
And their menus and controls can be opened from the tray.

### Requirement: Start network and Bluetooth applets with Hyprland

The Hyprland startup path MUST start `nm-applet` and `blueman-applet` as session applets. The applets MUST belong to the Hyprland session lifecycle rather than the Waybar process lifecycle.

#### Scenario: A Hyprland session starts

Given a Hyprland session is starting
When its startup path runs
Then `nm-applet` and `blueman-applet` are started for that session
And Waybar can display them through its native tray.

#### Scenario: Waybar moves to another output

Given the Hyprland session applets are already running
When the integration restarts Waybar for a selected-output change
Then the applets are not started a second time
And the existing applet processes remain owned by the Hyprland session.

### Requirement: Reflect Bluetooth adapter states

The Bluetooth module MUST be hidden when the Bluetooth adapter is disabled. It MUST use muted red styling when the adapter is enabled but disconnected, and it MUST use cyan styling when the adapter is connected.

#### Scenario: Bluetooth is disabled

Given the Bluetooth adapter is disabled
When the Bluetooth module state is rendered
Then the Bluetooth module is hidden.

#### Scenario: Bluetooth is enabled and disconnected

Given the Bluetooth adapter is enabled
And no Bluetooth device is connected
When the Bluetooth module state is rendered
Then the module is visible with muted red styling.

#### Scenario: Bluetooth is connected

Given the Bluetooth adapter is enabled
And a Bluetooth device is connected
When the Bluetooth module state is rendered
Then the module is visible with cyan styling.

### Requirement: Open the native network, Bluetooth, and audio controls

The network module MUST represent the preferred physical interfaces `wlp0s20f3` and `enp3s0` and MUST avoid Docker virtual interfaces. A left click on the network module MUST open the NetworkManager editor. A left click on the Bluetooth module MUST open Blueman. A left click on the audio module MUST open `pavucontrol`.

#### Scenario: Physical network interfaces are available

Given `wlp0s20f3`, `enp3s0`, and Docker virtual interfaces are present
When the network module selects interfaces to display
Then it uses the preferred physical interfaces
And it does not select Docker virtual interfaces.

#### Scenario: Control applications are opened

Given the pointer is over a network, Bluetooth, or audio module
When the user left-clicks the module
Then the NetworkManager editor opens for the network module
Or Blueman opens for the Bluetooth module
Or `pavucontrol` opens for the audio module.

### Requirement: Provide audio controls

The audio module MUST adjust volume on scroll and MUST toggle mute on middle click.

#### Scenario: Audio volume is changed

Given the pointer is over the audio module
When the user scrolls
Then the audio volume changes in the scroll direction.

#### Scenario: Audio mute is toggled

Given the pointer is over the audio module
When the user middle-clicks
Then the audio mute state changes.

### Requirement: Declare the NixOS prerequisite boundary

Complete native network, Bluetooth, and audio integration MUST be treated as requiring approved changes in the sibling `~/nixos-config` repository. Those changes MUST enable `hardware.bluetooth.enable`, enable `services.blueman.enable`, and install `pavucontrol`. This repository MUST NOT modify `~/nixos-config` without explicit approval or a linked cross-repository scope.

#### Scenario: The complete integration is evaluated

Given the repository configuration is being evaluated for complete native network, Bluetooth, and audio behavior
When the prerequisites are checked
Then the required `~/nixos-config` changes are identified as a blocking prerequisite
And the required options and package are `hardware.bluetooth.enable`, `services.blueman.enable`, and `pavucontrol`.

#### Scenario: No sibling-repository approval exists

Given no explicit approval or linked cross-repository scope exists
When this repository's change is applied
Then it does not modify `~/nixos-config`
And the complete integration remains flagged as blocked by that prerequisite.
