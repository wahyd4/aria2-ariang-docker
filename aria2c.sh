#! /bin/bash -eu

sed -i 's/6800/'"${ARIA2_EXTERNAL_PORT}"'/g' /usr/local/www/aria2/js/aria-ng*.js
RPC_SECRET_BASE64=$(echo -n ${RPC_SECRET} | base64)
sed -i 's/secret:\"\"/secret:\"'"${RPC_SECRET_BASE64}"'\"/g' /usr/local/www/aria2/js/aria-ng*.js

if [[ "${ARIA2_SSL}" = "true" ]]; then
  echo "[INFO] Start aria2 with secure config and rpc-secret"

  /usr/bin/aria2c --conf-path="/app/conf/aria2.conf" \
    --enable-rpc --rpc-listen-all \
    --rpc-certificate=/app/conf/key/aria2.crt \
    --rpc-private-key=/app/conf/key/aria2.key \
    --rpc-secret="${RPC_SECRET}" --rpc-secure

elif [[ "${ARIA2_SSL}" = "false" ]] && [[ "${RPC_SECRET}" != "" ]]; then
  echo "[INFO] Start aria2 with rpc-secret"
  /usr/bin/aria2c --conf-path="/app/conf/aria2.conf" \
    --enable-rpc \
    --rpc-listen-all \
    --rpc-secret="${RPC_SECRET}"
else
  echo "[INFO] Start aria2 with standard mode"
  /usr/bin/aria2c --conf-path="/app/conf/aria2.conf" --enable-rpc --rpc-listen-all

fi
