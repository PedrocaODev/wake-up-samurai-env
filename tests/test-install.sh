#!/usr/bin/env bash
set -euo pipefail

TEST_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_DIR=$(CDPATH= cd -- "$TEST_DIR/.." && pwd)
INSTALLER="$REPO_DIR/install.sh"
TEST_TMP=$(mktemp -d "${TMPDIR:-/tmp}/install-test.XXXXXX")
trap 'rm -rf "$TEST_TMP"' EXIT HUP INT TERM

HOME_DIR="$TEST_TMP/home"
FAKE_BIN="$TEST_TMP/bin"
FAKE_STOW_LOG="$TEST_TMP/stow.log"
BACKUP_TIMESTAMP=20240102030405
HYPR_DIR="$HOME_DIR/.config/hypr"
HYPR_TARGET="$HYPR_DIR/hyprland.lua"
MANAGED_HYPR="$REPO_DIR/hypr/.config/hypr/hyprland.lua"
COLLISION_BACKUP="$HYPR_TARGET.backup.$BACKUP_TIMESTAMP"
UNRELATED_FILE="$HOME_DIR/.config/unrelated.conf"

mkdir -p "$HYPR_DIR" "$FAKE_BIN" "$HOME_DIR/.config"
printf 'user-managed hyprland\n' > "$HYPR_TARGET"
printf 'existing collision backup\n' > "$COLLISION_BACKUP"
printf 'leave this file alone\n' > "$UNRELATED_FILE"

cat > "$FAKE_BIN/stow" <<'FAKE_STOW'
#!/usr/bin/env bash
set -euo pipefail

source_dir=
target_dir=
packages=()
while [ "$#" -gt 0 ]; do
    case "$1" in
        -d) source_dir=$2; shift 2 ;;
        -t) target_dir=$2; shift 2 ;;
        *) packages+=("$1"); shift ;;
    esac
done

printf 'source=%s target=%s packages=%s\n' "$source_dir" "$target_dir" "${packages[*]}" >> "${FAKE_STOW_LOG:?}"

for package in "${packages[@]}"; do
    package_dir="$source_dir/$package"
    [ -d "$package_dir" ] || { printf 'missing package: %s\n' "$package" >&2; exit 1; }

    while IFS= read -r source_file; do
        relative=${source_file#"$package_dir"/}
        target_file="$target_dir/$relative"
        if [ -L "$target_file" ] && [ "$(readlink -f "$target_file")" = "$(readlink -f "$source_file")" ]; then
            continue
        fi
        if [ -e "$target_file" ] || [ -L "$target_file" ]; then
            printf 'target collision: %s\n' "$target_file" >&2
            exit 1
        fi
        mkdir -p "$(dirname "$target_file")"
        ln -s "$source_file" "$target_file"
    done < <(find "$package_dir" -type f -print)
done
FAKE_STOW
chmod +x "$FAKE_BIN/stow"

check() {
    if "$@"; then
        return 0
    fi
    printf 'not ok - %s\n' "$1" >&2
    exit 1
}

check_equal() {
    local expected=$1 actual=$2 description=$3
    if [ "$expected" = "$actual" ]; then
        return 0
    fi
    printf 'not ok - %s (expected %q, got %q)\n' "$description" "$expected" "$actual" >&2
    exit 1
}

run_installer() {
    HOME="$HOME_DIR" \
    PATH="$FAKE_BIN:$PATH" \
    FAKE_STOW_LOG="$FAKE_STOW_LOG" \
    BACKUP_TIMESTAMP="$BACKUP_TIMESTAMP" \
    "$INSTALLER" >/dev/null
}

run_installer

check grep -Fq "source=$REPO_DIR target=$HOME_DIR packages=alacritty herdr nvim pi hypr waybar foot pavucontrol" "$FAKE_STOW_LOG"
check [ -L "$HYPR_TARGET" ]
check_equal "$(readlink -f "$MANAGED_HYPR")" "$(readlink -f "$HYPR_TARGET")" 'Hyprland entrypoint points to the complete repository file'

for relative in \
    .config/waybar/config.jsonc \
    .config/waybar/style.css \
    .config/foot/foot.ini \
    .config/pavucontrol.ini; do
    deployed="$HOME_DIR/$relative"
    case "$relative" in
        .config/foot/*) pkg=foot ;;
        .config/pavucontrol.ini) pkg=pavucontrol ;;
        *) pkg=waybar ;;
    esac
    source="$REPO_DIR/$pkg/$relative"
    check [ -L "$deployed" ]
    check_equal "$(readlink -f "$source")" "$(readlink -f "$deployed")" "$relative is deployed from the repository"
done

check grep -Fxq 'existing collision backup' "$COLLISION_BACKUP"
backup_count=$(find "$HYPR_DIR" -maxdepth 1 -type f -name "hyprland.lua.backup.$BACKUP_TIMESTAMP*" -printf '%f\n' | wc -l)
check_equal 2 "$backup_count" 'unmanaged Hyprland file gets one non-colliding backup'
new_backup_count=$(find "$HYPR_DIR" -maxdepth 1 -type f -name "hyprland.lua.backup.$BACKUP_TIMESTAMP*" ! -name "hyprland.lua.backup.$BACKUP_TIMESTAMP" -printf '%f\n' | wc -l)
check_equal 1 "$new_backup_count" 'backup uses a unique suffix after timestamp collision'
new_backup=$(find "$HYPR_DIR" -maxdepth 1 -type f -name "hyprland.lua.backup.$BACKUP_TIMESTAMP*" ! -name "hyprland.lua.backup.$BACKUP_TIMESTAMP" -print)
check grep -Fxq 'user-managed hyprland' "$new_backup"
check grep -Fxq 'leave this file alone' "$UNRELATED_FILE"

run_installer
repeat_backup_count=$(find "$HYPR_DIR" -maxdepth 1 -type f -name "hyprland.lua.backup.$BACKUP_TIMESTAMP*" -printf '%f\n' | wc -l)
check_equal "$backup_count" "$repeat_backup_count" 'repeat deployment does not create another backup'
check [ -L "$HYPR_TARGET" ]
check_equal "$(readlink -f "$MANAGED_HYPR")" "$(readlink -f "$HYPR_TARGET")" 'repeat deployment keeps the repository-owned Hyprland link'

printf 'installer temporary-HOME contract: PASS\n'
