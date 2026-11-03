#! /bin/bash -eu

if [[ "${ARIA2_SSL:-}" = "true" ]]; then
  echo "[WARN] ARIA2_SSL is deprecated and ignored. Caddy terminates TLS for clients and proxies over plaintext to aria2's localhost RPC, so aria2 must not use TLS itself."
fi

# Point AriaNg at the right RPC port. An empty ARIA2_EXTERNAL_PORT means the app
# is reached on the same port as the page, so derive it from the page URL.
if [[ -n "${ARIA2_EXTERNAL_PORT:-}" ]]; then
  if [[ ! "${ARIA2_EXTERNAL_PORT}" =~ ^[0-9]{1,5}$ ]] \
    || (( 10#${ARIA2_EXTERNAL_PORT} < 1 || 10#${ARIA2_EXTERNAL_PORT} > 65535 )); then
    echo "[ERROR] ARIA2_EXTERNAL_PORT must be a number between 1 and 65535, got '${ARIA2_EXTERNAL_PORT}'."
    exit 1
  fi
  RPC_PORT_EXPRESSION="\"${ARIA2_EXTERNAL_PORT}\""
else
  # location.port is empty on the scheme's default port, so fall back to 443
  # for HTTPS pages (a plain `||80` sends https pages to port 80).
  RPC_PORT_EXPRESSION='(location.port||(location.protocol==="https:"?443:80))'
fi
sed -i 's#rpcPort:"6800"#rpcPort:'"${RPC_PORT_EXPRESSION}"'#g' /usr/local/www/aria2/js/aria-ng*.js

RPC_SECRET_BASE64=$(printf '%s' "${RPC_SECRET:-}" | base64 | tr -d '\n')
sed -i "s|secret:\"\"|secret:\"${RPC_SECRET_BASE64}\"|g" /usr/local/www/aria2/js/aria-ng*.js

ARIA2_CONF="/app/conf/aria2.conf"
ARIA2_CONF_TMP=""
cleanup() {
  if [[ -n "${ARIA2_CONF_TMP}" ]]; then
    rm -f "${ARIA2_CONF_TMP}"
  fi
}
trap cleanup EXIT

if [[ -n "${RPC_SECRET:-}" ]]; then
  if [[ "${RPC_SECRET}" == *$'\n'* || "${RPC_SECRET}" == *$'\r'* ]]; then
    echo "[ERROR] RPC_SECRET must not contain newline characters."
    exit 1
  fi
  # aria2 trims leading/trailing whitespace from a config-file value, so a
  # secret like "abc " would be trimmed to "abc" in aria2 while AriaNg sends
  # the untrimmed value. Reject instead of silently breaking authentication.
  if [[ "${RPC_SECRET}" =~ ^[[:space:]] || "${RPC_SECRET}" =~ [[:space:]]$ ]]; then
    echo "[ERROR] RPC_SECRET must not begin or end with whitespace."
    exit 1
  fi

  # Keep the secret out of the process list: append it to a private copy of the
  # config instead of passing --rpc-secret on the command line. /tmp is tried
  # first so the secret is memory-backed and short-lived; aria2's state volume
  # is the fallback for a read-only root FS.
  write_conf_copy() {
    rm -f "$1"
    (umask 077; cp /app/conf/aria2.conf "$1")
  }
  ARIA2_CONF_TMP="/tmp/aria2.conf"
  if ! write_conf_copy "${ARIA2_CONF_TMP}" 2>/dev/null; then
    rm -f "${ARIA2_CONF_TMP}" 2>/dev/null || true
    ARIA2_CONF_TMP="/app/.cache/aria2.conf"
    if ! write_conf_copy "${ARIA2_CONF_TMP}"; then
      echo "[ERROR] Cannot write the aria2 config copy to /tmp or /app/.cache."
      exit 1
    fi
  fi
  # umask 077 already created it 0600; this is a best-effort second attempt on
  # filesystems that ignore umask or reject chmod (SMB/CIFS, some NFS).
  chmod 600 "${ARIA2_CONF_TMP}" 2>/dev/null || true
  # A leading newline terminates a final line that has no trailing newline in a
  # user-supplied aria2.conf; otherwise "rpc-secret=..." would be glued onto it.
  printf '\nrpc-secret=%s\n' "${RPC_SECRET}" >> "${ARIA2_CONF_TMP}"
  ARIA2_CONF="${ARIA2_CONF_TMP}"
  echo "[INFO] Start aria2 with rpc-secret"
else
  echo "[INFO] Start aria2 with standard mode"
fi

/usr/bin/aria2c --conf-path="${ARIA2_CONF}" --enable-rpc
