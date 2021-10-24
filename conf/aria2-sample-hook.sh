#! /bin/bash -eu

# For more details about how to use this feature, see: https://aria2.github.io/manual/en/html/aria2c.html#event-hook

echo "[INFO] $(date -u +'%Y-%m-%dT%H:%M:%SZ') Aria2 hook triggered with parameters: GID [$1], Files Count: [$2], Files Path: [$3]"
