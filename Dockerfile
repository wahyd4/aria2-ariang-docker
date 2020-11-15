FROM alpine:latest

LABEL AUTHOR=Junv<wahyd4@gmail.com>

WORKDIR /app

ENV RPC_SECRET=""
ENV ENABLE_AUTH=false
ENV DOMAIN=http://localhost
ENV ARIA2_USER=user
ENV ARIA2_PWD=password
ENV ARIA2_SSL=false
ENV ARIA2_EXTERNAL_PORT=80
ENV PUID=1000
ENV PGID=1000
ENV CADDYPATH=/app
ENV RCLONE_CONFIG=/app/conf/rclone.conf
ENV XDG_DATA_HOME=/app/.caddy/data
ENV XDG_CONFIG_HOME=/app/.caddy/config

ADD aria2c.sh caddy.sh Procfile init.sh start.sh rclone.sh /app/
ADD conf /app/conf
ADD Caddyfile SecureCaddyfile /usr/local/caddy/

RUN adduser -D -u 1000 junv \
  && apk update \
  && apk add runit shadow wget bash curl openrc gnupg aria2 tar mailcap --no-cache \
  && caddy_tag=2.2.1 \
  && wget -N https://github.com/caddyserver/caddy/releases/download/v${caddy_tag}/caddy_${caddy_tag}_linux_amd64.tar.gz \
  && tar -zxvf caddy_${caddy_tag}_linux_amd64.tar.gz \
  && mv caddy /usr/local/bin/ \
  && rm -rf caddy_${caddy_tag}_linux_amd64.tar.gz \
  && filebrowser_version=v2.7.0 \
  && platform=linux-amd64 \
  && wget -N https://github.com/filebrowser/filebrowser/releases/download/${filebrowser_version}/${platform}-filebrowser.tar.gz \
  && tar -zxvf ${platform}-filebrowser.tar.gz \
  && rm -rf ${platform}-filebrowser.tar.gz \
  && rm LICENSE README.md CHANGELOG.md \
  && wget -N https://bin.equinox.io/c/ekMN3bCZFUn/forego-stable-${platform}.tgz \
  && tar -zxvf forego-stable-${platform}.tgz \
  && rm -rf forego-stable-${platform}.tgz \
  && mkdir -p /usr/local/www \
  && mkdir -p /usr/local/www/aria2 \
  && rm -rf init /app/*.txt \
  && curl -O https://downloads.rclone.org/rclone-current-linux-amd64.zip \
  && unzip rclone-*.zip \
  && cd rclone-*-linux-amd64 \
  && cp rclone /usr/local/bin/ \
  && chown junv:junv /usr/local/bin/rclone \
  && chmod 755 /usr/local/bin/rclone \
  && rm /app/rclone-*.zip \
  && rm -rf /app/rclone-* \
  && mkdir /usr/local/www/aria2/Download \
  && cd /usr/local/www/aria2 \
  && chmod +rw /app/conf/aria2.session \
  && version=1.1.7 \
  && wget -N --no-check-certificate https://github.com/mayswind/AriaNg/releases/download/${version}/AriaNg-${version}.zip \
  && unzip AriaNg-${version}.zip \
  && rm -rf AriaNg-${version}.zip \
  && chmod -R 755 /usr/local/www/aria2

# folder for storing ssl keys
VOLUME /app/conf/key

# file downloading folder
VOLUME /data

EXPOSE 80 443

HEALTHCHECK --interval=1m --timeout=3s \
  CMD curl -f http://localhost || exit 1

CMD ["./start.sh"]
