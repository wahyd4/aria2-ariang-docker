#! /bin/bash -eu

if [ "${RCLONE_CONFIG_BASE64}" != "" ]; then
  echo "[INFO] Config Rclone from RCLONE_CONFIG_BASE64 env"
  umask 077
  printf '%s' "${RCLONE_CONFIG_BASE64}" | base64 -d > /app/conf/rclone.conf
  chmod 600 /app/conf/rclone.conf
  echo "[INFO] Config Rclone from RCLONE_CONFIG_BASE64 completed"
fi

if [ "${ENABLE_RCLONE}" = "true" ]; then
  echo "[INFO] Start Rclone, please make sure you can connect to Github website. if not, please set docker env ENABLE_RCLONE=false"
  # Keep the GUI credentials out of the process list; rclone reads these
  # environment variables as defaults for --rc-user/--rc-pass.
  export RCLONE_RC_USER="${ARIA2_USER}"
  export RCLONE_RC_PASS="${ARIA2_PWD}"
  rclone rcd --rc-web-gui \
    --rc-web-gui-no-open-browser \
    --rc-addr 127.0.0.1:5572 \
    --cache-dir /app/.cache
else
  echo "[INFO] Skip starting Rclone as it has been disabled"
  sleep 3650d
fi
