#!/bin/bash

MOUNT_POINT="/media/RECO_CONFIG"

# Ensure the mount point exists
mkdir -p "$MOUNT_POINT"

# Get the device name from udev
DEVICE=$1

# Function to log messages asynchronously
log_async() {
    local message="$1"
    local level="${2:-info}" # Default level is "info"

    # Run logger in a separate shell
    /usr/local/bin/logger.sh "$message" "$level" &
}

# Check if the label is RECO_CONFIG
LABEL=$(blkid -o value -s LABEL "$DEVICE")
if [ "$LABEL" == "RECO_CONFIG" ]; then
    log_async "Mounting USB drive with label RECO_CONFIG..."

    # Start the mount process
    /usr/bin/systemd-mount --no-block --automount=yes \
        -o gid=$(getent group usbmount | awk -F: '{print $3}'),umask=000 --collect "$DEVICE" "$MOUNT_POINT"

    # Poll the mount point to verify success
    
else
    log_async "USB drive label does not match RECO_CONFIG. Skipping." "warning"
fi
