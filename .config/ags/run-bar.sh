#!/bin/bash

LOGFILE="$HOME/.config/ags/crash.log"
INSTANCE="bar"

# Self-detach from controlling terminal if attached
if [[ -t 0 || -t 1 || -t 2 ]]; then
    exec setsid -f "$0" "$@" >/dev/null 2>&1 < /dev/null
fi

# Refuse to start if the instance is already running.
if pgrep -af "ags run" | grep -q "bar.tsx"; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] AGS bar already running, exiting watchdog." >> "$LOGFILE"
    exit 0
fi

while true; do
    echo "========================================" >> "$LOGFILE"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting AGS bar (instance=$INSTANCE)" >> "$LOGFILE"
    echo "========================================" >> "$LOGFILE"

    ags run ~/.config/ags/bar.tsx >> "$LOGFILE" 2>&1

    EXIT_CODE=$?
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] AGS exited with code: $EXIT_CODE" >> "$LOGFILE"
    echo "" >> "$LOGFILE"

    if [[ $EXIT_CODE -eq 0 || $EXIT_CODE -eq 130 || $EXIT_CODE -eq 143 ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Clean exit, not restarting" >> "$LOGFILE"
        break
    fi

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Crash detected, restarting in 2 seconds..." >> "$LOGFILE"
    sleep 2
done
