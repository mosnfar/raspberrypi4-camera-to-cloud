#!/bin/bash

# Buffer time for system boot
sleep 30


# Configure global variables
MAX_RETRIES=10
RETRY_COUNT=0

DRIVE_ADD="drive:directory/subdirectory"

STORE_DIR="/home/path/to/"
LOG_DIR="/home/path/for/log/"

CAMERA_ADD="/dev/video0"

DAY_OF_STORAGE=2 #Maximum date for storage - e.g. 2 days
MAX_STORAGE_SIZE=200000000 #Maximum size for storage - e.g. 200000000 Byte -> 200 MB

INTERVAL_DELAY=10 #Interval between taking frames - e.g. 10 seconds

# Function to mount Google Drive
mount_drive() {
    rclone mount --daemon --vfs-cache-mode full "$DRIVE_ADD" "$STORE_DIR" >> "$LOG_DIR"rclone_mount.log 2>&1
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

# Function for check the directory total size

calculate_dir_size() {
    local directory="$1"
    local total_size=$(du -sb "$directory" | awk '{print $1}')
    echo "$total_size"
}

check_dir_size() {
    local directory="$1"
    local max_size="$2"
    local total_size=$(calculate_dir_size "$directory")
    if [ "$total_size" -lt "$max_size" ]; then
        return 0
    else
        return 1
    fi
}

average_file_size() {
    local directory="$1"
    local file_count=$(find "$directory" -type f | wc -l)
    if [ "$file_count" -gt 0 ]; then
        local total_size=$(calculate_dir_size "$directory")
        local average_size=$((total_size / file_count))
        echo "$average_size"
    else
        echo "0"
    fi
}

remove_old_files() {
    local directory="$1"
    local max_size="$2"
    local cutoff="$3"
    
    # Calculate the average file size
    local average_size=$(average_file_size "$directory")

    # Calculate the new maximum size
    local new_max_size=$((max_size - 2 * average_size))
    
    # Ensure the new maximum size is positive
    if [ "$new_max_size" -lt 0 ]; then
        echo "Error: Average file size is too large relative to the maximum size."
        return
    fi
    
    # Find and remove old files with cutoff
    find "$directory" -mtime +$cutoff | xargs rm

    while ! check_dir_size "$directory" "$new_max_size"; do
        # Find the oldest file in the directory and remove it
        oldest_file=$(find "$directory" -type f -printf '%T+ %p\n' | sort | head -n 1 | awk '{print $2}')
        if [ -n "$oldest_file" ]; then
            echo "Removing file: $oldest_file"
            rm "$oldest_file"
        else
            echo "No more files to remove."
            break
        fi
    done
}


sleep $INTERVAL_DELAY
while true; do

    if check_dir_size "$STORE_DIR" "$MAX_STORAGE_SIZE"; then
        remove_old_files
    else
        # Getting current date and time
        CURRENT_DATE=$(date +"%Y%m%d.%H%M%S")

        # Takeing picture and saving to drive
        ffmpeg -hide_banner -loglevel panic -f v4l2 -video_size 1920x1080 -i "$CAMERA_ADD" -frames 1 "${STORE_DIR}image${CURRENT_DATE}.jpg"
        sleep 10
    fi

done