#!/bin/bash -eu
RCLONE_AUTO_UPLOAD_PROVIDER=google-drive
if [[ $RCLONE_AUTO_UPLOAD_PROVIDER == "" ]]; then
    echo "[INFO] $(date -u +'%Y-%m-%dT%H:%M:%SZ') Auto upload isn't enabled"
    exit 0
fi

if [ $2 -eq 0 ]; then
    echo "[WARN] $(date -u +'%Y-%m-%dT%H:%M:%SZ') No files detected"
    exit 0
fi

echo "[INFO] $(date -u +'%Y-%m-%dT%H:%M:%SZ') Start to upload files with: Files Count: [$2], Files Path: [$3]"

path=$3                                    # File full path
downloadpath='/data'                       # Aria2 downloading folder
provider_name=$RCLONE_AUTO_UPLOAD_PROVIDER # RClone remote provider
folder=$RCLONE_AUTO_UPLOAD_REMOTE_PATH     # Foler path in Rclone remote provider
MinSize=$RCLONE_AUTO_UPLOAD_FILE_MIN_SIZE  # Set mininum file size to be uploaded, files smaller than this will be deleted without uploading
MaxSize=$RCLONE_AUTO_UPLOAD_FILE_MAX_SIZE  # Set the Max file size to be uploaded

while true; do #提取下载文件根路径，如把/data/a/b/c/d.jpg变成/data/a
    file_path=$path
    path=${path%/*}
    if [ "$path" == "" ]; then #不在下载文件夹
        exit 0
    elif [ "$path" == "$downloadpath" ] && [ $2 -eq 1 ]; then # To handle single file
        rclone move "$file_path" ${provider_name}:${folder}/
        echo "[INFO] $(date -u +'%Y-%m-%dT%H:%M:%SZ') Successfully uploaded file $file_path"
        exit 0
    elif [ "$path" == "$downloadpath" ]; then # To handle folder
        while [[ "$(ls -A "$file_path/")" != "" ]]; do
            rclone move "$file_path"/ ${provider_name}:${folder}/"${file_path##*/}"/ --delete-empty-src-dirs --min-size $MinSize --max-size $MaxSize

            echo "[INFO] $(date -u +'%Y-%m-%dT%H:%M:%SZ') Successfully uploaded file $file_path"

            rclone delete -v "$file_path" --max-size $MinSize # Delete files smaller than min file.
        done
        rm -rf "$file_path/"
        exit 0
    fi
done
