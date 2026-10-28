#!/bin/sh

waybar_select_output() {
    monitors_file=${1-}
    shift || return 1

    [ -n "$monitors_file" ] || return 1

    preferences=
    for preference do
        if [ -n "$preferences" ]; then
            preferences="$preferences
$preference"
        else
            preferences=$preference
        fi
    done

    LC_ALL=C awk -v preferences="$preferences" '
        function reset_record() {
            current = ""
            have_dimensions = 0
        }

        /^Monitor[[:space:]]/ {
            reset_record()
            if ($0 ~ /^Monitor[[:space:]]+[^[:space:]]+[[:space:]]+\(ID[[:space:]]+[0-9]+\):/) {
                record = $0
                sub(/^Monitor[[:space:]]+/, "", record)
                current = record
                sub(/[[:space:]].*$/, "", current)
            }
            next
        }

        current != "" && !have_dimensions && $0 ~ /^[[:space:]]*[0-9]+x[0-9]+@/ {
            dimensions = $0
            sub(/^[[:space:]]*/, "", dimensions)
            sub(/@.*$/, "", dimensions)
            split(dimensions, size, "x")
            area = (size[1] + 0) * (size[2] + 0)
            have_dimensions = 1
            if (area > 0)
                areas[current] = area
        }

        END {
            preference_count = split(preferences, preferred, "\n")
            if (preferences == "")
                preference_count = 0

            for (i = 1; i <= preference_count; i++) {
                if (preferred[i] in areas) {
                    print preferred[i]
                    exit 0
                }
            }

            external = ""
            largest = -1
            for (name in areas) {
                if (name != "eDP-1" && (areas[name] > largest || (areas[name] == largest && (external == "" || name < external)))) {
                    external = name
                    largest = areas[name]
                }
            }
            if (external != "") {
                print external
                exit 0
            }

            if ("eDP-1" in areas) {
                print "eDP-1"
                exit 0
            }
            exit 1
        }
    ' "$monitors_file"
}

waybar_private_dir() {
    private_dir=$1
    [ -n "$private_dir" ] || return 1

    if [ -L "$private_dir" ]; then
        return 1
    fi
    if [ ! -e "$private_dir" ]; then
        (umask 077; mkdir -- "$private_dir") || return 1
    fi
    [ -d "$private_dir" ] || return 1
    [ "$(stat -c '%u' "$private_dir" 2>/dev/null)" = "$(id -u)" ] || return 1
    chmod 700 -- "$private_dir" || return 1
    [ "$(stat -c '%a' "$private_dir" 2>/dev/null)" = 700 ]
}

waybar_runtime_dir() {
    runtime_base=${XDG_RUNTIME_DIR-}
    if [ -n "$runtime_base" ] && [ -d "$runtime_base" ] && [ ! -L "$runtime_base" ] \
        && [ "$(stat -c '%u' "$runtime_base" 2>/dev/null)" = "$(id -u)" ] \
        && [ "$(stat -c '%a' "$runtime_base" 2>/dev/null)" = 700 ]; then
        runtime_dir=$runtime_base/wake-up-samurai-waybar
        waybar_private_dir "$runtime_dir" || return 1
        printf '%s\n' "$runtime_dir"
        return 0
    fi

    # ponytail: use one mktemp-created fallback directory and remember its path
    # in a private cache directory; upgrade to a session manager if cleanup or
    # multiple concurrent desktop sessions become a requirement.
    cache_base=${XDG_CACHE_HOME:-${HOME:-}/.cache}
    [ -n "$cache_base" ] || return 1
    fallback_root=$cache_base/wake-up-samurai-waybar
    if [ ! -d "$cache_base" ]; then
        (umask 077; mkdir -p -- "$cache_base") || return 1
    fi
    waybar_private_dir "$fallback_root" || return 1

    runtime_lock=$fallback_root/.runtime.lock
    [ ! -L "$runtime_lock" ] || return 1
    (umask 077; : >> "$runtime_lock") || return 1
    chmod 600 -- "$runtime_lock" || return 1
    exec 8>>"$runtime_lock"
    flock -x 8 || { exec 8>&-; return 1; }

    runtime_dir=
    runtime_locator=$fallback_root/runtime-dir
    if [ -f "$runtime_locator" ] && [ ! -L "$runtime_locator" ]; then
        IFS= read -r runtime_dir < "$runtime_locator" || runtime_dir=
        case $runtime_dir in
            /*) waybar_private_dir "$runtime_dir" || runtime_dir= ;;
            *) runtime_dir= ;;
        esac
    fi
    if [ -z "$runtime_dir" ]; then
        runtime_dir=$(mktemp -d "${TMPDIR:-/tmp}/wake-up-samurai-waybar.XXXXXX") || {
            flock -u 8
            exec 8>&-
            return 1
        }
        chmod 700 -- "$runtime_dir" || {
            rmdir -- "$runtime_dir" 2>/dev/null || :
            flock -u 8
            exec 8>&-
            return 1
        }
        locator_tmp=$(mktemp "$fallback_root/.runtime-dir.XXXXXX") || {
            rmdir -- "$runtime_dir" 2>/dev/null || :
            flock -u 8
            exec 8>&-
            return 1
        }
        chmod 600 -- "$locator_tmp"
        printf '%s\n' "$runtime_dir" > "$locator_tmp" && mv -f -- "$locator_tmp" "$runtime_locator" || {
            rm -f -- "$locator_tmp"
            rmdir -- "$runtime_dir" 2>/dev/null || :
            flock -u 8
            exec 8>&-
            return 1
        }
    fi

    flock -u 8
    exec 8>&-
    printf '%s\n' "$runtime_dir"
}

waybar_runtime_state_file() {
    runtime_dir=$(waybar_runtime_dir) || return 1
    printf '%s/state\n' "$runtime_dir"
}

waybar_resolve_launcher() {
    launcher=${WAYBAR_BIN-}
    if [ -z "$launcher" ]; then
        launcher=$(command -v waybar 2>/dev/null) || return 1
    fi
    case $launcher in
        /*) ;;
        *) launcher=$(command -v "$launcher" 2>/dev/null) || return 1 ;;
    esac
    [ -x "$launcher" ] || return 1
    printf '%s\n' "$launcher"
}

waybar_new_token() {
    token=$(od -An -N16 -tx1 /dev/urandom 2>/dev/null | tr -d ' \n')
    if [ -z "$token" ]; then
        token=$(date +%s)-$$-$(id -u)
    fi
    printf '%s\n' "$token"
}

waybar_config_path() {
    config=${WAYBAR_CONFIG:-${XDG_CONFIG_HOME:-${HOME:-}/.config}/waybar/config.jsonc}
    [ -r "$config" ] || return 1
    printf '%s\n' "$config"
}

waybar_style_path() {
    style=${WAYBAR_STYLE:-${XDG_CONFIG_HOME:-${HOME:-}/.config}/waybar/style.css}
    [ -r "$style" ] || return 1
    printf '%s\n' "$style"
}

waybar_create_config() {
    selected=$1
    token=$2
    case $selected in
        ''|*[!A-Za-z0-9._:-]*) return 1 ;;
    esac
    case $token in
        ''|*[!A-Za-z0-9._:-]*) return 1 ;;
    esac

    runtime_dir=$(waybar_runtime_dir) || return 1
    source_config=$(waybar_config_path) || return 1
    config_tmp=$(mktemp "$runtime_dir/.config.XXXXXX") || return 1
    chmod 600 -- "$config_tmp" || { rm -f -- "$config_tmp"; return 1; }
    if ! awk -v output="$selected" '
        !inserted && $0 ~ /^[[:space:]]*\{/ {
            print
            printf "  \"output\": \"%s\",\n", output
            inserted = 1
            next
        }
        { print }
        END { if (!inserted) exit 1 }
    ' "$source_config" > "$config_tmp"; then
        rm -f -- "$config_tmp"
        return 1
    fi

    config="$runtime_dir/config-$token.jsonc"
    if [ -e "$config" ] || [ -L "$config" ]; then
        rm -f -- "$config_tmp"
        return 1
    fi
    mv -- "$config_tmp" "$config" || {
        rm -f -- "$config_tmp"
        return 1
    }
    printf '%s\n' "$config"
}

waybar_state_is_private() {
    state_file=$1
    [ -f "$state_file" ] && [ ! -L "$state_file" ] || return 1
    [ "$(stat -c '%u' "$state_file" 2>/dev/null)" = "$(id -u)" ] || return 1
    chmod 600 -- "$state_file"
}

waybar_process_starttime() {
    pid=$1
    [ -r "/proc/$pid/stat" ] || return 1
    awk '{ sub(/^.*\) /, ""); print $20 }' "/proc/$pid/stat" 2>/dev/null
}

waybar_pid_is_owned() {
    pid=$1
    token=$2
    expected_start=${3-}
    case $pid in ''|0|*[!0-9]*) return 1 ;; esac
    case $token in ''|*[!A-Za-z0-9._:-]*) return 1 ;; esac
    marker="wake-up-samurai-waybar:$token"
    marker_found=0
    if [ -r "/proc/$pid/cmdline" ]; then
        cmdline=$(tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null) || cmdline=
        case " $cmdline " in
            *" $marker "*) marker_found=1 ;;
        esac
    fi
    if [ "$marker_found" -eq 0 ] && [ -r "/proc/$pid/environ" ]; then
        environment=$(tr '\0' '\n' < "/proc/$pid/environ" 2>/dev/null) || environment=
        case "$environment" in
            *"WAYBAR_OWNER_MARKER=$marker"*) marker_found=1 ;;
        esac
    fi
    [ "$marker_found" -eq 1 ] || return 1
    [ -z "$expected_start" ] || [ "$(waybar_process_starttime "$pid")" = "$expected_start" ]
}

waybar_pid_is_alive() {
    pid=$1
    case $pid in ''|0|*[!0-9]*) return 1 ;; esac
    [ -r "/proc/$pid/stat" ] || return 1
    process_state=$(awk '{ print $3 }' "/proc/$pid/stat" 2>/dev/null) || return 1
    [ "$process_state" != Z ]
}

waybar_wait_for_exit() {
    # kill -0 is intentionally limited to this bounded post-TERM wait. It is
    # not used to monitor monitors or to drive output selection.
    pid=$1
    token=$2
    starttime=$3
    attempts=0
    while [ "$attempts" -lt 100 ]; do
        waybar_pid_is_owned "$pid" "$token" "$starttime" || return 0
        waybar_pid_is_alive "$pid" || return 0
        kill -0 "$pid" 2>/dev/null || return 0
        sleep 0.01
        attempts=$((attempts + 1))
    done

    waybar_pid_is_owned "$pid" "$token" "$starttime" || return 0
    kill -KILL "$pid" 2>/dev/null || :
    attempts=0
    while [ "$attempts" -lt 50 ]; do
        waybar_pid_is_owned "$pid" "$token" "$starttime" || return 0
        waybar_pid_is_alive "$pid" || return 0
        kill -0 "$pid" 2>/dev/null || return 0
        sleep 0.01
        attempts=$((attempts + 1))
    done
    return 1
}

waybar_write_state() {
    state_file=$1
    selected=$2
    pid=$3
    token=$4
    launcher=$5
    starttime=${6-}
    config=${7-}
    state_dir=${state_file%/*}
    [ "$state_dir" != "$state_file" ] || state_dir=.
    state_tmp=$(mktemp "$state_dir/.state.XXXXXX") || return 1
    chmod 600 -- "$state_tmp" || { rm -f -- "$state_tmp"; return 1; }
    {
        printf 'version=1\n'
        printf 'output=%s\n' "$selected"
        printf 'pid=%s\n' "$pid"
        printf 'token=%s\n' "$token"
        printf 'starttime=%s\n' "$starttime"
        printf 'launcher=%s\n' "$launcher"
        printf 'config=%s\n' "$config"
    } > "$state_tmp" && mv -f -- "$state_tmp" "$state_file" || {
        rm -f -- "$state_tmp"
        return 1
    }
}

waybar_spawn() {
    launcher=$1
    selected=$2
    token=$3
    marker="wake-up-samurai-waybar:$token"
    WAYBAR_SPAWNED_CONFIG=
    if [ -n "${WAYBAR_TEST_ACTION_LOG-}" ]; then
        WAYBAR_OWNER_MARKER="$marker" "$launcher" "$selected" &
    else
        config=$(waybar_create_config "$selected" "$token") || return 1
        style=$(waybar_style_path) || {
            rm -f -- "$config"
            return 1
        }
        WAYBAR_SPAWNED_CONFIG=$config
        WAYBAR_OWNER_MARKER="$marker" "$launcher" -c "$config" -s "$style" &
    fi
    WAYBAR_SPAWNED_PID=$!
}

waybar_secure_state_dir() {
    state_dir=$1
    [ -n "$state_dir" ] || return 1
    [ -d "$state_dir" ] && [ ! -L "$state_dir" ] || return 1
    [ "$(stat -c '%u' "$state_dir" 2>/dev/null)" = "$(id -u)" ] || return 1
    chmod 700 -- "$state_dir" || return 1
    [ "$(stat -c '%a' "$state_dir" 2>/dev/null)" = 700 ]
}

waybar_reconcile_locked() {
    selected=$1
    state_file=$2
    launcher=$3
    current_output=
    current_pid=
    current_token=
    current_start=
    current_config=

    if waybar_state_is_private "$state_file"; then
        while IFS='=' read -r key value; do
            case $key in
                output) current_output=$value ;;
                pid) current_pid=$value ;;
                token) current_token=$value ;;
                starttime) current_start=$value ;;
                config) current_config=$value ;;
            esac
        done < "$state_file"
    fi

    owned=0
    if waybar_pid_is_owned "$current_pid" "$current_token" "$current_start" && waybar_pid_is_alive "$current_pid"; then
        owned=1
    fi
    [ "$current_output" = "$selected" ] && [ "$owned" -eq 1 ] && return 0

    if [ "$owned" -eq 1 ]; then
        kill -TERM "$current_pid" 2>/dev/null || :
        waybar_wait_for_exit "$current_pid" "$current_token" "$current_start" || return 1
    fi

    case $current_config in
        "$state_dir"/config-*.jsonc)
            [ ! -L "$current_config" ] && rm -f -- "$current_config"
            ;;
    esac

    token=$(waybar_new_token) || return 1
    waybar_spawn "$launcher" "$selected" "$token" || return 1
    new_pid=$WAYBAR_SPAWNED_PID
    new_config=${WAYBAR_SPAWNED_CONFIG-}
    new_start=$(waybar_process_starttime "$new_pid") || {
        kill -TERM "$new_pid" 2>/dev/null || :
        return 1
    }
    waybar_write_state "$state_file" "$selected" "$new_pid" "$token" "$launcher" "$new_start" "$new_config" || {
        kill -TERM "$new_pid" 2>/dev/null || :
        waybar_wait_for_exit "$new_pid" "$token" "$new_start" || :
        [ -z "$new_config" ] || rm -f -- "$new_config"
        return 1
    }
}

waybar_reconcile_output() {
    selected=${1-}
    state_file=${2-}
    launcher=${3-}
    [ -n "$selected" ] && [ -n "$state_file" ] && [ -n "$launcher" ] || return 1

    state_dir=${state_file%/*}
    [ "$state_dir" != "$state_file" ] || state_dir=.
    waybar_secure_state_dir "$state_dir" || return 1
    [ ! -L "$state_file" ] || return 1
    lock_file=$state_dir/.lock
    [ ! -L "$lock_file" ] || return 1
    (umask 077; : >> "$lock_file") || return 1
    chmod 600 -- "$lock_file" || return 1
    exec 9>>"$lock_file"
    flock -x 9 || { exec 9>&-; return 1; }
    waybar_reconcile_locked "$selected" "$state_file" "$launcher"
    status=$?
    flock -u 9
    exec 9>&-
    return "$status"
}

waybar_should_reselect() {
    case ${1-} in
        hyprland.start|monitor.added|monitor.removed) return 0 ;;
        *) return 1 ;;
    esac
}

waybar_reselect() {
    launcher=$(waybar_resolve_launcher) || return 1
    state_file=$(waybar_runtime_state_file) || return 1
    selected=$(hyprctl monitors | waybar_select_output - "$@") || return 1
    [ -n "$selected" ] || return 1
    waybar_reconcile_output "$selected" "$state_file" "$launcher"
}

waybar_start() {
    waybar_reselect "$@"
}

case ${1-} in
    --start)
        shift
        waybar_start "$@"
        ;;
    --reconcile)
        shift
        waybar_reselect "$@"
        ;;
esac
