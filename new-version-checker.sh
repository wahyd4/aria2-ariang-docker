#! /bin/bash -u
sleep 5

if [ "$ENABLE_APP_CHECKER" = "false" ]; then
  echo "[INFO] Skip checking new version"
  # Do nothing and just sleep 10 years
  sleep 315360000
  exit 0
fi

set -e
APP_VERSION=$(cat APP_VERSION)
set +e
while true; do
  echo "[INFO] $(date -u +'%Y-%m-%dT%H:%M:%SZ') Checking for new version against ${APP_VERSION} ..."
  newer_version=$(curl --max-time 6 -fsS "https://badges.toozhao.com/val/aria2-ui-docker?version=${APP_VERSION}&arch=$(arch)")

  # Some responses (errors, proxy pages) are not versions; ignore them.
  if [[ ! ${newer_version} =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "[WARN] $(date -u +'%Y-%m-%dT%H:%M:%SZ') Failed to check new version."
    sleep 86400
    continue
  fi

  if [[ ${newer_version} != "${APP_VERSION}" ]] \
    && printf '%s\n%s\n' "${APP_VERSION}" "${newer_version}" | sort -V -C; then
    echo "[INFO] $(date -u +'%Y-%m-%dT%H:%M:%SZ') Found newer Docker image version wahyd4/aria2-ui:${newer_version}, please consider to upgrade by using docker pull command to have better user experience."
    # check new version daily
    sleep 86400
    continue
  fi
  echo "[INFO] $(date -u +'%Y-%m-%dT%H:%M:%SZ') Congrats, you are using the latest version docker image"
  sleep 86400
done
