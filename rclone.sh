#! /bin/bash -eu

echo "Start Rclone"
rclone rcd --rc-web-gui \
  --rc-web-gui-no-open-browser \
  --rc-addr :5572 \
  --rc-user $ARIA2_USER \
  --rc-pass $ARIA2_PWD
