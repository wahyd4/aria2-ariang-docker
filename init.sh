#! /bin/bash -eu
#

chown -R junv:junv \
         /data \
         /app \
         /usr/local \
         /var/log \
&& chmod +x /app/caddy.sh \
         /app/aria2c.sh \
&& echo "**** give caddy permissions to use low ports ****" \
&& setcap cap_net_bind_service=+ep /usr/local/bin/caddy \
&& "${@-sh}"
