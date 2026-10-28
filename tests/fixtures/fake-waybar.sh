#!/usr/bin/env bash
set -u

role=${WAYBAR_TEST_ROLE:-replacement}
output=${1-}
log=${WAYBAR_TEST_ACTION_LOG:?WAYBAR_TEST_ACTION_LOG is required}
unrelated_log=${WAYBAR_TEST_UNRELATED_LOG:-}

if [ -n "${WAYBAR_TEST_PID_FILE:-}" ]; then
    printf '%s\n' "$$" > "$WAYBAR_TEST_PID_FILE"
fi

case "$role" in
    old|unrelated)
        printf '%s-start:%s\n' "$role" "$output" >> "$log"
        [ "$role" != unrelated ] || [ -z "$unrelated_log" ] || printf '%s-start:%s\n' "$role" "$output" >> "$unrelated_log"
        trap 'printf "%s-exit:%s\n" "$role" "$output" >> "$log"; exit 0' TERM INT
        while :; do sleep 0.02; done
        ;;
    stubborn)
        printf '%s-start:%s\n' "$role" "$output" >> "$log"
        trap ':' TERM INT
        while :; do read -r -t 1 _ || :; done
        ;;
    *)
        printf 'start:%s\n' "$output" >> "$log"
        trap 'exit 0' TERM INT
        while :; do sleep 0.02; done
        ;;
esac
