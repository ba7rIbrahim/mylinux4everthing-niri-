#!/bin/bash

# Check if the user provided the time argument
if [ -z "$1" ]; then
  echo "Usage: ./minecraft_timer.sh <minutes>"
  echo "Example: ./minecraft_timer.sh 60"
  exit 1
fi

MINUTES=$1
# Calculate wait time (Total minutes minus 1 minute for the warning)
WAIT_TIME=$(((MINUTES - 1) * 60))

# Display start message in terminal
START_TIME=$(date +"%H:%M")
EXIT_TIME=$(date -d "+$MINUTES minutes" +"%H:%M")
echo "Timer started at: $START_TIME"
echo "Game will close at: $EXIT_TIME"

# Wait until 1 minute remains
sleep $WAIT_TIME

# Send notification 1 minute before closing
notify-send "تنبيه الوقت" "تبقى دقيقة واحدة للعب، سيتم إغلاق اللعبة قريباً!" -u critical -i clock

# Wait for the final 60 seconds
sleep 60

# Force close Minecraft (Java process)
pkill -9 java

# Send final notification
notify-send "انتهى الوقت" "تم إغلاق اللعبة للحفاظ على وقتك." -i dialog-information
