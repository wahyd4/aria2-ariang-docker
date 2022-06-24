#!/bin/bash -eux

if [[ ${RCLONE_AUTO_UPLOAD_PROVIDER} == "" ]]; then
    echo "[INFO] $(date -u +'%Y-%m-%dT%H:%M:%SZ') Auto upload isn't enabled"
    exit 0
fi

file_count=$2
file_path=$3
downloadsFolder='/data'

if [ $file_count -eq 0 ]; then
    echo "[WARN] $(date -u +'%Y-%m-%dT%H:%M:%SZ') No files detected. Original parameters: Files Count: ${file_count}, Files Path: ${file_path}"
    exit 0
fi

echo "[INFO] $(date -u +'%Y-%m-%dT%H:%M:%SZ') Start to upload files with: Files Count: ${file_count}, Files Path: ${file_path}"

folder=${file_path%/*}

if [ "${folder}" == "" ]; then # Not the actual file, or no files downloaded.
    echo "[WARN] $(date -u +'%Y-%m-%dT%H:%M:%SZ') Fail to find files ${file_path}"
    exit 0
else
    # Copy files to remote
    rclone copy "${file_path}" ${RCLONE_AUTO_UPLOAD_PROVIDER}:${RCLONE_AUTO_UPLOAD_REMOTE_PATH}${folder}/ --min-size ${RCLONE_AUTO_UPLOAD_FILE_MIN_SIZE} --max-size ${RCLONE_AUTO_UPLOAD_FILE_MAX_SIZE} -P
    echo "[INFO] $(date -u +'%Y-%m-%dT%H:%M:%SZ') Successfully uploaded ${file_count} files ${file_path}"
fi
