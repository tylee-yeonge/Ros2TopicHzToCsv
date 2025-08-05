#!/bin/bash
TOPIC_NAME=$1
TOPIC_NAME_FOR_FILENAME=${TOPIC_NAME//\//-}
MESSAGE_TYPE=$2
RELIABILITY=$3
CURRENT_DIR=$(pwd)
CURRENT_TIME=$(date +%Y-%m-%d_%H-%M-%S)
CURRENT_DATE=$(date +%Y-%m-%d)
mkdir -p $CURRENT_DIR/$CURRENT_DATE

echo "Topic Name: $TOPIC_NAME"
echo "Message Type: $MESSAGE_TYPE"
echo "Current Time: $CURRENT_TIME"
echo "Reliability: $RELIABILITY"

python3 TopicHzToCsv.py --ros-args -p topic_name:=/$TOPIC_NAME -p message_type:=$MESSAGE_TYPE -p csv_filename:="$CURRENT_DIR/$CURRENT_DATE/$TOPIC_NAME_FOR_FILENAME-$CURRENT_TIME.csv" -p window_size:=20 -p reliability:=$RELIABILITY