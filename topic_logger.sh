#!/bin/bash
TOPIC_NAME=$1
MESSAGE_TYPE=$2

CURRENT_TIME=$(date +%Y-%m-%d_%H-%M-%S)

echo "Topic Name: $TOPIC_NAME"
echo "Message Type: $MESSAGE_TYPE"
echo "Current Time: $CURRENT_TIME"

python3 TopicHzToCsv.py --ros-args -p topic_name:=/$TOPIC_NAME -p message_type:=$MESSAGE_TYPE -p csv_filename:="$TOPIC_NAME-$CURRENT_TIME.csv" -p window_size:=20