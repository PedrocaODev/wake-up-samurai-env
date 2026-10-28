## Implementation slices

### Slice 0 — Preflight and scope gate

**Tasks:**
- 1.1 Record the baseline `git status --porcelain=v1`, changed paths, and existing diffs; preserve `alacritty/.config/alacritty/alacritty.toml`, `herdr/.config/herdr/config.toml`, and every unrelated dirty or untracked path.
- 1.2 Confirm that the allowed scope is this change root, repository dotfile packages, `install.sh`, `README`, and `docs/roadmap.md`.
- 1.3 Check for explicit or linked approval to edit `~/nixos-config`; without it, record native Bluetooth, Blueman, and `pavucontrol` integration as blocked and leave that repository untouched.
- 1.4 Inventory the current Hyprland entrypoint and installer behavior before any edit so the managed Lua entrypoint preserves unrelated configuration.

**Tests first:**
- Capture the baseline with `git status --short`, `git diff --name-only`, and focused diffs for the known pre-existing modified files before implementation starts.
- Treat the scope and approval record as the preflight gate; no implementation may proceed until the baseline and cross-repository decision are recorded.

**TDD exception:**
- Preflight and scope inventory have no new runtime behavior to unit-test. Evidence is the recorded Git baseline, inspected entrypoint/installer inventory, and explicit approval or block decision.

### Slice 1 — Selector and owned-process red tests

**Tasks:**
- 2.1 Add the dependency-free `tests/test-waybar-output-selector.sh` harness with local monitor-output fixtures and shell assertions.
- 2.2-2.6 Add red assertions for preference ordering, largest external output by pixel area, deterministic lowest-name tie-breaking, `eDP-1` fallback, and safe rejection of incomplete monitor records.
- 2.7 Add the smallest ownership assertions for unchanged selection, changed selection, stopping and waiting for the tracked PID, starting the replacement on the new output, and preserving an unrelated Waybar PID.
- 2.8 Add event assertions proving only monitor-add and monitor-remove trigger reselection; workspace and window events must not restart Waybar.
- 2.9 Run the tests before implementing the selector or ownership logic and retain failure evidence.

**Tests first:**
- Write the fixtures and assertions before the Lua selector and process-management implementation exists.
- Run `bash tests/test-waybar-output-selector.sh` against the pre-implementation tree and require a meaningful failure, not a skipped or vacuous pass.

**TDD exception:**
- None for selector, event filtering, or process ownership. These are behavioral requirements and must have failing tests before implementation.

### Slice 2 — Hyprland Lua and event integration

**Tasks:**
- 3.1 Create `hypr/.config/hypr/hyprland.lua` as the complete repository-managed entrypoint, carrying over the inventoried configuration.
- 3.2 Apply only the required theme changes: 2px borders, 10px rounding, active `#e23d3d`, inactive `#5f3030`, and preserved gaps, blur, and shadow behavior.
- 3.3 Add the editable ordered connector preference and dependency-free monitor parsing, rejecting incomplete records without `jq`, `socat`, JSON parsing, or polling.
- 3.4 Wire startup selection and monitor-add/monitor-remove callbacks through the existing Lua event path; do not restart on workspace or window events.
- 3.5 Track only the Waybar PID launched by this integration, restart only after a selection change, wait for exit, and never use broad `pkill waybar` behavior.
- 3.6 Run the selector and ownership tests against the integration and compare the resulting entrypoint with the preflight inventory.

**Tests first:**
- Re-run the failing `bash tests/test-waybar-output-selector.sh` before the implementation edit to establish the red state.
- Implement the smallest Lua/shell integration needed to turn the selector, ownership, and event assertions green; then run the same test without substituting a live compositor for the deterministic harness.

**TDD exception:**
- Full Hyprland daemon/event execution is not available in a unit test. The exception is limited to Lua syntax/static inspection and the controlled shell harness; live callback behavior is deferred to the Slice 7 checklist. Core selection and ownership behavior remain test-first.

### Slice 3 — Waybar configuration and style

**Tasks:**
- 4.1-4.4 Add the repository-managed JSONC configuration for exactly one exclusive 36px top bar on the selected output, with the required left, center, and right islands and modules.
- 4.5 Configure Japanese numeral inactive workspaces, active `侍`, and static urgent styling without blinking or animation.
- 4.6 Add Wake Up Samurai CSS properties and consume them for normal, active, dim, urgent, and device states, using the existing Alacritty monospace and `Symbols Nerd Font Mono` fallback.
- 4.7 Set fixed padding, borders, minimum dimensions, and fullscreen-safe geometry so label changes do not move the islands or cover fullscreen content.
- 4.8 Run the installed Waybar/configuration and CSS static validation available in the environment and fix only new configuration errors.

**Tests first:**
- Before editing the configuration, establish a narrow static contract check for required bar ownership, module groups, output selection, fixed height, and forbidden animation/broad process behavior; it must fail while the managed configuration is absent.
- After implementation, run the static assertions and the installed Waybar config/style smoke check. If the installed CLI's exact validation flag is uncertain, confirm the supported invocation during apply rather than fabricating a command; use the smallest supported config-load or launch smoke check.

**TDD exception:**
- CSS rendering, glyph appearance, island geometry, fullscreen exclusion, and visual palette fidelity are not practical unit-test targets. The narrow exception is static property/selector assertions plus installed Waybar runtime evidence and the Slice 7 live inspection; no visual framework, palette generator, or parser dependency is added.

### Slice 4 — Safe installer with temporary-`HOME` red tests then implementation

**Tasks:**
- 6.1 Add `tests/test-install.sh` before changing `install.sh`, using a temporary `HOME` with an unmanaged `hyprland.lua`, a timestamp collision, a repository-owned link on repeat deployment, and unrelated files.
- 6.2 Run that test against the current installer to establish the pre-edit failure while keeping the real home directory and sibling repository untouched.
- 6.3 Back up an unmanaged `~/.config/hypr/hyprland.lua` under a unique timestamped name before Stow, recognize an existing repository-owned link, and leave unrelated targets unchanged.
- 6.4 Extend the existing Stow package list and manual-link fallback only for the new Hyprland and Waybar packages, using the installed Waybar runtime.
- 6.5 Re-run the temporary-`HOME` backup/idempotence test and verify the deployed Hyprland path is the complete repository-managed link.

**Tests first:**
- Create and run `bash tests/test-install.sh` before modifying `install.sh`; require it to fail for the missing backup/collision/idempotence behavior.
- Implement only the installer changes needed by the red test, then run the test again against the temporary home and inspect the created backup ordering and links.

**TDD exception:**
- None for backup ordering, collision handling, ownership detection, idempotence, or unrelated-file isolation. The temporary filesystem test is the required behavioral test and must run before implementation.

### Slice 5 — Gated native tray and NixOS integration

**Tasks:**
- 5.1 Require explicit or linked approval for `~/nixos-config` before applying this slice; otherwise record the block and make no sibling-repository edit.
- 5.2-5.3 After approval, add non-duplicating Hyprland-session startup for `nm-applet` and `blueman-applet` and the required native Waybar tray/device interactions.
- 5.4 After approval, make only the linked `~/nixos-config` changes for `hardware.bluetooth.enable`, `services.blueman.enable`, and `pavucontrol`.
- 5.5 Run the approved sibling configuration checks and verify only approved options/packages evaluate and build.
- 5.6 Validate Bluetooth disabled, enabled-disconnected, and connected presentation states as hidden, muted red, and cyan.

**Tests first:**
- Make the approval check the first test: an absent approval must produce a recorded blocked result and zero writes under `~/nixos-config`.
- If approval exists, add/run red static or controlled-session assertions for single applet ownership, network/Bluetooth/audio command mappings, and the three Bluetooth state mappings before implementation.
- Run the approved sibling checks only after the implementation is present: from `~/nixos-config`, use `nix flake check` or `nix build .#nixosConfigurations.ideapad.config.system.build.toplevel`.

**TDD exception:**
- Hardware state, applet lifecycle, and Nix evaluation/build require the approved host/session and cannot be unit-tested fully. The exception is limited to static command/state assertions, approved `nix` checks, and the live state matrix. Complete integration remains blocked until cross-repo approval is recorded.

### Slice 6 — Documentation and deferred-work boundaries

**Tasks:**
- 7.1-7.5 Document Waybar, applet, Stow, output-selection, ownership, no-`jq`/no-`socat`, and cross-repository prerequisites and boundaries in `README`.
- 7.6 Add `docs/roadmap.md` entries for wallpaper, Wofi theming, notifications, lock/idle behavior, Powerlevel10k, and GTK/Qt integration as deferred or future work only.

**Tests first:**
- Before writing docs, derive the documented command names, paths, prerequisites, precedence, and blocked states from the implemented files and passing tests; do not document unimplemented behavior.
- After writing, run `openspec validate add-samurai-hyprland-waybar-nixos-integration --strict` and perform narrow searches for every required prerequisite, boundary, deferred item, and prohibition.

**TDD exception:**
- Documentation has no runtime red/green test. The narrow exception is manual source-to-doc comparison plus strict OpenSpec validation and static presence/wording checks; live claims must be backed by Slice 8 evidence or marked blocked.

### Slice 7 — Live verification and final checks

**Tasks:**
- 8.1-8.7 Execute the live Hyprland checklist for one 36px exclusive bar, monitor relocation, owned-PID replacement, no duplicate applets, fullscreen behavior, interactions, glyphs/colors, and the approved-or-blocked native prerequisite state.
- 9.1-9.5 Run strict OpenSpec, applicable shell/Lua/Waybar/installer/Nix checks, final scope preservation review, and searches for `jq`, `socat`, polling, palette generators, and broad `pkill waybar` behavior.

**Tests first:**
- Re-run `bash tests/test-waybar-output-selector.sh` and `bash tests/test-install.sh` before live checks.
- Run `bash -n install.sh` and `bash -n` on each new or changed shell helper script; no helper path is assumed until apply identifies one. Run Lua syntax validation with the installed Lua checker when available.
- Run `openspec validate add-samurai-hyprland-waybar-nixos-integration --strict`, the installed Waybar config/style smoke check confirmed during apply, and `git diff --check`.
- Compare final `git status --short` and `git diff --name-only` with the preflight baseline, confirming unrelated dirty files and unapproved `~/nixos-config` files are unchanged.
- Perform the live checklist only in an available Hyprland session. If NixOS scope is not approved, record native tray/device checks as blocked rather than changing the sibling repository.

**TDD exception:**
- Live compositor, hardware, glyph, and fullscreen checks are manual runtime verification, not unit tests. The evidence is the command output plus a checklist recording each pass or explicit block; no claim is marked passed without its corresponding environment evidence.

## Review checkpoints

### Checkpoint 1 — After core runtime configuration

After Slices 2-3, run `run_fix_loop <task-or-plan>` over the Lua, selector/ownership tests, Waybar JSONC, and CSS changes. Require a clean `review.md` with a `PASSED` result before proceeding to the runner gate or treating core runtime configuration as complete. Review event trigger scope, tracked-PID ownership, unchanged-selection behavior, monitor parsing safety, exact bar/module requirements, and forbidden mechanisms.

### Checkpoint 2 — After installer and cross-repository integration

After Slice 4 and, only when approved, Slice 5, run `run_fix_loop <task-or-plan>` again over the installer tests, repository-local changes, and any approved sibling diff. Require a clean `review.md` with a `PASSED` result before the runner gate. Confirm temporary-`HOME` isolation, timestamp collision safety, repeat deployment, applet non-duplication, and strict cross-repository scope.

### Final gate ordering

Run `run_fix_loop <task-or-plan>` and confirm the resulting `review.md` is clean and `PASSED`; only then run `run_runner`. The runner must return `VERDICT: PASSED` before verification or archive can advance. A blocked cross-repository prerequisite is acceptable only when recorded as blocked; it is not permission to claim complete integration.

## Final verification intent

- Test scripts: `bash tests/test-waybar-output-selector.sh` and `bash tests/test-install.sh`.
- Shell syntax: `bash -n install.sh`, plus `bash -n <exact path>` for every new or changed shell helper identified during apply.
- OpenSpec: `openspec validate add-samurai-hyprland-waybar-nixos-integration --strict`.
- Lua: use the installed Lua syntax checker against `hypr/.config/hypr/hyprland.lua` when available; otherwise rely on the deterministic harness and static inspection, recording the limitation.
- Waybar: confirm the installed CLI's supported config/style validation or minimal config-load invocation during apply; run that exact command and do not invent an unsupported flag. Include a runtime smoke check for one configured bar where the environment permits.
- Approved NixOS scope only: from `~/nixos-config`, run `nix flake check` or `nix build .#nixosConfigurations.ideapad.config.system.build.toplevel`; do not run or edit sibling configuration without recorded approval.
- Scope preservation: run `git status --short`, `git diff --name-only`, and `git diff --check`; compare with the Slice 0 baseline and verify the known pre-existing dirty files, unrelated files, and any unapproved sibling repository remain untouched.
- Final static prohibition search: confirm no `jq`, `socat`, polling loop, palette generator, or broad `pkill waybar` was introduced.
- Live checklist: exactly one 36px exclusive bar on the selected output; output add/remove relocation only; old owned PID exits before replacement; unrelated Waybar survives; no duplicate applets; fullscreen exclusion; workspace/media/network/Bluetooth/audio interactions; informational title/clock/privacy behavior; Japanese numerals, `侍`, symbols, colors, and Bluetooth disabled/disconnected/connected states. Record unavailable Hyprland hardware/session checks as blocked, not passed.
- Gate evidence: `run_fix_loop` must leave a clean `review.md` with `PASSED`, followed by `run_runner` returning `VERDICT: PASSED`.

## Intended commit grouping

- Planning: commit the change-root planning artifact `openspec/changes/add-samurai-hyprland-waybar-nixos-integration/plan.md` separately from implementation and documentation.
- Repository-local implementation: group the selector/ownership tests, Hyprland Lua entrypoint, Waybar JSONC/CSS, installer changes, and their focused tests in the repository-local implementation commit or commits.
- Repository-local documentation: keep `README` and `docs/roadmap.md` in a separate documentation commit from runtime implementation.
- Optional sibling integration: if and only if cross-repository approval is recorded, make the narrowly scoped `~/nixos-config` Bluetooth/Blueman/`pavucontrol` change in its own commit in that different repository. Never combine it with a wake-up-samurai repository commit.
- Do not claim the final integration commit is complete while the approved sibling commit is absent or the cross-repository approval gate is unresolved.
