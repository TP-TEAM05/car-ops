#!/bin/bash

LOCKFILE="/reco/run/reco_config_monitor.lock"

# Check if the lock file exists
if [ -f "$LOCKFILE" ]; then
    /usr/local/bin/logger.sh "Script already executed. Remove /reco/run/reco_config_monitor.lock to run ReCo config service." "error"
   exit 0
fi

# Check if something is mounted at /media/RECO_CONFIG
if mountpoint -q /media/RECO_CONFIG; then
    # Create lockfile
    touch "$LOCKFILE"
    /usr/local/bin/logger.sh "Config script started running. Please wait for success message" "info"
    # Run the pipeline
    cd /home/ubuntu/car-ops/pypyr
    pypyr default
else
    /usr/local/bin/logger.sh "/media/RECO_CONFIG is not a mount point." "error"
fi
