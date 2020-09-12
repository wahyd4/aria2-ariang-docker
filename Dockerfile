FROM alpine:latest

LABEL AUTHOR=Junv<wahyd4@gmail.com>

WORKDIR /app

ENV RPC_SECRET=""
ENV ENABLE_AUTH=false
ENV DOMAIN=0.0.0.0:80
ENV ARIA2_USER=user
ENV ARIA2_PWD=password
ENV ARIA2_SSL=false
ENV ARIA2_EXTERNAL_PORT=80
ENV PUID=1000
ENV PGID=1000
ENV CADDYPATH=/app
ENV RCLONE_CONFIG=/app/conf/rclone/rclone.conf

RUN adduser -D -u 1000 junv \
  && apk update \
  && apk add runit shadow wget bash curl openrc gnupg aria2 tar --no-cache \
  && caddy_tag=v1.0.4 \
  && wget -N https://github.com/caddyserver/caddy/releases/download/${caddy_tag}/caddy_${caddy_tag}_linux_amd64.tar.gz \
  && tar -zxvf caddy_${caddy_tag}_linux_amd64.tar.gz \
  && mv caddy /usr/local/bin/ \
  && rm -rf caddy_${caddy_tag}_linux_amd64.tar.gz \
  && filebrowser_version=v2.5.0 \
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
  && rm -rf /app/rclone-*

ADD aria2c.sh caddy.sh Procfile init.sh start.sh rclone.sh /app/
ADD conf /app/conf
ADD Caddyfile SecureCaddyfile /usr/local/caddy/

# AriaNg
RUN mkdir /usr/local/www/aria2/Download \
  && cd /usr/local/www/aria2 \
  && chmod +rw /app/conf/aria2.session \
  && version=1.1.6 \
  && wget -N --no-check-certificate https://github.com/mayswind/AriaNg/releases/download/${version}/AriaNg-${version}.zip \
  && unzip AriaNg-${version}.zip \
  && rm -rf AriaNg-${version}.zip \
  && chmod -R 755 /usr/local/www/aria2

# folder for storing ssl keys
VOLUME /app/conf/key

# file downloading folder
VOLUME /data

EXPOSE 80 443

CMD ["./start.sh"]
