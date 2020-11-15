#! /bin/bash -eu

echo "Run aria2c and ariaNG"
if [ "$ENABLE_AUTH" = "true" ]; then
  echo "Using Basic Auth config file "
  export CADDY_FILE=/usr/local/caddy/SecureCaddyfile

  echo "**** generate basic auth password for caddy ****"
  ARIA2_PWD_ENCRYPT=`caddy hash-password -plaintext ${ARIA2_PWD}`
  sed -i 's/ARIA2_USER/'"${ARIA2_USER}"'/g' /usr/local/caddy/SecureCaddyfile
  sed -i 's/ARIA2_PWD_ENCRYPT/'"${ARIA2_PWD_ENCRYPT}"'/g' /usr/local/caddy/SecureCaddyfile
else
  echo "Using caddy without Basic Auth"
  export CADDY_FILE=/usr/local/caddy/Caddyfile
fi

/usr/local/bin/caddy run -config ${CADDY_FILE} -adapter=caddyfile
