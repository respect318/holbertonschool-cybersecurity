#!/bin/bash

# Ensure script is run with root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (use sudo)"
  exit 1
fi

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <create|open|close> [args...]"
    exit 1
fi

MODE="$1"

case "$MODE" in
    create)
        if [ "$#" -ne 3 ]; then
            echo "Usage: $0 create <file_path> <size_in_MB>"
            exit 1
        fi
        FILE_PATH="$2"
        SIZE_MB="$3"
        
        echo "Creating virtual disk of ${SIZE_MB}MB..."
        dd if=/dev/zero of="$FILE_PATH" bs=1M count="$SIZE_MB"
        
        echo "Formatting with LUKS..."
        cryptsetup luksFormat "$FILE_PATH"
        ;;
        
    open)
        if [ "$#" -ne 4 ]; then
            echo "Usage: $0 open <file_path> <mapper_name> <mount_point>"
            exit 1
        fi
        FILE_PATH="$2"
        MAPPER_NAME="$3"
        MOUNT_POINT="$4"
        
        echo "Opening LUKS volume..."
        cryptsetup luksOpen "$FILE_PATH" "$MAPPER_NAME"
        
        # Check if it has a filesystem, if not, create it
        FS_TYPE=$(blkid -o value -s TYPE /dev/mapper/"$MAPPER_NAME")
        if [ -z "$FS_TYPE" ]; then
            echo "No filesystem found. Creating ext4 filesystem..."
            mkfs.ext4 /dev/mapper/"$MAPPER_NAME"
        fi
        
        echo "Mounting volume..."
        mkdir -p "$MOUNT_POINT"
        mount /dev/mapper/"$MAPPER_NAME" "$MOUNT_POINT"
        echo "Volume mounted at $MOUNT_POINT"
        ;;
        
    close)
        if [ "$#" -ne 3 ]; then
            echo "Usage: $0 close <mapper_name> <mount_point>"
            exit 1
        fi
        MAPPER_NAME="$2"
        MOUNT_POINT="$3"
        
        echo "Unmounting volume..."
        umount "$MOUNT_POINT"
        
        echo "Closing LUKS volume..."
        cryptsetup luksClose "$MAPPER_NAME"
        echo "Volume closed successfully."
        ;;
        
    *)
        echo "Error: Invalid mode. Use 'create', 'open', or 'close'."
        exit 1
        ;;
esac
