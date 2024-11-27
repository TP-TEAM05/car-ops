#!/bin/bash

LOG_DIR="/tmp/reco"
mkdir -pm 777 "$LOG_DIR"

EPOCH=$(date +%s)
LOG_FILE="$LOG_DIR/mount_log_$EPOCH.txt"

export SENTRY_DSN="https://60b54799df74ddab5585ba77f35f37ab@o4508080703864832.ingest.de.sentry.io/4508363861655632"

# Log message
log_message() {
    local message="$1"
    local level="${2:-info}" # Default level is "info"

    # Log locally
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $message" >> "$LOG_FILE"

    sentry-cli send-event --message "$message" --level "$level"
    
}

# Read and log the message from arguments
MESSAGE="$1"
LEVEL="$2"
log_message "$MESSAGE" "$LEVEL"
