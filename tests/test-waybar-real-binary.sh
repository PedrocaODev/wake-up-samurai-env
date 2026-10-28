#!/usr/bin/env bash
set -euo pipefail

TEST_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_DIR=$(CDPATH= cd -- "$TEST_DIR/.." && pwd)
SELECTOR="$REPO_DIR/hypr/.config/hypr/waybar-output.sh"
WAYBAR_BIN=${WAYBAR_BIN:-$(command -v waybar 2>/dev/null || true)}

[ -x "$WAYBAR_BIN" ] || { echo 'Waybar binary is required for the real-binary smoke check' >&2; exit 1; }
[ -n "${WAYLAND_DISPLAY:-}" ] || { echo 'WAYLAND_DISPLAY is required for the real-binary smoke check' >&2; exit 1; }
[ -n "${XDG_RUNTIME_DIR:-}" ] || { echo 'XDG_RUNTIME_DIR is required for the real-binary smoke check' >&2; exit 1; }

# shellcheck disable=SC1090
. "$SELECTOR"

TEST_TMP=$(mktemp -d "${TMPDIR:-/tmp}/waybar-real-binary.XXXXXX")
trap 'rm -rf "$TEST_TMP"' EXIT HUP INT TERM
mkdir -m 700 "$TEST_TMP/runtime"

export WAYBAR_CONFIG="$REPO_DIR/waybar/.config/waybar/config.jsonc"
export WAYBAR_STYLE="$REPO_DIR/waybar/.config/waybar/style.css"
export XDG_RUNTIME_DIR="$TEST_TMP/runtime"
selected=${WAYBAR_SMOKE_OUTPUT:-eDP-1}
config=$(waybar_create_config "$selected" smoke)
style=$WAYBAR_STYLE
real_runtime_dir=${WAYBAR_REAL_XDG_RUNTIME_DIR:-/run/user/$(id -u)}
log="$TEST_TMP/waybar.log"

set +e
XDG_RUNTIME_DIR="$real_runtime_dir" WAYBAR_OWNER_MARKER=wake-up-samurai-waybar:smoke \
  timeout --signal=TERM 3s "$WAYBAR_BIN" -c "$config" -s "$style" >"$log" 2>&1
status=$?
set -e

[ "$status" -eq 124 ] || {
  printf 'Waybar exited before the smoke timeout (status %s)\n' "$status" >&2
  cat "$log" >&2
  exit 1
}
grep -Fq "Bar configured" "$log" || {
  echo 'Waybar did not configure a bar during the real-binary smoke check' >&2
  cat "$log" >&2
  exit 1
}
grep -Fq "output: $selected" "$log" || {
  echo "Waybar did not configure the selected output: $selected" >&2
  cat "$log" >&2
  exit 1
}

printf 'real Waybar output-selection smoke: PASS (%s)\n' "$selected"
