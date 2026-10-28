# portable-hyprland-waybar-dotfiles Specification

## Purpose

Define the portable Wake Up Samurai Hyprland and Waybar behavior, layout, visual states, modules, and interactions without expanding the desktop integration beyond the confirmed scope.

## ADDED Requirements

### Requirement: Provide the Wake Up Samurai desktop configuration

The integration MUST provide repository-managed Hyprland and Waybar configuration for the Wake Up Samurai desktop setup. The installed Waybar binary MUST be used as the runtime dependency; the dotfiles MUST NOT require a second Waybar installation.

#### Scenario: A compatible system deploys the desktop configuration

Given the repository-managed dotfiles are available and a Waybar binary is installed
When the desktop configuration is deployed
Then Hyprland and Waybar use the repository-managed Wake Up Samurai configuration
And no alternate Waybar version is installed by this integration.

### Requirement: Render one exclusive three-island bar

Waybar MUST render exactly one bar at the top with a height of 36px. Its left, center, and right module groups MUST form the three visual islands. The bar MUST be exclusive so that it does not overlay fullscreen content, and it MUST be present only on the currently selected output.

#### Scenario: The selected output displays the bar

Given one output is selected for the integration
When Waybar starts
Then exactly one 36px bar is displayed at the top of that output
And the left, center, and right groups are displayed as three islands
And the bar reserves space instead of overlaying fullscreen content.

#### Scenario: Fullscreen content is shown

Given a fullscreen Hyprland window is displayed on the selected output
When the window enters fullscreen
Then the Waybar bar does not cover the fullscreen content.

### Requirement: Preserve visual geometry and typography

The Waybar styling MUST use CSS custom properties for the existing Wake Up Samurai palette and MUST consume those variables for normal, active, dim, urgent, and device states. The configuration MUST use the monospace font already selected for Alacritty and `Symbols Nerd Font Mono` for symbols. Japanese numeral labels and `侍` MUST render through that font stack or its available fallback without changing the desktop font choice. Fixed padding, border widths, and minimum dimensions MUST preserve island and workspace geometry when the active label changes.

#### Scenario: The active workspace label changes width

Given an inactive workspace is labeled with a Japanese numeral
When that workspace becomes active and its label changes to `侍`
Then the island and workspace geometry remain fixed
And the configured Alacritty monospace and symbol font stack remains in use.

#### Scenario: A Waybar state uses the Samurai palette

Given a normal, active, dim, urgent, or device module state is rendered
When Waybar applies its stylesheet
Then the state consumes a CSS custom property from the existing Wake Up Samurai palette
And no palette generator or synchronization tool is required.

### Requirement: Preserve Hyprland border and window decoration states

Hyprland MUST use a 2px border and 10px rounding for active and inactive window states. The active border color MUST be `#e23d3d`, the inactive border color MUST be `#5f3030`, and the existing gaps, blur, and shadow behavior MUST remain enabled.

#### Scenario: An active window is focused

Given a Hyprland window is focused
When its decoration is rendered
Then its border is 2px, rounded to 10px, and colored `#e23d3d`.

#### Scenario: An inactive window is unfocused

Given a Hyprland window is not focused
When its decoration is rendered
Then its border is 2px, rounded to 10px, and colored `#5f3030`
And the existing gaps, blur, and shadow behavior remains enabled.

### Requirement: Provide workspace and title modules

The left island MUST contain the Hyprland workspace buttons and the focused-window title. The workspace module MUST show all workspaces, activate a workspace on left click, and change workspace on scroll. The title MUST be informational and MUST NOT perform a destructive action.

#### Scenario: All workspaces are displayed

Given Hyprland has multiple workspaces
When the left island is rendered
Then every workspace is represented in the workspace module
And the focused-window title is displayed beside the workspace buttons.

#### Scenario: A user changes workspaces

Given the pointer is over the workspace module
When the user left-clicks a workspace or scrolls the module
Then the corresponding workspace is activated for a left click
And the workspace changes in the scroll direction for a scroll event.

#### Scenario: A title is displayed

Given a focused window has a title
When the title module is rendered
Then it reports the focused-window title
And clicking the title does not perform a destructive action.

### Requirement: Provide media and clock modules

The center island MUST contain media status and controls plus a compact `HH:MM` clock beside the media module. MPRIS artist/title text MUST be truncated to about 40 characters and MUST expose the full content in a tooltip. The focused-window title MUST be truncated to about 45 characters and MUST expose the full content in a tooltip. If no player is available, the media module MUST remain empty or hidden rather than creating replacement player UI. The clock MUST be informational.

#### Scenario: Media text exceeds the display length

Given an MPRIS player exposes artist/title content longer than about 40 characters
When the media module is rendered
Then the displayed artist/title text is truncated to about 40 characters
And the full artist/title content is available in the tooltip.

#### Scenario: Focused title exceeds the display length

Given the focused-window title is longer than about 45 characters
When the title module is rendered
Then the displayed title is truncated to about 45 characters
And the full title is available in the tooltip.

#### Scenario: Media controls are used

Given an available MPRIS player is displayed in the center island
When the user left-clicks the media module
Then playback toggles between play and pause
When the user scrolls the media module
Then the existing direction mapping moves to the previous or next media item.

#### Scenario: No player is available

Given no MPRIS player is available
When the center island is rendered
Then the media module is empty or hidden
And no replacement player interface is created.

### Requirement: Provide the status, tray, and privacy modules

The right island MUST contain the native tray, CPU, memory, disk, audio, backlight, preferred physical network interfaces `wlp0s20f3` and `enp3s0`, Bluetooth, privacy, and battery modules. CPU and memory MUST always be visible. Disk MUST be available in a hover drawer. CPU, memory, disk, and battery MUST provide detailed tooltips. Privacy MUST be informational. Network and Bluetooth left-click behavior MUST open the NetworkManager editor and Blueman respectively, and audio left-click behavior MUST open `pavucontrol`.

#### Scenario: The right island is rendered

Given the desktop session is running
When the right island is rendered
Then the listed tray, resource, device, privacy, and battery modules are available
And CPU and memory are visible without opening a drawer
And disk is available through a hover drawer.

#### Scenario: A status tooltip is inspected

Given the pointer is over CPU, memory, disk, or battery
When the tooltip is shown
Then the module provides detailed status information.

#### Scenario: Device actions are invoked

Given the pointer is over a network, Bluetooth, or audio module
When the user left-clicks the module
Then the NetworkManager editor opens for a network module
Or Blueman opens for the Bluetooth module
Or `pavucontrol` opens for the audio module.

### Requirement: Map audio interactions

The audio module MUST adjust volume on scroll and MUST toggle mute on middle click.

#### Scenario: Volume is adjusted

Given the pointer is over the audio module
When the user scrolls
Then the audio volume changes in the scroll direction.

#### Scenario: Audio is muted or unmuted

Given the pointer is over the audio module
When the user middle-clicks
Then the audio mute state toggles.

### Requirement: Render workspace urgency without animation

Inactive workspace labels MUST use Japanese numerals, the active workspace label MUST be `侍`, and urgent workspace styling MUST use a static urgent color with no blinking or animation.

#### Scenario: Workspace states are rendered

Given workspaces include inactive, active, and urgent states
When the workspace module is rendered
Then inactive labels use Japanese numerals
And the active label is `侍`
And urgent styling remains static without blinking or animation.
