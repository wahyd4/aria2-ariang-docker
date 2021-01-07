#! /bin/bash -eu

if [ "$ENABLE_RCLONE" = "true" ]; then
  echo "Start Rclone, please make sure you can connect to Github website. if not, please set docker env ENABLE_RCLONE=false"
  rclone rcd --rc-web-gui \
    --rc-web-gui-no-open-browser \
    --rc-addr :5572 \
    --rc-user $ARIA2_USER \
    --rc-pass $ARIA2_PWD \
    --cache-dir /app/.cache
else
  echo "Skip starting Rclone as it's been disabled"
  sleep 3650d
fi
