#! /bin/bash -eu

if [ "$RCLONE_CONFIG_BASE64" != "" ]; then
  echo "[INFO] Config Rclone from RCLONE_CONFIG_BASE64 env"
  echo $RCLONE_CONFIG_BASE64 | base64 -d > /app/conf/rclone.conf
  echo "[INFO] Config Rclone from RCLONE_CONFIG_BASE64 completed"
fi

if [ "$ENABLE_RCLONE" = "true" ]; then
  echo "[INFO] Start Rclone, please make sure you can connect to Github website. if not, please set docker env ENABLE_RCLONE=false"
  rclone rcd --rc-web-gui \
    --rc-web-gui-no-open-browser \
    --rc-addr :5572 \
    --rc-user $ARIA2_USER \
    --rc-pass $ARIA2_PWD \
    --cache-dir /app/.cache
else
  echo "[INFO] Skip starting Rclone as it has been disabled"
  sleep 3650d
fi
