#! /bin/sh -eux

echo "[INFO] Set variables for $(arch)"

caddy_version=2.11.7
filebrowser_version=v2.63.23
rclone_version=v1.75.2
ariang_version=1.3.15

# Caddy publishes SHA-512 checksums (caddy_${caddy_version}_checksums.txt),
# so these are SHA-512 even though the file name says "checksums".
caddy_sha512_amd64=a7a433a1b133efc3c8d10eb0b99d52a24b5ef5c322dc77f5282182b1c0402139ab83f3a99f0c52409df77d20123fb0b523edad8a66d8f5e49136197bf61ef0e7
caddy_sha512_arm64=3db36ba90c7a6e8dda40ee3dd71fa08844c76b5fb08f61b31e5e78d2ed38e71c51dc7baed875e50d1ca1279196e84302967237386ae87c91ae9f2aaceada682e
caddy_sha512_armv7=6eb3894f9a215f75f3ec50e627c34b2cd6fb81d10ec7838f27c30dcf417b810f618136b507766bc17e7400a5c0f4fa6001bb062ebb7a401ee63505012615825e

rclone_sha256_amd64=349ac8fba6ff65d6247043f1750cdcb518ec5d500ef91463a10d37c0ccdf3702
rclone_sha256_arm64=7e1e8d69654941b7b7df84ee74c5f7fb09cce7d5496947fb7bf16b55ff427d10
rclone_sha256_armv7=757a5b233ad0e8cdc60749a2d451231d81be45c01304a4c04b4514e733275b73

filebrowser_sha256_amd64=b14db2bb8033caa3f80205eb6578b2ed0744ebd9e716b790bc4a9703ce909e88
filebrowser_sha256_arm64=c55b3450b6ac07ef73b5b49f0b2955a8e755100b71af1df73f9e5d25b12fd27a
filebrowser_sha256_armv7=dee508c90f30434cb7cce0cac5359dece2e938792bbcaff03cbccb7f8e37bd8c

# AriaNg does not publish a checksum file; this is the SHA-256 of the
# AriaNg-${ariang_version}.zip release asset.
ariang_sha256=d2317e441966ad31f1e342cb6a6cc1c51808fb0a10cf6e39cb30b0517b3e7823

# browse.html is pinned to a commit; this is the SHA-256 of that blob.
browse_html_sha256=079bbc8539e74ef4e311c83bc30f10a5ff9d4b22ce2b15c64566c55a1576b6f4

verify_sha256() {
  printf '%s  %s\n' "$1" "$2" | sha256sum -c -
}

verify_sha512() {
  printf '%s  %s\n' "$1" "$2" | sha512sum -c -
}

case "$(arch)" in

   x86_64)
      platform=linux-amd64
      caddy_arch=amd64
      caddy_sha512=${caddy_sha512_amd64}
      rclone_platform=linux-amd64
      rclone_sha256=${rclone_sha256_amd64}
      filebrowser_sha256=${filebrowser_sha256_amd64}
     ;;
   armv7l)
      platform=linux-armv7
      caddy_arch=armv7
      caddy_sha512=${caddy_sha512_armv7}
      rclone_platform=linux-arm-v7
      rclone_sha256=${rclone_sha256_armv7}
      filebrowser_sha256=${filebrowser_sha256_armv7}
     ;;

   aarch64)
      platform=linux-arm64
      caddy_arch=arm64
      caddy_sha512=${caddy_sha512_arm64}
      rclone_platform=linux-arm64
      rclone_sha256=${rclone_sha256_arm64}
      filebrowser_sha256=${filebrowser_sha256_arm64}
     ;;

   *)
     echo "[ERROR] unsupported arch $(arch), exit now"
     exit 1
     ;;
esac

caddy_file=caddy_${caddy_version}_linux_${caddy_arch}.tar.gz
rclone_file=rclone-${rclone_version}-${rclone_platform}.zip
filebrowser_file=${platform}-filebrowser.tar.gz
ariang_file=AriaNg-${ariang_version}.zip

export DEBIAN_FRONTEND=noninteractive

groupadd junv \
  && useradd -g junv -m -s /bin/bash junv \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
       ca-certificates wget curl aria2 tar unzip libcap2-bin runit \
  && wget -N https://github.com/caddyserver/caddy/releases/download/v${caddy_version}/${caddy_file} \
  && verify_sha512 "${caddy_sha512}" "${caddy_file}" \
  && tar -zxf ${caddy_file} \
  && mv caddy /usr/local/bin/ \
  && rm -rf ${caddy_file} \
  && wget -P /app -N https://raw.githubusercontent.com/glowinthedark/caddy-file-server-browse-extension/39e997c91539d0f04fcce53a3cb6605b2ae9e50c/browse.html \
  && verify_sha256 "${browse_html_sha256}" /app/browse.html \
  && wget -N https://github.com/filebrowser/filebrowser/releases/download/${filebrowser_version}/${filebrowser_file} \
  && verify_sha256 "${filebrowser_sha256}" "${filebrowser_file}" \
  && tar -zxf ${filebrowser_file} \
  && rm -rf ${filebrowser_file} \
  && rm -f LICENSE README.md CHANGELOG.md \
  && mkdir -p /usr/local/www \
  && mkdir -p /usr/local/www/aria2 \
  && rm -rf init /app/*.txt \
  && curl -fsSLO https://downloads.rclone.org/${rclone_version}/${rclone_file} \
  && verify_sha256 "${rclone_sha256}" "${rclone_file}" \
  && unzip -q ${rclone_file} \
  && cd rclone-* \
  && cp rclone /usr/local/bin/ \
  && chown junv:junv /usr/local/bin/rclone \
  && chmod 755 /usr/local/bin/rclone \
  && rm /app/${rclone_file} \
  && rm -rf /app/rclone-* \
  && mkdir /usr/local/www/aria2/Download \
  && cd /usr/local/www/aria2 \
  && chmod 644 /app/conf/aria2.session \
  && wget -N https://github.com/mayswind/AriaNg/releases/download/${ariang_version}/${ariang_file} \
  && verify_sha256 "${ariang_sha256}" "${ariang_file}" \
  && unzip -q ${ariang_file} \
  && rm -rf ${ariang_file} \
  && chmod -R 755 /usr/local/www/aria2 \
  && mkdir -p /data && chown junv:junv /data \
  && mkdir -p /data/cloud \
  && chown junv:junv /data/cloud \
  && ln -s /data/cloud /app \
  && apt-get purge -y --auto-remove unzip \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
