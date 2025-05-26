#!/bin/bash

# === Configuration ===
# List of arguments for each instance of topic_logger.sh
# Each item in the array is a string of arguments.
# If topic_logger.sh takes no arguments, you can leave the strings empty or use a different loop structure.

# Example: If topic_logger.sh takes a topic name and an output file:
#   ARGUMENTS_LIST=(
#       "/topic1 /output/log1.csv"
#       "/topic2 /output/log2.csv"
#       "/another_topic /output/log3.csv"
#   )
# Example: If topic_logger.sh takes only a topic name:
#   ARGUMENTS_LIST=(
#       "/topic1"
#       "/topic2"
#       "/topic3"
#   )
# Example: If topic_logger.sh takes no arguments, but you want to run 3 instances:
# You can define it like this, and the script will run ./topic_logger.sh (with no args) for each item.
#   ARGUMENTS_LIST=(
#       "" # Instance 1
#       "" # Instance 2
#       "" # Instance 3
#   )
# Or, for a fixed number of instances with no specific args, see alternative loop commented out below.

ARGUMENTS_LIST=(
    "front/scan sensor_msgs/msg/LaserScan"
    "rear/scan sensor_msgs/msg/LaserScan"
    "safety_plc/get/obstacle_zone_shape std_msgs/msg/UInt8"
    "rs_camera_1/depth/image_rect_raw sensor_msgs/msg/Image"    
    "rs_camera_2/color/image_raw sensor_msgs/msg/Image"
    "rs_camera_3/depth/image_rect_raw sensor_msgs/msg/Image"
    "rs_camera_4/color/image_raw sensor_msgs/msg/Image"
    "rs_camera_5/color/image_raw sensor_msgs/msg/Image"
    "front_md/postion_feedback accessories_msgs/msg/RoboteqPostionFeedback"
    "rear_md/postion_feedback accessories_msgs/msg/RoboteqPostionFeedback"
)

# Path to the script to be run multiple times
# Ensure this script exists and is executable (e.g., chmod +x topic_logger.sh)
LOGGER_SCRIPT="./topic_logger.sh"

# === Script Logic ===

# Check if the logger script exists
if [ ! -f "$LOGGER_SCRIPT" ]; then
    echo "Error: Logger script '$LOGGER_SCRIPT' not found."
    echo "Please ensure it is in the correct path."
    exit 1
fi

# Check if the logger script is executable
if [ ! -x "$LOGGER_SCRIPT" ]; then
    echo "Error: Logger script '$LOGGER_SCRIPT' is not executable."
    echo "Please run 'chmod +x $LOGGER_SCRIPT' to make it executable."
    exit 1
fi

echo "Starting multiple instances of '$LOGGER_SCRIPT' in the background..."

PIDS=() # Array to store Process IDs

for args_str in "${ARGUMENTS_LIST[@]}"; do
    # If args_str is empty, just run the script. Otherwise, pass args_str.
    if [ -z "$args_str" ]; then
        echo "Starting $LOGGER_SCRIPT"
        $LOGGER_SCRIPT &
    else
        echo "Starting $LOGGER_SCRIPT $args_str"
        # $args_str is intentionally not quoted here to allow word splitting by the shell.
        # If an argument within args_str itself contains spaces and should be treated as a single argument
        # by topic_logger.sh, it should be quoted appropriately within the ARGUMENTS_LIST.
        # e.g., ARGUMENTS_LIST=("\"/path with spaces/datafile\" --option value" "another_config")
        $LOGGER_SCRIPT $args_str &
    fi
    PIDS+=($!) # Store the PID of the last backgrounded process
done

if [ ${#PIDS[@]} -eq 0 ]; then
    echo "No instances were configured to start in ARGUMENTS_LIST."
    echo "Please check the ARGUMENTS_LIST array in the script."
else
    echo ""
    echo "${#PIDS[@]} instance(s) of '$LOGGER_SCRIPT' started."
    echo "PIDs: ${PIDS[@]}"
    echo ""
    echo "To stop these specific instances, you can use: kill ${PIDS[@]}"
    echo "To stop all instances of '$LOGGER_SCRIPT' (more general, use with caution): pkill -f '$LOGGER_SCRIPT'"
    echo "(pkill might affect other scripts if '$LOGGER_SCRIPT' is a common name)"
fi

# --- Alternative loop structure ---
# If you simply want to run a fixed number of instances of topic_logger.sh,
# and topic_logger.sh does not require different arguments for each instance (or takes no arguments),
# you can use a loop like this. Comment out the ARGUMENTS_LIST and the loop above if you use this.
#
# NUM_INSTANCES=3 # Define how many instances to run
# LOGGER_ARGS="" # Define any common arguments here, or leave empty if none
#
# echo "Starting $NUM_INSTANCES instances of $LOGGER_SCRIPT (alternative method)..."
# ALT_PIDS=()
# for i in $(seq 1 $NUM_INSTANCES)
# do
#     instance_specific_arg="instance_${i}" # Example: create a unique ID or log file name
#     echo "Starting $LOGGER_SCRIPT $LOGGER_ARGS $instance_specific_arg (instance $i)"
#     # Modify how arguments are passed as needed
#     $LOGGER_SCRIPT $LOGGER_ARGS $instance_specific_arg &
#     ALT_PIDS+=($!)
# done
#
# if [ ${#ALT_PIDS[@]} -gt 0 ]; then
#   echo ""
#   echo "PIDs (alternative method): ${ALT_PIDS[@]}"
#   echo "To stop these: kill ${ALT_PIDS[@]}"
# fi
# --- End of alternative loop structure ---

echo ""
echo "All background tasks launched. This script ('$0') will now exit."
echo "The '$LOGGER_SCRIPT' instances will continue to run in the background."

