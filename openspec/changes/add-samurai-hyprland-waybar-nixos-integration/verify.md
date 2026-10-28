## Verification record

### Pre-conditions

- [x] `review.md` has a final `PASSED` verdict after three review rounds and no blocking findings. It still records four open non-blocking findings; `review.md` was not changed.
- [ ] All planned tests pass — deterministic checks pass, but the planned live session and hardware checks remain blocked.
- [x] Deterministic shell, Hyprland configuration, Waybar smoke, scope, and prohibition checks are recorded below.

### Checks

#### Check: Waybar output selector and owned-process harness

- **Type:** unit
- **Command:** `bash tests/test-waybar-output-selector.sh`
- **Exit code:** 0
- **Outcome:** PASS
- **Evidence:** `19 passed, 0 failed`; covers preference ordering, area/tie/fallback selection, malformed records, ownership replacement, timeout cleanup, concurrent reconciliation, and monitor-only event filtering.

#### Check: Temporary-HOME installer contract

- **Type:** integration
- **Command:** `bash tests/test-install.sh`
- **Exit code:** 0
- **Outcome:** PASS
- **Evidence:** `installer temporary-HOME contract: PASS`; backup collision handling, repository-owned repeat deployment, Hyprland/Waybar links, and unrelated-file isolation passed. Historical pre-implementation red-test output for tasks 6.1-6.2 is unavailable.

#### Check: Waybar configuration static contract

- **Type:** validation
- **Command:** `bash tests/test-waybar-config.sh`
- **Exit code:** 0
- **Outcome:** PASS
- **Evidence:** `waybar config static contract: PASS`; required bar geometry, module groups, interactions, palette/font identifiers, and forbidden animation checks passed.

#### Check: Shell syntax for installer and test scripts

- **Type:** lint
- **Command:** `bash -n install.sh tests/*.sh`
- **Exit code:** 0
- **Outcome:** PASS
- **Evidence:** No syntax errors were reported by the runner evidence.

#### Check: Shell syntax for the Waybar launcher

- **Type:** lint
- **Command:** `sh -n hypr/.config/hypr/waybar-output.sh`
- **Exit code:** 0
- **Outcome:** PASS
- **Evidence:** No syntax errors were reported by the runner evidence.

#### Check: Shell syntax for the fake Waybar test helper

- **Type:** lint
- **Command:** `bash -n tests/fixtures/fake-waybar.sh`
- **Exit code:** 0
- **Outcome:** PASS
- **Evidence:** No syntax errors were reported in the implementation-session verification evidence.

#### Check: Hyprland Lua configuration parsing

- **Type:** configuration
- **Command:** `hyprland --verify-config --config hypr/.config/hypr/hyprland.lua`
- **Exit code:** 0
- **Outcome:** PASS
- **Evidence:** `Config parsing result: config ok`.

#### Check: Standalone Lua syntax checker

- **Type:** lint
- **Command:** `luac -p hypr/.config/hypr/hyprland.lua`
- **Exit code:** NOT RUN
- **Outcome:** NOT RUN
- **Evidence:** No standalone `lua`, `luajit`, or `luac` checker was available in the recorded environment. Native Hyprland configuration parsing passed instead.

#### Check: Waybar configuration/style runtime smoke

- **Type:** integration
- **Command:** `timeout 3s waybar -c waybar/.config/waybar/config.jsonc -s waybar/.config/waybar/style.css -l error`
- **Exit code:** 124
- **Outcome:** PASS
- **Evidence:** The expected timeout stopped the live Waybar process after startup. No configuration parse error was emitted; the bar configured on `eDP-1` at height 36. The bounded runner evidence also reported clean startup/stop only, not full interaction or visual verification.

#### Check: Approved NixOS configuration check

- **Type:** build
- **Command:** `cd /home/pedro/nixos-config && nix flake check`
- **Exit code:** 0
- **Outcome:** PASS
- **Evidence:** The implementation-session evidence reports that all Nix flake checks passed. No NixOS source was changed by this verification update.

#### Check: Strict OpenSpec validation

- **Type:** validation
- **Command:** `openspec validate add-samurai-hyprland-waybar-nixos-integration --strict`
- **Exit code:** 0
- **Outcome:** PASS
- **Evidence:** Validation was run after creating this artifact and completed successfully.

#### Check: Final Git status preservation

- **Type:** inspection
- **Command:** `git status --short`
- **Exit code:** 0
- **Outcome:** PASS
- **Evidence:** The runner recorded the existing repository state and preserved unrelated paths. The implementation paths are the planned `install.sh`, `README`, `docs/`, `hypr/`, `openspec/`, `tests/`, and `waybar/` paths; `.pi/gates/` contains session runner evidence.

#### Check: Final changed-path review

- **Type:** inspection
- **Command:** `git diff --name-only`
- **Exit code:** 0
- **Outcome:** PASS
- **Evidence:** The runner recorded no implementation edits outside the planned scope. Untracked planned files are represented by `git status --short`, not by this command.

#### Check: Whitespace and patch integrity

- **Type:** validation
- **Command:** `git diff --check`
- **Exit code:** 0
- **Outcome:** PASS
- **Evidence:** No whitespace errors were reported.

#### Check: Forbidden implementation mechanisms

- **Type:** inspection
- **Command:** `! grep -RInE '(^|[^[:alnum:]_])(jq|socat|pkill[[:space:]]+waybar|while[[:space:]]+.*(sleep|hyprctl)|palette[[:space:]]*generator)' install.sh hypr/.config/hypr waybar/.config/waybar`
- **Exit code:** 0
- **Outcome:** PASS
- **Evidence:** The negated search completed with exit code 0 because no forbidden `jq`, `socat`, polling-loop, palette-generator, or broad `pkill waybar` implementation match was found.

#### Check: Final live bar startup checklist

- **Type:** inspection
- **Command:** `hyprctl monitors -j; pgrep -af 'waybar|nm-applet|blueman-applet'`
- **Exit code:** NOT RUN
- **Outcome:** BLOCKED
- **Evidence:** The runner performed only bounded Waybar startup/stop. It did not perform a deployed-session count of exactly one bar, so the full 8.1 check remains blocked.

#### Check: Monitor hotplug relocation and owned-PID replacement

- **Type:** integration
- **Command:** `hyprctl monitors -j` before and after a physical monitor add/remove, followed by the owned-PID replacement checklist
- **Exit code:** NOT RUN
- **Outcome:** BLOCKED
- **Evidence:** No hotplug hardware action was performed. The deterministic ownership harness passed, but it is not live monitor relocation evidence.

#### Check: Applet duplicate prevention after relocation

- **Type:** integration
- **Command:** `pgrep -af 'nm-applet|blueman-applet'` after startup and repeated monitor relocation
- **Exit code:** NOT RUN
- **Outcome:** BLOCKED
- **Evidence:** No repeated live monitor relocation or applet lifecycle matrix was available to the runner.

#### Check: Fullscreen exclusion

- **Type:** integration
- **Command:** `manual Hyprland fullscreen checklist`
- **Exit code:** NOT RUN
- **Outcome:** BLOCKED
- **Evidence:** No visual fullscreen test was performed.

#### Check: Workspace, media, network, Bluetooth, audio, title, clock, and privacy interactions

- **Type:** integration
- **Command:** `manual Waybar interaction checklist in a deployed Hyprland session`
- **Exit code:** NOT RUN
- **Outcome:** BLOCKED
- **Evidence:** The bounded Waybar startup did not exercise clicks, scroll actions, media controls, device launchers, or informational-module behavior.

#### Check: Glyphs, colors, and Bluetooth state matrix

- **Type:** inspection
- **Command:** `manual Waybar glyph/color inspection with Bluetooth disabled, enabled-disconnected, and connected states`
- **Exit code:** NOT RUN
- **Outcome:** BLOCKED
- **Evidence:** No visual glyph/color inspection or Bluetooth hardware-state matrix was performed. The bounded Waybar run reported no Bluetooth controller.

#### Check: Native tray/device runtime prerequisites

- **Type:** integration
- **Command:** `manual native tray and device runtime checklist`
- **Exit code:** NOT RUN
- **Outcome:** BLOCKED
- **Evidence:** The configuration/build prerequisite check passed, but live applet, tray, Bluetooth, and audio-device behavior requires the unavailable controlled session and hardware state matrix.

#### Check: Review-loop gate

- **Type:** inspection
- **Command:** `run_fix_loop <task-or-plan>`
- **Exit code:** NOT RUN
- **Outcome:** PASS
- **Evidence:** Existing `review.md` records three completed review rounds with final `Verdict: PASSED` and zero blocking findings. No new review run was performed for this artifact-only update, and `review.md` was not modified.

#### Check: Runner gate

- **Type:** validation
- **Command:** `run_runner`
- **Exit code:** 0
- **Outcome:** BLOCKED
- **Evidence:** `.pi/gates/runner-1787551832247.json` records `verdict: BLOCKED` for the full final verification task because live checks remain unavailable. `.pi/gates/runner-1787551884102.json` records `verdict: PASSED` only for the separately bounded Waybar startup/stop check; it does not cover hotplug, fullscreen, interactions, glyphs/colors, or Bluetooth hardware states.

### Outcome

**BLOCKED**

Deterministic implementation and validation checks passed, including the selector/ownership harness, temporary-HOME installer contract, Waybar static contract, shell syntax, Hyprland configuration parsing, bounded Waybar config/style startup, NixOS flake check, strict OpenSpec validation, scope review, whitespace review, and prohibition search. The overall verdict is BLOCKED because the planned live hotplug, fullscreen, applet-duplication, interaction, glyph/color, and Bluetooth state checks were not run.
