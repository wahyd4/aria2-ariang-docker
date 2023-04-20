#! /bin/bash -eu

echo "[INFO] Update uid and gid to ${PUID}:${PGID}"
groupmod -o -g "$PGID" junv
usermod -o -u "$PUID" junv

mkdir -p /app/.caddy
mkdir -p /app/.cache
mkdir -p /app/.cache/aria2

echo "[INFO] Run chown against app related folders and user ${PUID}"

chown -R junv:junv \
         /app \
         /app/.caddy \
         /app/.cache \
         /usr/local \
         /var/log

if [[ "${FIX_DATA_VOLUME_PERMISSIONS}" = "true" ]]; then
  echo "[INFO] Setup user ${PUID} proper permissions for /data"
  chown -R junv:junv /data
fi

chmod +x /app/caddy.sh \
         /app/rclone.sh \
         /app/aria2c.sh

echo "[INFO] Give caddy permissions to use low ports"
setcap cap_net_bind_service=+ep /usr/local/bin/caddy

"${@-sh}"
