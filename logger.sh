#!/bin/bash

LOG_FILE="/reco/log/reco.txt"
LAST_LOG="/reco/log/reco_lastlog"
THROTTLE_INTERVAL=60 # seconds

export SENTRY_DSN="https://60b54799df74ddab5585ba77f35f37ab@o4508080703864832.ingest.de.sentry.io/4508363861655632"

# Ensure log file exists
if [ ! -f "$LOG_FILE" ]; then
    touch "$LOG_FILE"
    chmod 666 "$LOG_FILE"
fi

log_message() {
    local message="$1"
    local level="${2:-info}"

    # Check throttle
    local now=$(date +%s)
    local last=$(cat "$LAST_LOG" 2>/dev/null || echo 0)
    if ((now - last < THROTTLE_INTERVAL)); then
        echo "$(date +'%Y-%m-%d %H:%M:%S') - Throttled: $message" >>"$LOG_FILE"
        return
    fi

    echo "$now" >"$LAST_LOG"
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $message" >>"$LOG_FILE"
    SENTRY_DSN="$SENTRY_DSN" sentry-cli send-event --message "$message" --log-level "$level"
}

MESSAGE="$1"
LEVEL="$2"
log_message "$MESSAGE" "$LEVEL"
