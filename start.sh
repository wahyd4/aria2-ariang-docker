#!/bin/bash -eu

# Signal handling is installed before anything else: as PID 1, bash ignores a
# SIGTERM that arrives before the trap exists, which would make `docker stop`
# wait for its timeout. forego (pinned in the Dockerfile) is started as a child
# because it exits 0 whatever happens to its supervised processes, and an
# unexpected exit has to become a non-zero status. SIGTERM/SIGINT are forwarded
# to it, at most once: a second signal makes forego skip its grace period and
# SIGKILL its children, which would defeat the graceful stop.
forego_pid=""
received_signal=""
signal_sent=""

forward_signal() {
  received_signal="true"
  if [[ -z "${signal_sent}" && -n "${forego_pid}" ]]; then
    signal_sent="true"
    kill -TERM "${forego_pid}" 2>/dev/null || true
  fi
}

trap forward_signal TERM INT

export APP_VERSION="$(cat /app/APP_VERSION)"

# Only two combinations are supported: both 0 (run as root without init) and
# both non-zero (drop privileges through init.sh/chpst).
if [[ ! "${PUID:-}" =~ ^[0-9]+$ || ! "${PGID:-}" =~ ^[0-9]+$ ]]; then
  echo "[ERROR] PUID and PGID must both be numeric. Got PUID='${PUID:-}' PGID='${PGID:-}'."
  echo "[ERROR] Supported combinations are PUID=0 and PGID=0 (run as root), or both non-zero (run as user)."
  exit 1
fi

if [[ "${PUID}" == "0" && "${PGID}" == "0" ]]; then
  run_as_root=true
elif [[ "${PUID}" != "0" && "${PGID}" != "0" ]]; then
  run_as_root=false
else
  echo "[ERROR] Unsupported PUID/PGID combination: PUID='${PUID}' PGID='${PGID}'."
  echo "[ERROR] Supported combinations are PUID=0 and PGID=0 (run as root), or both non-zero (run as user)."
  exit 1
fi

# forego exits 0 whatever happens to its supervised processes, so run it as a
# child and turn an unexpected exit into a non-zero status. Poll instead of
# blocking in `wait`: a trapped signal interrupts `wait` and bash would then
# report 128+signal instead of forego's real exit status.
if [[ "${run_as_root}" == "true" ]]; then
  ./forego start &
else
  "$(dirname "$0")/init.sh" chpst -u junv ./forego start &
fi
forego_pid=$!
# A signal that arrived before forego existed was recorded but not forwarded;
# deliver it now (at most once, see forward_signal).
if [[ "${received_signal}" == "true" && -z "${signal_sent}" ]]; then
  signal_sent="true"
  kill -TERM "${forego_pid}" 2>/dev/null || true
fi

forego_status=0
while kill -0 "${forego_pid}" 2>/dev/null; do
  sleep 0.2
done
# bash keeps the exit status of its child until `wait` reports it.
wait "${forego_pid}" || forego_status=$?

# forego shuts down cleanly on the SIGTERM we forward (exit 0). Dying by that
# signal (143/130) means it was stopped before its handler was installed; that
# is still a requested shutdown, not a failure, so report it as 0.
if [[ "${received_signal}" == "true" ]] && (( forego_status == 143 || forego_status == 130 )); then
  forego_status=0
fi

if [[ "${forego_status}" -eq 0 && "${received_signal}" != "true" ]]; then
  echo "[ERROR] A supervised process exited unexpectedly, exiting with status 1."
  exit 1
fi

exit "${forego_status}"
