#!/bin/bash

LOG_DIR="/tmp/reco"
mkdir -pm 777 "$LOG_DIR"

LOG_FILE="$LOG_DIR/log.txt"

export SENTRY_DSN="https://60b54799df74ddab5585ba77f35f37ab@o4508080703864832.ingest.de.sentry.io/4508363861655632"

# Log message
log_message() {
    local message="$1"
    local level="${2:-info}" # Default level is "info"

    # Log locally
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $message" >> "$LOG_FILE"

    SENTRY_DSN="$SENTRY_DSN" sentry-cli send-event --message "$message" --log-level "$level"
    
}

# Read and log the message from arguments
MESSAGE="$1"
LEVEL="$2"
log_message "$MESSAGE" "$LEVEL"
