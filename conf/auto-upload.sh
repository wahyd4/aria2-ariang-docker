#!/bin/bash -eu

if [[ ${RCLONE_AUTO_UPLOAD_PROVIDER} == "" ]]; then
    echo "[INFO] $(date -u +'%Y-%m-%dT%H:%M:%SZ') Auto upload isn't enabled"
    exit 0
fi

file_count=$2
file_path=$3
downloadsFolder='/data'

if [ ${file_count} -eq 0 ]; then
    echo "[WARN] $(date -u +'%Y-%m-%dT%H:%M:%SZ') No files detected. Original parameters: Files Count: ${file_count}, Files Path: ${file_path}"
    exit 0
fi

echo "[INFO] $(date -u +'%Y-%m-%dT%H:%M:%SZ') Start to upload files with: Files Count: ${file_count}, Files Path: ${file_path}"

folder=${file_path%/*}

if [ "${folder}" == "" ]; then # Not the actual file, or no files downloaded.
    echo "[WARN] $(date -u +'%Y-%m-%dT%H:%M:%SZ') Fail to find files ${file_path}"
    exit 0
else
    if [[ "$(ls -A "$folder/")" != "" ]] && [[ ${folder} != ${downloadsFolder} ]] ; then
        # Copy files to remote
        echo "[INFO] $(date -u +'%Y-%m-%dT%H:%M:%SZ') Start uploading entire folder ${folder}"
        rclone copy "${folder}" ${RCLONE_AUTO_UPLOAD_PROVIDER}:${RCLONE_AUTO_UPLOAD_REMOTE_PATH}${folder}/ --min-size ${RCLONE_AUTO_UPLOAD_FILE_MIN_SIZE} --max-size ${RCLONE_AUTO_UPLOAD_FILE_MAX_SIZE} -P
    else
        #Handle single file
        echo "[INFO] $(date -u +'%Y-%m-%dT%H:%M:%SZ') Start uploading file file_path"
        rclone copy "${file_path}" ${RCLONE_AUTO_UPLOAD_PROVIDER}:${RCLONE_AUTO_UPLOAD_REMOTE_PATH}${folder}/ --min-size ${RCLONE_AUTO_UPLOAD_FILE_MIN_SIZE} --max-size ${RCLONE_AUTO_UPLOAD_FILE_MAX_SIZE} -P
    fi
    echo "[INFO] $(date -u +'%Y-%m-%dT%H:%M:%SZ') Successfully uploaded ${file_count} files ${file_path}"
fi
