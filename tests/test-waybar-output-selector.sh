#!/usr/bin/env bash
#
# Slice 1 RED contract for hypr/.config/hypr/waybar-output.sh.
#
# The production file is sourceable and must not start Waybar when sourced. It
# exposes this intentionally small contract:
#
#   waybar_select_output MONITORS_FILE PREFERENCE...
#       Reads captured `hyprctl monitors` human-readable output and prints one
#       connector name. A record starts with `Monitor NAME (ID N):`; the first
#       following WIDTHxHEIGHT@... line supplies the pixel area. Records without
#       a connector name or valid dimensions are ignored. Every valid name other
#       than eDP-1 is an external output. The function returns non-zero if no
#       valid output can be selected.
#
#   waybar_reconcile_output SELECTED_OUTPUT STATE_FILE LAUNCHER
#       STATE_FILE contains output=NAME and pid=PID. If NAME is unchanged, the
#       tracked process and state remain untouched. If it changes, only PID is
#       terminated, the function waits for that child to exit, then runs
#       LAUNCHER SELECTED_OUTPUT in the background and writes the new output/PID.
#       The test launcher is a local fake Waybar process.
#
#   waybar_should_reselect EVENT
#       Returns 0 only for hyprland.start, monitor.added, and monitor.removed;
#       it returns 1 for all other events.
#
# These tests deliberately target the absent production interface. They are RED
# until the implementation is added in the later Slice 2.

set -o pipefail
export LC_ALL=C

TEST_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
FIXTURE_DIR="$TEST_DIR/fixtures"
SELECTOR="$TEST_DIR/../hypr/.config/hypr/waybar-output.sh"
CONTRACT_LOADED=0

PASS_COUNT=0
FAIL_COUNT=0

pass() {
    PASS_COUNT=$((PASS_COUNT + 1))
    printf 'ok - %s\n' "$1"
}

fail() {
    FAIL_COUNT=$((FAIL_COUNT + 1))
    printf 'not ok - %s\n' "$1"
}

# Keep the missing-file failure explicit instead of letting an absent source
# turn the whole script into a skipped/vacuous test.
if [ -f "$SELECTOR" ]; then
    # shellcheck disable=SC1090
    if . "$SELECTOR"; then
        CONTRACT_LOADED=1
    else
        printf 'not ok - source %s (source failed)\n' "$SELECTOR"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
else
    printf 'not ok - source %s (implementation is absent)\n' "$SELECTOR"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

selector_call() {
    if [ "$CONTRACT_LOADED" -ne 1 ] || ! declare -F waybar_select_output >/dev/null 2>&1; then
        printf 'selector function unavailable\n' >&2
        return 127
    fi
    waybar_select_output "$@"
}

reconcile_call() {
    if [ "$CONTRACT_LOADED" -ne 1 ] || ! declare -F waybar_reconcile_output >/dev/null 2>&1; then
        printf 'reconcile function unavailable\n' >&2
        return 127
    fi
    waybar_reconcile_output "$@"
}

event_call() {
    if [ "$CONTRACT_LOADED" -ne 1 ] || ! declare -F waybar_should_reselect >/dev/null 2>&1; then
        printf 'event whitelist function unavailable\n' >&2
        return 127
    fi
    waybar_should_reselect "$1"
}

assert_selection() {
    fixture=$1
    expected=$2
    name=$3
    shift 3

    actual=$(selector_call "$FIXTURE_DIR/$fixture" "$@" 2>/dev/null)
    status=$?
    if [ "$status" -ne 0 ]; then
        fail "$name (selector unavailable or rejected fixture; exit $status)"
    elif [ "$actual" = "$expected" ]; then
        pass "$name"
    else
        fail "$name (expected '$expected', got '$actual')"
    fi
}

assert_event_status() {
    event=$1
    expected=$2
    name=$3

    event_call "$event" >/dev/null 2>&1
    status=$?
    if [ "$status" -eq "$expected" ]; then
        pass "$name"
    else
        fail "$name (expected exit $expected, got $status)"
    fi
}

state_value() {
    wanted=$1
    state=$2
    while IFS='=' read -r key value; do
        if [ "$key" = "$wanted" ]; then
            printf '%s' "$value"
            return 0
        fi
    done < "$state"
    return 1
}

spawn_owned_fake() {
    role=$1
    output=$2
    token=$3
    state=$4
    pid_file=$TEST_TMP/waybar-$role.pid
    rm -f -- "$pid_file"
    WAYBAR_TEST_PID_FILE=$pid_file WAYBAR_TEST_ROLE=$role waybar_spawn "$FIXTURE_DIR/fake-waybar.sh" "$output" "$token"
    pid=$WAYBAR_SPAWNED_PID
    for _ in 1 2 3 4 5 6 7 8 9 10; do
        [ -s "$pid_file" ] && break
        sleep 0.01
    done
    child_pid=$(<"$pid_file")
    starttime=$(waybar_process_starttime "$child_pid")
    printf 'output=%s\npid=%s\ntoken=%s\nstarttime=%s\n' "$output" "$child_pid" "$token" "$starttime" > "$state"
    remember_pid "$pid"
    remember_pid "$child_pid"
}

TEST_TMP=$(mktemp -d "${TMPDIR:-/tmp}/waybar-output-selector.XXXXXX")
OWNED_PIDS=""

remember_pid() {
    OWNED_PIDS="$OWNED_PIDS $1"
}

cleanup() {
    for pid in $OWNED_PIDS; do
        if kill -0 "$pid" 2>/dev/null; then
            kill -TERM "$pid" 2>/dev/null || :
            wait "$pid" 2>/dev/null || :
        fi
    done
    rm -rf "$TEST_TMP"
}
trap cleanup EXIT HUP INT TERM

assert_selection \
    monitors-preference.txt DP-1 \
    'selects the first connected ordered preference' \
    DP-1 HDMI-A-1
assert_selection \
    monitors-preference.txt HDMI-A-1 \
    'continues to the next ordered preference when the first is unavailable' \
    USB-C-1 HDMI-A-1
assert_selection \
    monitors-largest.txt USB-C-1 \
    'selects the largest external output by pixel area' \
    VGA-1
assert_selection \
    monitors-tie.txt DP-1 \
    'uses the lexicographically lowest name for equal external areas' \
    USB-C-1
assert_selection \
    monitors-fallback.txt eDP-1 \
    'falls back to eDP-1 when no connected external output exists' \
    USB-C-1
assert_selection \
    monitors-malformed.txt eDP-1 \
    'ignores an incomplete monitor record instead of selecting it arbitrarily' \
    HDMI-A-1

run_unchanged_selection_test() {
    if [ "$CONTRACT_LOADED" -ne 1 ] || ! declare -F waybar_reconcile_output >/dev/null 2>&1; then
        fail 'does not restart the tracked Waybar when selection is unchanged (reconcile function unavailable)'
        return
    fi

    log="$TEST_TMP/unchanged.log"
    state="$TEST_TMP/unchanged.state"
    : > "$log"
    export WAYBAR_TEST_ACTION_LOG="$log"

    spawn_owned_fake old eDP-1 unchanged-token "$state"
    owned_pid=$(state_value pid "$state")
    sleep 0.1

    selected=$(selector_call "$FIXTURE_DIR/monitors-malformed.txt" HDMI-A-1 2>/dev/null)
    select_status=$?
    if [ "$select_status" -ne 0 ] || [ "$selected" != eDP-1 ]; then
        fail 'does not restart after a malformed record leaves the selection unchanged (selector unavailable)'
        return
    fi

    reconcile_call "$selected" "$state" "$FIXTURE_DIR/fake-waybar.sh" >/dev/null 2>&1
    reconcile_status=$?
    actual_log=$(<"$log")
    actual_pid_alive=1
    kill -0 "$owned_pid" 2>/dev/null || actual_pid_alive=0

    if [ "$reconcile_status" -eq 0 ] && [ "$actual_log" = 'old-start:eDP-1' ] && [ "$actual_pid_alive" -eq 1 ]; then
        pass 'does not restart the tracked Waybar when selection is unchanged'
    else
        fail "does not restart the tracked Waybar when selection is unchanged (status $reconcile_status, log '$actual_log', alive $actual_pid_alive)"
    fi
}

run_changed_selection_test() {
    if [ "$CONTRACT_LOADED" -ne 1 ] || ! declare -F waybar_reconcile_output >/dev/null 2>&1; then
        fail 'stops, waits for, and replaces only the tracked Waybar on selection change (reconcile function unavailable)'
        return
    fi

    log="$TEST_TMP/changed.log"
    unrelated_log="$TEST_TMP/unrelated.log"
    state="$TEST_TMP/changed.state"
    : > "$log"
    : > "$unrelated_log"
    export WAYBAR_TEST_ACTION_LOG="$log"

    WAYBAR_TEST_ACTION_LOG="$unrelated_log" WAYBAR_TEST_ROLE=unrelated "$FIXTURE_DIR/fake-waybar.sh" unrelated-output &
    unrelated_pid=$!
    remember_pid "$unrelated_pid"
    sleep 0.1

    spawn_owned_fake old eDP-1 changed-token "$state"
    owned_pid=$(state_value pid "$state")
    sleep 0.1

    reconcile_call DP-1 "$state" "$FIXTURE_DIR/fake-waybar.sh" >/dev/null 2>&1
    reconcile_status=$?
    new_pid=$(state_value pid "$state" 2>/dev/null || :)
    actual_log=$(<"$log")
    actual_unrelated_log=$(<"$unrelated_log")
    old_alive=1
    unrelated_alive=0
    kill -0 "$owned_pid" 2>/dev/null || old_alive=0
    kill -0 "$unrelated_pid" 2>/dev/null && unrelated_alive=1

    expected_log=$'old-start:eDP-1\nold-exit:eDP-1\nstart:DP-1'
    if [ "$reconcile_status" -eq 0 ] \
        && [ "$old_alive" -eq 0 ] \
        && [ "$actual_log" = "$expected_log" ] \
        && [ "$actual_unrelated_log" = 'unrelated-start:unrelated-output' ] \
        && [ "$unrelated_alive" -eq 1 ] \
        && [ "$new_pid" ] \
        && [ "$new_pid" != "$owned_pid" ] \
        && kill -0 "$new_pid" 2>/dev/null \
        && [ "$(state_value output "$state")" = 'DP-1' ]; then
        remember_pid "$new_pid"
        pass 'stops, waits for, and replaces only the tracked Waybar on selection change'
    else
        [ "$new_pid" ] && remember_pid "$new_pid"
        fail "stops, waits for, and replaces only the tracked Waybar on selection change (status $reconcile_status, old_alive $old_alive, unrelated_alive $unrelated_alive, log '$actual_log', unrelated '$actual_unrelated_log')"
    fi
}

run_timeout_escalation_test() {
    if [ "$CONTRACT_LOADED" -ne 1 ] || ! declare -F waybar_reconcile_output >/dev/null 2>&1; then
        fail 'kills the actual tracked Waybar child after TERM timeout (reconcile function unavailable)'
        return
    fi

    log="$TEST_TMP/timeout.log"
    state="$TEST_TMP/timeout.state"
    : > "$log"
    export WAYBAR_TEST_ACTION_LOG="$log"
    spawn_owned_fake stubborn eDP-1 timeout-token "$state"
    owned_pid=$(state_value pid "$state")

    reconcile_call DP-1 "$state" "$FIXTURE_DIR/fake-waybar.sh" >/dev/null 2>&1
    status=$?
    new_pid=$(state_value pid "$state" 2>/dev/null || :)
    old_alive=0
    kill -0 "$owned_pid" 2>/dev/null && old_alive=1
    if [ "$status" -eq 0 ] && [ "$old_alive" -eq 0 ] && [ -n "$new_pid" ] && kill -0 "$new_pid" 2>/dev/null; then
        remember_pid "$new_pid"
        pass 'kills the actual tracked Waybar child after TERM timeout'
    else
        [ "$new_pid" ] && remember_pid "$new_pid"
        fail "kills the actual tracked Waybar child after TERM timeout (status $status, old_alive $old_alive, new_pid $new_pid)"
    fi
}

run_stale_and_unowned_state_test() {
    if [ "$CONTRACT_LOADED" -ne 1 ] || ! declare -F waybar_reconcile_output >/dev/null 2>&1; then
        fail 'replaces stale or unowned state without killing an arbitrary PID (reconcile function unavailable)'
        return
    fi

    log="$TEST_TMP/stale.log"
    state="$TEST_TMP/stale.state"
    : > "$log"
    export WAYBAR_TEST_ACTION_LOG="$log"
    printf 'output=eDP-1\npid=999999999\ntoken=stale-token\nstarttime=1\n' > "$state"

    reconcile_call eDP-1 "$state" "$FIXTURE_DIR/fake-waybar.sh" >/dev/null 2>&1
    status=$?
    new_pid=$(state_value pid "$state" 2>/dev/null || :)
    actual_log=$(<"$log")
    if [ "$status" -eq 0 ] && [ "$actual_log" = 'start:eDP-1' ] && [ -n "$new_pid" ] && kill -0 "$new_pid" 2>/dev/null; then
        remember_pid "$new_pid"
        pass 'replaces stale or unowned state without killing an arbitrary PID'
    else
        [ "$new_pid" ] && remember_pid "$new_pid"
        fail "replaces stale or unowned state without killing an arbitrary PID (status $status, pid $new_pid, log '$actual_log')"
    fi
}

run_concurrent_reconcile_test() {
    if [ "$CONTRACT_LOADED" -ne 1 ] || ! declare -F waybar_reconcile_output >/dev/null 2>&1; then
        fail 'serializes concurrent callbacks to one owned Waybar (reconcile function unavailable)'
        return
    fi

    log="$TEST_TMP/concurrent.log"
    state="$TEST_TMP/concurrent.state"
    : > "$log"
    export WAYBAR_TEST_ACTION_LOG="$log"
    reconcile_call DP-1 "$state" "$FIXTURE_DIR/fake-waybar.sh" >/dev/null 2>&1 &
    first=$!
    reconcile_call DP-1 "$state" "$FIXTURE_DIR/fake-waybar.sh" >/dev/null 2>&1 &
    second=$!
    wait "$first"
    first_status=$?
    wait "$second"
    second_status=$?
    new_pid=$(state_value pid "$state" 2>/dev/null || :)
    starts=$(grep -c '^start:DP-1$' "$log" 2>/dev/null || true)
    if [ "$first_status" -eq 0 ] && [ "$second_status" -eq 0 ] && [ "$starts" -eq 1 ] && [ -n "$new_pid" ] && kill -0 "$new_pid" 2>/dev/null; then
        remember_pid "$new_pid"
        pass 'serializes concurrent callbacks to one owned Waybar'
    else
        [ "$new_pid" ] && remember_pid "$new_pid"
        fail "serializes concurrent callbacks to one owned Waybar (statuses $first_status/$second_status, starts $starts, pid $new_pid)"
    fi
}

run_unchanged_selection_test
run_changed_selection_test
run_stale_and_unowned_state_test
run_timeout_escalation_test
run_concurrent_reconcile_test

assert_event_status hyprland.start 0 'reselects at Hyprland startup'
assert_event_status monitor.added 0 'reselects on monitor.added'
assert_event_status monitor.removed 0 'reselects on monitor.removed'
assert_event_status workspace 1 'does not reselect on workspace events'
assert_event_status workspacev2 1 'does not reselect on workspacev2 events'
assert_event_status activewindow 1 'does not reselect on activewindow events'
assert_event_status openwindow 1 'does not reselect on openwindow events'
assert_event_status closewindow 1 'does not reselect on closewindow events'

printf '\n%d passed, %d failed\n' "$PASS_COUNT" "$FAIL_COUNT"
[ "$FAIL_COUNT" -eq 0 ]
