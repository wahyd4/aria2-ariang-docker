#! /bin/bash -eu

echo "[INFO] Run aria2c and ariaNG"

echo "[INFO] Generate basic auth password for caddy"
ARIA2_PWD_ENCRYPT=$(caddy hash-password --plaintext ${ARIA2_PWD})

case $ENABLE_AUTH in
true)
  echo "[INFO] Use Basic Auth config file "
  export CADDY_FILE=/usr/local/caddy/SecureCaddyfile
  sed -i "s#ARIA2_USER#${ARIA2_USER}#g" ${CADDY_FILE}
  sed -i "s#ARIA2_PWD_ENCRYPT#${ARIA2_PWD_ENCRYPT}#g" ${CADDY_FILE}
  ;;

heroku)
  echo "[INFO] Run Caddy with Heroku mode"
  export CADDY_FILE=/usr/local/caddy/HerokuCaddyfile
  sed -i "s#ARIA2_USER#${ARIA2_USER}#g" ${CADDY_FILE}
  sed -i "s#ARIA2_PWD_ENCRYPT#${ARIA2_PWD_ENCRYPT}#g" ${CADDY_FILE}

  sed -i 's/PORT/'"${PORT}"'/g' ${CADDY_FILE}

  ;;
*)
  echo "[INFO] Use caddy without Basic Auth"
  export CADDY_FILE=/usr/local/caddy/Caddyfile
  ;;
esac

/usr/local/bin/caddy run --config ${CADDY_FILE} --adapter=caddyfile
