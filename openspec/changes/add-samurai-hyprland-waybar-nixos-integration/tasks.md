## 1. Apply preflight and scope gate

- [x] 1.1 Record the current Git status and the change scope before applying any task; preserve the existing modified `alacritty/.config/alacritty/alacritty.toml`, `herdr/.config/herdr/config.toml`, and all unrelated dirty or untracked files.
- [x] 1.2 Confirm that implementation is limited to this change root, the repository dotfile packages, the installer, `README`, and `docs/roadmap.md` unless an explicit cross-repository scope is approved.
- [x] 1.3 Resolve and record whether explicit approval or a linked scope exists for `~/nixos-config`; without it, leave that repository untouched and mark complete native Bluetooth, Blueman, and `pavucontrol` integration as blocked.
- [x] 1.4 Inventory the current Hyprland entrypoint and installer behavior before editing so the managed Lua file preserves current configuration except for the specified theme, autostart, and monitor-event wiring.

## 2. Build the smallest selector and ownership tests first

- [x] 2.1 Add a runnable shell test with local monitor-output fixtures and shell assertions before implementing the selector; keep it dependency-free and do not add `jq`, `socat`, a JSON parser, a polling loop, or a generator.
- [x] 2.2 Add a fixture/assertion for the first connected output in the editable ordered preference array.
- [x] 2.3 Add a fixture/assertion for the largest connected external output by pixel area when no preference matches.
- [x] 2.4 Add a fixture/assertion for deterministic lowest-name selection when external outputs have equal pixel area.
- [x] 2.5 Add a fixture/assertion for the `eDP-1` fallback when no connected external output exists.
- [x] 2.6 Add a fixture/assertion proving incomplete monitor output is ignored safely and cannot select an arbitrary output or trigger a restart.
- [x] 2.7 Add the smallest runnable ownership test for unchanged selection, changed selection, stopping and waiting for the tracked PID, starting the replacement with the new output, and leaving an unrelated Waybar PID running.
- [x] 2.8 Add assertions that only monitor-add and monitor-remove events invoke reselection, while workspace and window events do not.
- [ ] 2.9 Run the new selector and ownership tests before the implementation changes and retain the failure evidence needed to show that the tests exercise the missing behavior.

## 3. Package the complete Hyprland Lua entrypoint

- [x] 3.1 Create `hypr/.config/hypr/hyprland.lua` as the complete repository-managed entrypoint, carrying over the current configuration and changing no unrelated Hyprland behavior.
- [x] 3.2 Apply only the Wake Up Samurai theme changes required by the specification, including 2px borders, 10px rounding, active `#e23d3d`, inactive `#5f3030`, and preservation of existing gaps, blur, and shadow behavior.
- [x] 3.3 Add the editable ordered connector preference and dependency-free shell monitor parsing with safe rejection of incomplete records; do not use `jq`, `socat`, polling, or JSON parsing.
- [x] 3.4 Wire startup selection and monitor-add/monitor-remove callbacks through the existing Lua event path, with no workspace or window restart triggers.
- [x] 3.5 Track only the Waybar PID launched by this integration; restart it only after a selection change, wait for its exit before replacement, and do not use broad `pkill waybar` or another broad process termination.
- [x] 3.6 Run the selector and ownership tests against the Lua integration and compare the managed entrypoint with the preflight inventory to verify that only theme, autostart, and event wiring changed.

## 4. Add Waybar JSONC, modules, and CSS

- [x] 4.1 Add the repository-managed Waybar JSONC configuration for exactly one exclusive 36px top bar on the selected output, with left, center, and right module groups as three islands.
- [x] 4.2 Configure the left island with all Hyprland workspaces and the focused-window title; map workspace left-click and scroll behavior, keep the title informational, and preserve fixed workspace/island geometry.
- [x] 4.3 Configure the center island with MPRIS status and controls plus an informational `HH:MM` clock; use the required truncation and tooltip behavior, existing media direction mapping, and empty/hidden no-player behavior.
- [x] 4.4 Configure the right island with native tray, always-visible CPU and memory, hover-drawer disk, audio, backlight, preferred physical network interfaces `wlp0s20f3` and `enp3s0`, Bluetooth, privacy, and battery modules with the specified tooltips and interactions.
- [x] 4.5 Configure workspace labels so inactive workspaces use Japanese numerals, the active workspace uses `侍`, and urgent styling is static with no blinking or animation.
- [x] 4.6 Add Waybar CSS custom properties for the existing Wake Up Samurai palette and consume them for normal, active, dim, urgent, and device states; use the existing Alacritty monospace with `Symbols Nerd Font Mono` and available glyph fallback without a palette generator.
- [x] 4.7 Set the required fixed padding, borders, minimum dimensions, and fullscreen-safe geometry so changing workspace labels does not move the islands and the bar does not overlay fullscreen content.
- [x] 4.8 Run the installed Waybar/configuration and CSS static validation available in the project environment, without adding a parser or generator dependency, and fix only errors in the new configuration.

## 5. Apply gated native tray and NixOS prerequisites

- [x] 5.1 Do not apply this group until explicit approval or linked cross-repository scope for `~/nixos-config` is present; explicit user approval was provided and sibling edits remain limited to 5.4.
- [x] 5.2 After approval, add Hyprland-session startup for `nm-applet` and `blueman-applet`, keeping applet lifecycle outside Waybar restarts and preventing duplicate applet launches during output relocation.
- [x] 5.3 After approval, complete the native Waybar tray and device interactions: NetworkManager editor for network left-click, Blueman for Bluetooth left-click, `pavucontrol` for audio left-click, audio scroll volume changes, and audio middle-click mute toggle.
- [x] 5.4 After approval, make only the linked `~/nixos-config` changes for `hardware.bluetooth.enable`, `services.blueman.enable`, and installing `pavucontrol`; do not add unrelated NixOS configuration.
- [x] 5.5 Run the approved sibling configuration's `nix eval` and `nix build` checks and verify that the requested options and package evaluate/build without changing unapproved files.
- [ ] 5.6 Validate Bluetooth presentation for disabled, enabled-disconnected, and connected adapter states: hidden, muted red, and cyan respectively.

## 6. Test safe Stow deployment before editing the installer

- [ ] 6.1 Add a temporary-`HOME` installer test before modifying `install.sh`; use an unmanaged `hyprland.lua`, a timestamp collision, a repository-owned link on repeat deployment, and an unrelated file to assert backup ordering, non-collision, idempotence, and isolation.
- [ ] 6.2 Run the temporary-`HOME` test against the current installer to establish the pre-edit behavior and keep the test independent of the real home directory and sibling repository.
- [x] 6.3 Update `install.sh` to back up an unmanaged `~/.config/hypr/hyprland.lua` with a unique timestamped name before Stow runs, while recognizing an existing repository-owned link and leaving unrelated targets unchanged.
- [x] 6.4 Extend the existing Stow package list and manual-link fallback only for the new Hyprland and Waybar packages, using the installed Waybar runtime rather than installing another Waybar version.
- [x] 6.5 Re-run the temporary-`HOME` backup and idempotence test after the installer edit and verify that the deployed Hyprland path is the complete repository-managed link.

## 7. Document setup, boundaries, and deferred work

- [x] 7.1 Add `README` prerequisites for the installed Waybar runtime, native tray applets, and the blocking `~/nixos-config` requirements `hardware.bluetooth.enable`, `services.blueman.enable`, and `pavucontrol`.
- [x] 7.2 Document the Stow deployment order, timestamped backup of an unmanaged Hyprland entrypoint, complete managed replacement, repeat-deployment ownership detection, and protection of unrelated files.
- [x] 7.3 Document the single-bar ownership and output-selection precedence, including editable preferences, largest external output by pixel area, deterministic name tie-break, `eDP-1` fallback, monitor-only triggers, unchanged-selection behavior, tracked-PID restart, and prohibition on broad `pkill waybar`.
- [x] 7.4 Document Hyprland applet startup, native Waybar tray behavior, and the fact that output relocation does not launch duplicate applets.
- [x] 7.5 Document that monitor selection requires neither `jq` nor `socat` and that palette synchronization uses no custom generator.
- [x] 7.6 Add `docs/roadmap.md` listing wallpaper, Wofi theming, notifications, lock/idle behavior, Powerlevel10k, and GTK/Qt integration as deferred or future work, without presenting any of them as implemented or authorized here.

## 8. Verify the live Hyprland session

- [ ] 8.1 Start the deployed configuration in a live Hyprland session and verify exactly one 36px exclusive bar appears on the selected output.
- [ ] 8.2 Add and remove a monitor and verify hotplug relocation selects the required output, restarts only the owned Waybar process, waits for the old PID, and leaves no duplicate bar.
- [ ] 8.3 Verify the session has no duplicate `nm-applet` or `blueman-applet` instances after startup and repeated Waybar output relocation.
- [ ] 8.4 Enter fullscreen and verify Waybar does not cover fullscreen content.
- [ ] 8.5 Exercise workspace clicks and scroll, media controls, network/Bluetooth/audio clicks, audio scroll and mute, and informational title/clock/privacy behavior.
- [ ] 8.6 Inspect live glyphs and colors for Japanese numeral labels, `侍`, symbols, active/inactive/urgent states, and Bluetooth disabled/disconnected/connected states.
- [ ] 8.7 If the approved NixOS scope is unavailable, record the native tray/device runtime checks as blocked by the documented prerequisite rather than modifying `~/nixos-config`.

## 9. Run final strict checks and scope review

- [x] 9.1 Run the strict OpenSpec validation for this change and resolve every task/spec mismatch without adding unrequested behavior.
- [x] 9.2 Run the repository's applicable shell, Lua, Waybar, installer, and approved NixOS checks, including the selector, ownership, and temporary-`HOME` tests; deterministic checks passed in runner evidence, while live checks remain blocked.
- [x] 9.3 Verify the final diff contains only the planned change files plus no edits to unrelated dirty files or unapproved `~/nixos-config` files.
- [x] 9.4 Perform a final search/check proving the implementation introduced no `jq`, `socat`, palette generator, polling loop, or broad `pkill waybar` behavior.
- [ ] 9.5 Record blocked cross-repository prerequisites and live-session limitations, if any, and leave the change ready for the verification owner.

### Verification disposition

- Historical red-test evidence for 2.9 and 6.1-6.2 is unavailable in the current cumulative tree; the implemented selector/ownership and temporary-`HOME` checks pass.
- Live multi-monitor, fullscreen, tray-duplication, glyph, and Bluetooth-state checks remain blocked because they require a controlled deployed hardware/session matrix.
- The final runner evidence records `VERDICT: BLOCKED` because live hotplug, fullscreen, interaction, glyph/color, and Bluetooth hardware-state checks were not available; the bounded Waybar startup/stop runner separately records `VERDICT: PASSED`.
