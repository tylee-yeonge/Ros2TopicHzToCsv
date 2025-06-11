#!/bin/bash

# === Configuration ===
# Configuration file containing topic arguments
CONFIG_FILE="topic_list.txt"

# Path to the script to be run multiple times
# Ensure this script exists and is executable (e.g., chmod +x topic_logger.sh)
LOGGER_SCRIPT="./topic_logger.sh"

# === Functions ===
load_arguments_from_file() {
    local config_file="$1"
    local -n array_ref=$2
    
    if [ ! -f "$config_file" ]; then
        echo "Error: Configuration file '$config_file' not found."
        echo "Please create the file with the following format:"
        echo "# Comments start with #"
        echo "<topic_name> <message_type>"
        echo ""
        echo "Example:"
        echo "front/scan sensor_msgs/msg/LaserScan"
        echo "rear/scan sensor_msgs/msg/LaserScan"
        exit 1
    fi
    
    # Read file line by line, ignoring comments and empty lines
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip empty lines and comments
        if [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]]; then
            continue
        fi
        
        # Remove leading and trailing whitespace
        line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        # Skip if line is empty after trimming
        if [[ -z "$line" ]]; then
            continue
        fi
        
        # Add to array
        array_ref+=("$line")
    done < "$config_file"
}

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

# Load arguments from configuration file
ARGUMENTS_LIST=()
load_arguments_from_file "$CONFIG_FILE" ARGUMENTS_LIST

# Check if any arguments were loaded
if [ ${#ARGUMENTS_LIST[@]} -eq 0 ]; then
    echo "Warning: No valid topic configurations found in '$CONFIG_FILE'."
    echo "Please check the configuration file format."
    exit 1
fi

echo "Loaded ${#ARGUMENTS_LIST[@]} topic configuration(s) from '$CONFIG_FILE'"

# 추가: 읽은 내용을 출력
echo "=== Configuration Contents ==="
for i in "${!ARGUMENTS_LIST[@]}"; do
    echo "[$((i+1))] ${ARGUMENTS_LIST[i]}"
done
echo "=== End of Configuration ==="
echo ""

echo "Starting multiple instances of '$LOGGER_SCRIPT' in the foreground..."

for args_str in "${ARGUMENTS_LIST[@]}"; do
    # If args_str is empty, just run the script. Otherwise, pass args_str.
    if [ -z "$args_str" ]; then
        echo "Starting $LOGGER_SCRIPT"
        $LOGGER_SCRIPT
    else
        echo "Starting $LOGGER_SCRIPT $args_str"
        # $args_str is intentionally not quoted here to allow word splitting by the shell.
        # If an argument within args_str itself contains spaces and should be treated as a single argument
        # by topic_logger.sh, it should be quoted appropriately within the configuration file.
        $LOGGER_SCRIPT $args_str
    fi
done

echo ""
echo "All foreground tasks completed. This script ('$0') will now exit."
echo "Configuration loaded from: '$CONFIG_FILE'"

