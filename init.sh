#! /bin/bash -eu

# PUID/PGID must be consistent (same rules as start.sh). init.sh is the
# non-root path, so both values must be non-zero here.
if [[ ! "${PUID:-}" =~ ^[0-9]+$ || ! "${PGID:-}" =~ ^[0-9]+$ ]]; then
  echo "[ERROR] PUID and PGID must both be numeric. Got PUID='${PUID:-}' PGID='${PGID:-}'."
  echo "[ERROR] Supported combinations are PUID=0 and PGID=0 (run as root), or both non-zero (run as user)."
  exit 1
fi

if [[ "${PUID}" == "0" || "${PGID}" == "0" ]]; then
  echo "[ERROR] Unsupported PUID/PGID combination: PUID='${PUID}' PGID='${PGID}'."
  echo "[ERROR] Supported combinations are PUID=0 and PGID=0 (run as root), or both non-zero (run as user)."
  exit 1
fi

echo "[INFO] Update uid and gid to ${PUID}:${PGID}"
groupmod -o -g "$PGID" junv
usermod -o -u "$PUID" junv

mkdir -p /app/.caddy
mkdir -p /app/.cache
mkdir -p /app/.cache/aria2

echo "[INFO] Run chown against app related folders and user ${PUID}"

chown -R junv:junv \
         /app/.caddy \
         /app/.cache \
         /usr/local/www \
         /var/log

# /app/conf is usually a bind mount and may be read-only, so skip it in the
# recursive chown above and handle it separately without ever failing hard.
for path in /app/*; do
  if [[ "${path}" != "/app/conf" ]]; then
    chown -Rh junv:junv "${path}"
  fi
done
chown junv:junv /app

if ! (umask 077; : > /app/conf/.aria2-write-test) 2>/dev/null; then
  conf_read_only=true
  echo "[WARN] /app/conf is not writable (read-only mount?). aria2 will not be able to save its session to /app/conf/aria2.session."
else
  conf_read_only=false
  rm -f /app/conf/.aria2-write-test
fi

if ! chown -Rh junv:junv /app/conf 2>/dev/null; then
  if [[ "${conf_read_only}" != "true" ]]; then
    echo "[WARN] Could not change ownership of /app/conf. Continuing."
  fi
fi

if [[ "${FIX_DATA_VOLUME_PERMISSIONS:-false}" = "true" ]]; then
  echo "[INFO] Setup user ${PUID} proper permissions for /data"
  chown -R junv:junv /data
fi

# Warn (never exit) when junv cannot write to /data: macOS bind mounts can still
# be writable through a different mapping, so failing here would break them.
if [[ "${FIX_DATA_VOLUME_PERMISSIONS:-false}" != "true" ]]; then
  if ! chpst -u junv test -w /data 2>/dev/null; then
    echo "[WARN] /data is not writable by user junv (PUID=${PUID}, PGID=${PGID}); downloads will fail."
    echo "[WARN] Fix it by setting FIX_DATA_VOLUME_PERMISSIONS=true, or by aligning PUID/PGID with the owner of /data."
  fi
fi

chmod +x /app/caddy.sh \
         /app/rclone.sh \
         /app/aria2c.sh \
         /app/filebrowser.sh

echo "[INFO] Give caddy permissions to use low ports"
setcap cap_net_bind_service=+ep /usr/local/bin/caddy

# exec, so the process start.sh tracks (and signals) becomes forego itself
# rather than this wrapper script.
exec "${@-sh}"
