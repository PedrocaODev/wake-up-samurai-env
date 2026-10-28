#!/usr/bin/env bash
set -eu

config=waybar/.config/waybar/config.jsonc
style=waybar/.config/waybar/style.css
[ -f "$config" ] || { echo "missing $config" >&2; exit 1; }
[ -f "$style" ] || { echo "missing $style" >&2; exit 1; }

for needle in '"height": 36' '"position": "top"' '"exclusive": true' '"modules-left"' '"modules-center"' '"modules-right"' 'hyprland/workspaces' 'hyprland/window' 'mpris' 'clock' 'tray' 'cpu' 'memory' 'disk' '"group/disk"' '"drawer"' '"ignored-players"' '"on-click-middle": "previous"' '"on-click-right": "next"' '"on-scroll-up": "previous"' '"on-scroll-down": "next"' 'pulseaudio' 'backlight' 'network' 'privacy' 'battery' '侍' 'wlp0s20f3' 'enp3s0' 'pavucontrol' 'nm-connection-editor'; do
  grep -Fq "$needle" "$config" || { echo "missing config identifier: $needle" >&2; exit 1; }
done
grep -Fq '"modules-center": ["clock", "mpris"]' "$config" || { echo 'clock must be the first center module' >&2; exit 1; }
grep -Fq '"modules-right": ["tray", "cpu", "memory", "group/disk"' "$config" || { echo 'memory must be a direct always-visible right-island module' >&2; exit 1; }
! grep -Fq '"bluetooth"' "$config"
for needle in '"format": " {usage}%"' '"format": " {percentage}%"' '"format": " {percentage_used}%"' '"format": " {volume}%"' '"format-muted": " muted"' '"format": " {percent}%"' '"format-wifi": " {essid}"' '"format-ethernet": "󰈀 {ipaddr}"' '"format-disconnected": " off"' '"format": " {capacity}%"'; do
  grep -Fq "$needle" "$config" || { echo "missing selected icon format: $needle" >&2; exit 1; }
done
grep -Fq '"modules": ["disk"]' "$config" || { echo 'disk drawer must contain only disk' >&2; exit 1; }
for needle in '@define-color bg ' '@define-color text ' '@define-color muted ' '@define-color accent ' '@define-color cyan ' 'font-family: monospace'; do
  grep -Fqi -- "$needle" "$style" || { echo "missing style identifier: $needle" >&2; exit 1; }
done
! grep -Fq 'Symbols Nerd Font Mono' "$style"
for needle in 'animation' 'keyframes'; do
  if grep -Fqi -- "$needle" "$style"; then
    echo "forbidden animation: $needle" >&2; exit 1
  fi
done
# Output selection is supplied by the launcher in a generated Waybar-0.15 config.
! grep -Eq '^\s*"output"\s*:' "$config"
! grep -Fq '"format-player"' "$config"
! grep -Fq '"ignore-player"' "$config"
! grep -Fq '"on-click-middle": "previous track"' "$config"
! grep -Fq '"on-click-right": "next track"' "$config"

echo 'waybar config static contract: PASS'
