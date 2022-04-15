#! /bin/sh -eux

echo "[INFO] Set variables for $(arch)"

caddy_version=2.4.6
filebrowser_version=v2.21.1
rclone_version=v1.58.0
ariang_version=1.2.3

case "$(arch)" in

   x86_64)
      platform=linux-amd64
      caddy_file=caddy_${caddy_version}_linux_amd64.tar.gz
      rclone_file=rclone-${rclone_version}-${platform}.zip
     ;;
   armv7l)
     platform=linux-armv7
     caddy_file=caddy_${caddy_version}_linux_armv7.tar.gz
     rclone_file=rclone-${rclone_version}-linux-arm-v7.zip
     ;;

   aarch64)
     platform=linux-arm64
     caddy_file=caddy_${caddy_version}_linux_arm64.tar.gz
     rclone_file=rclone-${rclone_version}-${platform}.zip
     ;;

   *)
     echo "[ERROR] unsupported arch $(arch), exit now"
     exit 1
     ;;
esac

filebrowser_file=${platform}-filebrowser.tar.gz
ariang_file=AriaNg-${ariang_version}.zip

adduser -D -u 1000 junv \
  && apk update \
  && apk add runit shadow wget bash curl openrc gnupg aria2 tar mailcap fuse vim --no-cache \
  && wget -N https://github.com/caddyserver/caddy/releases/download/v${caddy_version}/${caddy_file} \
  && tar -zxf ${caddy_file} \
  && mv caddy /usr/local/bin/ \
  && rm -rf ${caddy_file} \
  && platform=linux-amd64 \
  && wget -N https://github.com/filebrowser/filebrowser/releases/download/${filebrowser_version}/${filebrowser_file} \
  && tar -zxf ${filebrowser_file} \
  && rm -rf ${filebrowser_file} \
  && rm LICENSE README.md CHANGELOG.md \
  && mkdir -p /usr/local/www \
  && mkdir -p /usr/local/www/aria2 \
  && rm -rf init /app/*.txt \
  && curl -O https://downloads.rclone.org/${rclone_version}/${rclone_file} \
  && unzip ${rclone_file} \
  && cd rclone-* \
  && cp rclone /usr/local/bin/ \
  && chown junv:junv /usr/local/bin/rclone \
  && chmod 755 /usr/local/bin/rclone \
  && rm /app/${rclone_file} \
  && rm -rf /app/rclone-* \
  && mkdir /usr/local/www/aria2/Download \
  && cd /usr/local/www/aria2 \
  && chmod +rw /app/conf/aria2.session \
  && wget -N --no-check-certificate https://github.com/mayswind/AriaNg/releases/download/${ariang_version}/${ariang_file} \
  && unzip ${ariang_file} \
  && rm -rf ${ariang_file} \
  && chmod -R 755 /usr/local/www/aria2 \
  && mkdir -p /data/cloud \
  && chown junv:junv /data/cloud \
  && ln -s /data/cloud /app
