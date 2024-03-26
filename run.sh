#!/bin/bash

# Buffer time for system boot
sleep 30


# Configure global variables
MAX_RETRIES=10
RETRY_COUNT=0

STORE_DIR="/home/path/to/"

DAY_OF_STORAGE=2
MAX_STORAGE_VOLUME=100

# Function to mount Google Drive
mount_drive() {
    rclone mount --daemon --vfs-cache-mode full rasfeed:RasFeed /home/pii/rasfeed/ >> /home/pii/rclone_mount.log 2>&1
}

# Attempt to mount Google Drive
mount_drive

# Check if mount was successful
while [ $? -ne 0 ]; do
    RETRY_COUNT=$((RETRY_COUNT + 1))
    
    if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
        echo "Max retries reached. Exiting..."
        exit 1
    fi
    
    echo "Mount attempt $RETRY_COUNT failed. Retrying in 60 seconds..."
    sleep 60
    
    # Attempt to mount Google Drive again
    mount_drive
done

echo "Google Drive successfully mounted."

sleep 10
while true; do

    # Getting current date and time
    CURRENT_DATE=$(date +"%Y%m%d.%H%M%S")

    # Takeing picture and saving to drive
    ffmpeg -hide_banner -loglevel panic -f v4l2 -video_size 1920x1080 -i /dev/video0 -frames 1 path/to/image"$CURRENT_DATE".jpg
    sleep 10
done