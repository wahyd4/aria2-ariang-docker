#! /bin/bash -eu

echo "[INFO] Run aria2c and ariaNG"

hash_password() {
  if [[ -z "${ARIA2_PWD}" ]]; then
    echo "[ERROR] ENABLE_AUTH is enabled but ARIA2_PWD is empty."
    exit 1
  fi
  if [[ "${ARIA2_PWD}" = "password" ]]; then
    echo "[WARN] ARIA2_PWD is still the default 'password'. Set a strong password before exposing this service."
  fi
  echo "[INFO] Generate basic auth password for caddy"
  # Read the password from stdin so it does not show up in the process list.
  ARIA2_PWD_ENCRYPT=$(printf '%s\n' "${ARIA2_PWD}" | caddy hash-password)
  export ARIA2_PWD_ENCRYPT
}

case "${ENABLE_AUTH}" in
true)
  echo "[INFO] Use Basic Auth config file "
  hash_password
  CADDY_FILE=/usr/local/caddy/SecureCaddyfile
  ;;

heroku)
  echo "[INFO] Run Caddy with Heroku mode"
  hash_password
  CADDY_FILE=/usr/local/caddy/HerokuCaddyfile
  ;;

false)
  echo "[INFO] Use caddy without Basic Auth"
  CADDY_FILE=/usr/local/caddy/Caddyfile
  ;;

*)
  echo "[ERROR] Invalid ENABLE_AUTH value '${ENABLE_AUTH}'. Expected 'true', 'false' or 'heroku'."
  exit 1
  ;;
esac

/usr/local/bin/caddy run --config "${CADDY_FILE}" --adapter=caddyfile
