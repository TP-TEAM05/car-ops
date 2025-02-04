#!/bin/bash

# ReCo script to kill all processes

# Kills all ROS processes
kill -9 $(ps -aux | grep ros | awk '{print $2}' | head -6)

# Kills all rpi_controller processes
kill -9 $(ps -aux | grep 'rpi_controller' | awk '{print $2}' | head -3)

# If ros2_ws is running in screen kill the screen
screen -X -S ros2_ws quit
screen -wipe

echo "RECO nodes killed at: $(date)" >>/home/ubuntu/log/reco.log
