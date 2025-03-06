#!/bin/bash -eu

echo "Checking if FileBrowser is enabled..."

if [ "$ENABLE_FILEBROWSER" = "true" ]; then
    echo "Starting FileBrowser..."
    /app/filebrowser -p 8080 -d /app/filebrowser.db -r /data -b /files
else
    echo "FileBrowser is disabled. Set ENABLE_FILEBROWSER=true to enable it."
    sleep 3650d
fi
