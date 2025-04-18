#!/bin/bash

# Run ROS2 nodes necessary for ReCo automotive
# Usage: ./reco-run.sh <backend_ip> <backend_port> [-v]
# If -v is specified, the output of programs is printed to the console

source /opt/ros/humble/setup.bash
source /home/ubuntu/ros2_ws/install/setup.bash

#######################################
# Function to capture stderr lines and forward them to logger.sh as errors
# Usage:    some_command 2> >(log_errors "tag_for_logger")
# The function name is arbitrary; call it whatever you like.
#######################################
log_errors() {
    local TAG="$1"
    while IFS= read -r line; do
        /usr/local/bin/logger.sh "[ROS2] ${TAG} ERROR: $line" "error"
    done
}

verbose=1 # Default: not verbose

# Set and export the ROS_DOMAIN_ID using the value from "id"

# First try to read from /home/ubuntu/ros_domain_id
if [ -f /home/ubuntu/ros_domain_id ]; then
    ROS_DOMAIN_ID=$(cat /home/ubuntu/ros_domain_id)
else
    # If the file does not exist, use the default value
    ROS_DOMAIN_ID=2
fi

export ROS_DOMAIN_ID
echo "[ROS2] Using ROS_DOMAIN_ID=${ROS_DOMAIN_ID}" >>/reco/log/reco-run.log

echo "Starting ROS2 nodes at: $(date)" >>/reco/log/reco-run.log

if [ "$verbose" -eq 1 ]; then
    # Verbose is ON => print stdout to console; only errors go to logger
    /opt/ros/humble/bin/ros2 run car_to_backend serial_pub &
    echo "[ROS2] serial_pub --> started"

    # Start gps_pub
    /opt/ros/humble/bin/ros2 run car_to_backend gps_pub &
    echo "[ROS2] gps_pub --> started"

    # Start udp_sub
    /opt/ros/humble/bin/ros2 run car_to_backend udp_sub &
    echo "[ROS2] udp_sub --> started"

    # Start udp_pub
    /opt/ros/humble/bin/ros2 run car_to_backend udp_pub &
    echo "[ROS2] udp_pub --> started"

    # Start car_controls
    /opt/ros/humble/bin/ros2 run car_to_backend car_controls &
    echo "[ROS2] car_controls --> started"

    # Start rpi_controller_pid.py
    python3 /home/ubuntu/rpi_controller_pid.py &
    echo "[ROS2] rpi_controller_pid.py --> started"

else
    # Verbose is OFF => send stdout to /dev/null; errors still go to logger
    /opt/ros/humble/bin/ros2 run car_to_backend serial_pub \
        1>/dev/null 2> >(log_errors "serial_pub") &
    echo "[ROS2] serial_pub --> started"

    /opt/ros/humble/bin/ros2 run car_to_backend gps_pub \
        1>/dev/null 2> >(log_errors "gps_pub") &
    echo "[ROS2] gps_pub --> started"

    /opt/ros/humble/bin/ros2 run car_to_backend udp_sub \
        1>/dev/null 2> >(log_errors "udp_sub") &
    echo "[ROS2] udp_sub --> started"

    /opt/ros/humble/bin/ros2 run car_to_backend udp_pub \
        1>/dev/null 2> >(log_errors "udp_pub") &
    echo "[ROS2] udp_pub --> started"

    /opt/ros/humble/bin/ros2 run car_to_backend car_controls \
        1>/dev/null 2> >(log_errors "car_controls") &
    echo "[ROS2] car_controls --> started"

    python3 /home/ubuntu/rpi_controller_pid.py \
        1>/dev/null 2> >(log_errors "rpi_controller_pid.py") &
    echo "[ROS2] rpi_controller_pid.py --> started"

fi

echo "RECO nodes started at: $(date)" >>/reco/log/reco-run.log
