#!/bin/sh
echo "Run aria2c and ariaNG"
echo $ENABLE_AUTH
if [ "$ENABLE_AUTH" = "true" ]; then
  echo "using basic auth config file "
  CADDY_FILE=/usr/local/caddy/SecureCaddyfile
else
  CADDY_FILE=/usr/local/caddy/Caddyfile
fi

if [ "$SSL" = "true" ]; then
echo "Start aria2 with secure config"

/usr/bin/aria2c --conf-path="/root/conf/aria2.conf" -D  \
--enable-rpc --rpc-listen-all  \
--rpc-certificate=/root/conf/key/aria2.crt \
--rpc-private-key=/root/conf/key/aria2.key \
--rpc-secret="$RPC_SECRET" --rpc-secure \
&& caddy -quic --conf ${CADDY_FILE}

else
echo "Start aria2 with standard mode"
/usr/bin/aria2c --conf-path="/root/conf/aria2.conf" -D \
--enable-rpc --rpc-listen-all \
&& caddy -quic --conf ${CADDY_FILE}
fi


