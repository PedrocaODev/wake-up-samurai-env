## Review record

### Verdict

- **Verdict:** PASSED
- **Rounds:** 3
- **Reviewed by:** oracle subagent

### Findings

#### Finding: F4

- **ID:** F4
- **Severity:** blocking
- **Location:** hypr/.config/hypr/waybar-output.sh:349-366
- **Summary:** The launcher now generates a selected-output Waybar 0.15 configuration and invokes Waybar with -c and -s; the real-binary smoke test covers this path.
- **Status:** fixed
- **Resolution:** 

#### Finding: F-NEW-1

- **ID:** F-NEW-1
- **Severity:** non-blocking
- **Location:** waybar/.config/waybar/config.jsonc:19-22
- **Summary:** MPRIS scroll-up maps to previous and scroll-down maps to next.
- **Status:** fixed
- **Resolution:** 

#### Finding: F-NEW-2

- **ID:** F-NEW-2
- **Severity:** non-blocking
- **Location:** waybar/.config/waybar/style.css:29-31
- **Summary:** Enabled-disconnected Bluetooth uses the muted color and connected Bluetooth uses cyan.
- **Status:** fixed
- **Resolution:** 

#### Finding: F-NEW-3

- **ID:** F-NEW-3
- **Severity:** non-blocking
- **Location:** tests/test-waybar-config.sh:13-17
- **Summary:** Required palette/font identifiers are checked independently, and animation/keyframes remain separately forbidden.
- **Status:** fixed
- **Resolution:** 

#### Finding: F-NEW-4

- **ID:** F-NEW-4
- **Severity:** blocking
- **Location:** waybar/.config/waybar/config.jsonc:9,29-33
- **Summary:** Memory is a direct modules-right entry while only disk is inside group/disk; the static test verifies both placements.
- **Status:** fixed
- **Resolution:** 

#### Finding: F-NEW-5

- **ID:** F-NEW-5
- **Severity:** non-blocking
- **Location:** hypr/.config/hypr/hyprland.lua:7-14,67-72
- **Summary:** Preferred connector names are restricted to shell-safe connector characters before being passed to the shell command.
- **Status:** fixed
- **Resolution:** 

#### Finding: F-NEW-6

- **ID:** F-NEW-6
- **Severity:** non-blocking
- **Location:** hypr/.config/hypr/hyprland.lua:75-77
- **Summary:** Applet duplicate checks are scoped to the current process session with pgrep -x -s instead of scanning all visible processes.
- **Status:** fixed
- **Resolution:** 

#### Finding: F-NEW-7

- **ID:** F-NEW-7
- **Severity:** blocking
- **Location:** openspec/changes/add-samurai-hyprland-waybar-nixos-integration/tasks.md:86-88
- **Summary:** Unavailable red-test history, live checks, run_fix_loop, and run_runner are explicitly recorded as blocked/unavailable, and the ledger does not claim those checks passed.
- **Status:** fixed
- **Resolution:** 

#### Finding: F-NEW-8

- **ID:** F-NEW-8
- **Severity:** non-blocking
- **Location:** hypr/.config/hypr/waybar-output.sh:349-357
- **Summary:** Setting the arbitrary WAYBAR_TEST_ACTION_LOG environment variable changes production startup from Waybar -c/-s invocation to a positional test-launcher invocation, so an inherited test variable can prevent the real bar from loading its configuration. Remove this production branch and make the fake launcher accept the normal CLI, or use an explicit test-only injection point.
- **Status:** open
- **Resolution:** 

#### Finding: F-NEW-9

- **ID:** F-NEW-9
- **Severity:** non-blocking
- **Location:** install.sh:12-19
- **Summary:** BACKUP_TIMESTAMP is inserted raw into the backup path; a value containing / can move the backup outside ~/.config/hypr. Validate it as digits-only or reject malformed overrides before constructing the path.
- **Status:** open
- **Resolution:** 

#### Finding: F-NEW-10

- **ID:** F-NEW-10
- **Severity:** non-blocking
- **Location:** waybar/.config/waybar/style.css:15
- **Summary:** Symbols Nerd Font Mono is the primary font for every label and generic monospace is only the fallback, which does not preserve the requested existing Alacritty monospace as the text font with Symbols Nerd Font Mono as fallback. Put the intended text family first and the symbol family second, or explicitly separate text and symbol styling.
- **Status:** open
- **Resolution:** 

#### Finding: F-NEW-11

- **ID:** F-NEW-11
- **Severity:** non-blocking
- **Location:** hypr/.config/hypr/waybar-output.sh:97-165
- **Summary:** The persistent per-user cache runtime locator is shared by concurrent sessions. A live owned Waybar from another Hyprland session can match the stored marker/output and suppress startup in the current session. Use XDG_RUNTIME_DIR as the session-scoped source, or namespace fallback state by Wayland/session identity.
- **Status:** open
- **Resolution:** 


### Iteration log

- Round 1: 4 findings (1 blocking open).
- Round 2: 8 findings (2 blocking open).
- Round 3: 12 findings (0 blocking open).
