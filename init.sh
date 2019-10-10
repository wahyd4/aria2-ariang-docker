#! /bin/bash -eu

echo "**** update uid and gid to ${PUID}:${PGID} ****"
groupmod -o -g "$PGID" junv
usermod -o -u "$PUID" junv

chown -R junv:junv \
         /app \
         /usr/local \
         /var/log \
         /data

chmod +x /app/caddy.sh \
         /app/aria2c.sh

echo "**** give caddy permissions to use low ports ****"
setcap cap_net_bind_service=+ep /usr/local/bin/caddy

"${@-sh}"
