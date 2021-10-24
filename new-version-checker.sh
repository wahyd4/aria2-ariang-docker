#! /bin/bash -u
sleep 5

set -e
APP_VERSION=$(cat APP_VERSION)
set +e
while true; do
  echo "[INFO] $(date -u +'%Y-%m-%dT%H:%M:%SZ') Checking for new version against ${APP_VERSION} ..."
  newer_version=$(curl --max-time 6 -s "https://badges.toozhao.com/val/aria2-ui-docker?version=${APP_VERSION}&arch=$(arch)")
  if [[ -z ${newer_version} ]]; then
    echo "[WARN] $(date -u +'%Y-%m-%dT%H:%M:%SZ') Failed to check new version."
    sleep 86400
    continue
  fi

  if [[ ${newer_version} > ${APP_VERSION} ]]; then
    echo "[INFO] $(date -u +'%Y-%m-%dT%H:%M:%SZ') Found newer Docker image version wahyd4/aria2-ui:${newer_version}, please consider to upgrade by using docker pull command to have better user experience."
    # check new version daily
    sleep 86400
    continue
  fi
  echo "[INFO] $(date -u +'%Y-%m-%dT%H:%M:%SZ') Good job, you are using the latest version docker image"
  sleep 86400
done
