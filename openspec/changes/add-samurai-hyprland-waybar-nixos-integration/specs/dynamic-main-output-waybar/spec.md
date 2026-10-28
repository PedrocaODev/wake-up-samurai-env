# dynamic-main-output-waybar Specification

## Purpose

Define deterministic main-output selection and monitor-event relocation for the single Wake Up Samurai Waybar instance without affecting unrelated Waybar processes.

## ADDED Requirements

### Requirement: Maintain an editable output preference

The output selector MUST expose an editable ordered array of connector names. The selector MUST evaluate the array in order and MUST select the first connected output whose name appears in the array.

#### Scenario: A preferred output is connected

Given the preference array contains `DP-1` followed by `HDMI-A-1`
And both outputs are connected
When the selector runs
Then it selects `DP-1`.

#### Scenario: The first preference is unavailable

Given the preference array contains `DP-1` followed by `HDMI-A-1`
And `DP-1` is not connected
And `HDMI-A-1` is connected
When the selector runs
Then it selects `HDMI-A-1`.

### Requirement: Apply the fallback precedence

When no preferred output is connected, the selector MUST select the largest connected external output by pixel area. If multiple external outputs have equal pixel area, it MUST select the output with the deterministically lowest output name according to the configured name comparison. If no external output is available, it MUST select `eDP-1`.

#### Scenario: No preference matches and external outputs differ in area

Given no output in the preference array is connected
And connected external outputs have different pixel areas
When the selector runs
Then it selects the external output with the largest pixel area.

#### Scenario: External outputs have equal area

Given no output in the preference array is connected
And two connected external outputs have equal pixel area
When the selector runs
Then it selects one according to the deterministic output-name tie-break.

#### Scenario: No external output is available

Given no output in the preference array is connected
And no connected external output is available
When the selector runs
Then it selects `eDP-1`.

### Requirement: Select the output at startup and monitor changes

The integration MUST run output selection at startup and after monitor add and monitor remove events. It MUST relocate the single Waybar bar to the selected output after a selection change.

#### Scenario: The session starts with a connected monitor

Given Hyprland reports its connected outputs at session startup
When the integration starts
Then it selects one output using the configured precedence
And starts the owned Waybar instance on that output.

#### Scenario: A monitor is added

Given the current selected output is `eDP-1`
When Hyprland emits a monitor add event and the selected output becomes `HDMI-A-1`
Then the integration relocates the owned Waybar instance to `HDMI-A-1`.

#### Scenario: A monitor is removed

Given the current selected output is an external monitor
When Hyprland emits a monitor remove event and the selection changes
Then the integration relocates the owned Waybar instance to the newly selected output.

### Requirement: Restrict event triggers

The Lua event-callback path MUST listen only for monitor add and monitor remove events for output reselection. Workspace events and window events MUST NOT trigger a Waybar restart.

#### Scenario: A workspace changes

Given the selected output and monitor set are unchanged
When Hyprland emits a workspace event
Then the integration does not restart Waybar.

#### Scenario: A window changes

Given the selected output and monitor set are unchanged
When Hyprland emits a window event
Then the integration does not restart Waybar.

#### Scenario: An unrelated monitor event is absent

Given no monitor add or monitor remove event has occurred
When other Hyprland events are received
Then the output selector is not invoked for those events.

### Requirement: Use dependency-free shell output parsing

The selector MUST parse the normal Hyprland monitor command output through shell tools already available to the integration. It MUST NOT require `jq`, `socat`, polling, or a JSON parser dependency for monitor selection.

#### Scenario: Monitor selection is performed

Given Hyprland provides its normal human-readable monitor command output
When the selector determines the main output
Then it uses shell parsing of that output
And it does not invoke `jq`, `socat`, a polling loop, or a JSON parser dependency.

#### Scenario: Monitor output is incomplete

Given a monitor record is missing a field required to calculate its selection
When the selector processes the record
Then it does not select an arbitrary output from the incomplete record
And it does not restart Waybar based on that incomplete selection.

### Requirement: Restart only the owned Waybar instance when selection changes

The integration MUST compare the newly selected output with the current output. If the selection is unchanged, it MUST leave the owned Waybar process running. If the selection changes, it MUST stop only the Waybar process launched and tracked by this integration, wait for that process to exit, and start its replacement on the new output. It MUST NOT use a broad `pkill waybar` or otherwise terminate an unrelated Waybar process.

#### Scenario: A monitor event does not change selection

Given the current selected output is `eDP-1`
And a monitor add or remove event leaves `eDP-1` as the selected output
When the event callback completes
Then the owned Waybar process is not restarted.

#### Scenario: A monitor event changes selection

Given the current selected output is `eDP-1`
And a monitor event changes the selected output to `DP-1`
When the event callback handles the change
Then it stops the tracked Waybar process
And waits for that process to exit
And starts one replacement process on `DP-1`.

#### Scenario: Another Waybar process exists

Given a Waybar process not launched or tracked by this integration is running
When the selected output changes
Then that unrelated process remains running.
