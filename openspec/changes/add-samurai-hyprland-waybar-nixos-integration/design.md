## Context

Wake Up Samurai already has a duplicated palette that must remain visually consistent across its desktop configuration. The current Hyprland Lua configuration is unmanaged at `~/.config/hypr`. Waybar 0.15 is installed, but there is no existing Waybar configuration. The repository already has Stow installer patterns that the deployment should follow. The current runtime has one monitor, `eDP-1`.

The change is limited to this repository's portable Hyprland and Waybar dotfiles, deployment, and documentation. Existing unrelated modified files must not be touched. The sibling `~/nixos-config` repository owns the system-level Bluetooth and audio package enablement.

## Goals / Non-Goals

**Goals:**

- Add portable Wake Up Samurai Hyprland and Waybar configuration that can be deployed with the repository's existing Stow installer patterns.
- Keep the existing duplicated Wake Up Samurai palette consistent. Use CSS variables for Waybar styling, without adding a palette generator or synchronization tool.
- Provide one 36px top bar made of three islands, using the existing Alacritty monospace font with `Symbols Nerd Font Mono` as the symbol font.
- Show all workspaces in the single bar while keeping the bar out of fullscreen content.
- Preserve workspace, title, media, status, tray, and privacy behavior through explicit module and interaction mappings.
- Render inactive workspaces with Japanese numerals and replace the active workspace label with `侍`. Keep urgent styling static.
- Use a deterministic dynamic output selection: the first connected output in an editable preference array, then the largest external output by pixel area with output name as the tie-break, then `eDP-1`.
- React to monitor add and remove events only. Use the existing Lua event-callback path and shell parsing, with no `jq` or `socat` dependency.
- Restart only the Waybar instance owned by this integration when the selected output changes.
- Use the native Waybar tray and autostart `nm-applet` and `blueman-applet` so their controls appear in the tray.
- Hide Bluetooth when the adapter is disabled, show it in muted red when enabled and disconnected, and show it in cyan when connected.
- Create a safe timestamped backup before Stow deployment and make repeated deployment safe and idempotent.
- Document setup, the cross-repository prerequisite, and deferred work in `README` and `docs/roadmap.md`.

**Non-Goals:**

- Do not modify `~/nixos-config` under the current action scope.
- Do not modify unrelated Hyprland behavior beyond the requested theme and autostart integration.
- Do not add a CSS or palette generator, `jq`, `socat`, or another new dependency for monitor selection.
- Do not add per-monitor Waybar instances or additional bars.
- Do not implement wallpaper, Wofi theming, notifications, lock/idle behavior, Powerlevel10k, or GTK/Qt integration.

## Decisions

### Decision: Configuration and deployment boundary

Treat the existing `~/.config/hypr/hyprland.lua` as unmanaged input before deployment. The package includes the complete `hypr/.config/hypr/hyprland.lua` and makes it the repository-managed Hyprland entrypoint. Deployment first creates a timestamped backup of the existing unmanaged `~/.config/hypr/hyprland.lua`, then runs Stow to replace it with the repository-managed symlink. Preserve existing Hyprland behavior except for the requested theme and autostart integration. The installed Waybar binary is the runtime dependency; this repository supplies its configuration and style but does not install another Waybar version.

Deployment follows the repository's existing Stow installer patterns. It backs up the unmanaged target before Stow, then runs Stow. On repeat runs, repository-owned links are recognized as already managed and are not backed up again as if they were user files. Existing unrelated modified files remain outside the deployment set.

### Decision: Palette and typography

Use CSS custom properties in the Waybar stylesheet for the existing Wake Up Samurai palette and consume those variables for normal, active, dim, urgent, and device states. The palette remains duplicated at configuration-language boundaries where necessary; no generator is introduced to synchronize Hyprland and CSS.

Use the monospace font already selected for Alacritty and `Symbols Nerd Font Mono` for symbols. The Japanese numeral glyphs and `侍` must be covered by the selected font stack or its available fallback without changing the desktop font choice.

### Decision: Bar geometry and islands

Run exactly one Waybar bar at the top with a 36px height. Its left, center, and right module groups form the three visual islands. Fixed padding, border widths, and minimum dimensions preserve island and workspace geometry when the active label changes from a Japanese numeral to `侍`.

The bar is exclusive and configured so it does not overlay fullscreen content. The one bar is placed only on the currently selected output; it is not duplicated on other outputs.

### Decision: Modules and interaction mappings

The left island contains the Hyprland workspace buttons and focused-window title. The workspace module shows all workspaces, activates a workspace on left click, and changes workspace on scroll. The title is informational and has no destructive action.

The center island contains media status and controls plus a compact `HH:MM` clock beside the media module. Left click toggles play/pause; scroll moves between the previous and next media item using the module's existing direction mapping. MPRIS artist/title text is truncated to about 40 characters, and the focused title is truncated to about 45 characters; each has a full-content tooltip. If no player is available, the module remains empty or hidden rather than creating a replacement player UI. The clock remains informational.

The right island contains the native tray, CPU and memory (always visible), disk (in a hover drawer), audio, backlight, preferred physical network interfaces (`wlp0s20f3` and `enp3s0`, avoiding Docker virtual interfaces), Bluetooth, privacy, and battery. CPU, memory, disk, and battery provide detailed tooltips. Privacy is informational. Network left click opens the NetworkManager editor, Bluetooth left click opens Blueman, and audio left click opens `pavucontrol`; audio scroll adjusts volume and middle click toggles mute. The tray exposes the applet menus through Waybar's native tray module.

### Decision: Workspace and device states

Inactive workspace labels use Japanese numerals. The active workspace label is `侍`, and urgent workspaces use a static urgent color with no blinking or animation. The active Hyprland border is `#e23d3d`; the inactive Hyprland border is `#5f3030`. Both states preserve 2px borders, 10px rounding, existing gaps, blur, and shadow.

Bluetooth is hidden when its adapter is disabled, muted red when the adapter is enabled but disconnected, and cyan when connected. No additional color system is introduced.

### Decision: Dynamic main-output selection

Keep the output preference as an editable ordered array of connector names. On startup and after a monitor add or remove event, select exactly one output using this precedence:

1. Select the first connected output named in the preference array.
2. If none is connected, select the largest external output by pixel area. Break equal-area ties deterministically by output name.
3. If no external output is available, select `eDP-1`.

The Lua Hyprland event callbacks listen only for monitor add and monitor remove events. They invoke the selector, which parses the normal Hyprland monitor command output with shell tools; it does not require `jq`, `socat`, polling, or a JSON parser dependency. Workspace and window events do not trigger a Waybar restart.

The callback restarts only the Waybar process launched and tracked by this integration. It compares the newly selected output with the current one and does nothing when the selection is unchanged. When it changes, it stops the owned instance, waits for it to exit, and starts the replacement with the selected output, without using a broad `pkill waybar` that could terminate another user's bar.

### Decision: Native tray and autostart

Autostart `nm-applet` and `blueman-applet` from the Hyprland startup path and display them through Waybar's native tray. The setup must avoid launching duplicate applets during a Waybar-only output restart; the applets belong to the Hyprland session lifecycle, not to the Waybar restart lifecycle.

### Decision: NixOS enablement boundary

Applying the complete native network, Bluetooth, and audio integration requires corresponding changes in `~/nixos-config`: `hardware.bluetooth.enable`, `services.blueman.enable`, and installation of `pavucontrol`. The current OpenSpec `actionContext` permits changes only in this repository, so this is a blocking apply prerequisite requiring explicit user approval or a linked cross-repository scope.

The implementation and documentation must surface that prerequisite and stop short of silently omitting it. No sibling-repository edit is authorized by this design.

### Decision: Documentation and deferred work

Update `README` with prerequisites, backup/Stow deployment, Waybar ownership, output-selection behavior, applet startup, and the blocking `~/nixos-config` boundary. Add `docs/roadmap.md` for deferred wallpaper, Wofi, notifications, lock/idle, Powerlevel10k, and GTK/Qt integration work. The roadmap does not authorize implementing those items in this change.

## Risks / Trade-offs

- **Shell parsing Hyprland output:** Human-readable monitor output is less stable than JSON parsing. The no-`jq`/no-`socat` constraint keeps the dependency surface small, but the parser must fail safely when an expected field is missing rather than select an arbitrary output.
- **Monitor naming:** Connector names can differ between machines. The editable preference array is intentionally user-maintained; the external-output fallback and deterministic name tie-break keep selection usable when preferences do not match.
- **Restart races:** Several monitor events can arrive close together, or a replacement Waybar can start before the previous process exits. Tracking ownership, restarting only on selection changes, and waiting for process exit reduce the risk, but live-session verification is still required.
- **CSS and font glyph coverage:** Japanese numerals, `侍`, and Nerd Font symbols may not be covered uniformly by every configured font. The fixed geometry prevents state changes from moving the islands, but setup must verify the actual font fallback and glyph rendering.
- **One-bar trade-off:** A single selected-output bar keeps placement stable and avoids duplicate UI, but other outputs do not receive their own bar. Showing all workspaces in the selected bar is the chosen compromise.
- **Tray and NixOS prerequisites:** Applets may not function until the sibling NixOS options and `pavucontrol` package are enabled. Apply is blocked on explicit cross-repository scope instead of hiding this dependency.
- **Runtime/manual verification:** Waybar has no current configuration and monitor callbacks require a live Hyprland session. Static checks can validate configuration and scripts, but output relocation, fullscreen behavior, tray menus, Bluetooth state colors, and glyphs require manual runtime verification.
- **Backup idempotence:** Repeated deployment must not create confusing backups of the integration's own symlinks, and timestamp collisions or partial Stow failure must not destroy user files. Back up unmanaged paths before Stow, use unique timestamps, and leave owned links untouched on subsequent runs.
