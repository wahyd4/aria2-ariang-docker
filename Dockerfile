FROM golang:alpine AS build-forego

RUN apk add --no-cache git openssh

WORKDIR /app

RUN git clone https://github.com/wahyd4/forego.git \
    && cd forego \
    && git checkout fix-go-mod \
    && go mod download \
    && go build -o forego \
    && chmod +x forego

FROM alpine:edge

LABEL AUTHOR=Junv<wahyd4@gmail.com>

WORKDIR /app

ENV RPC_SECRET=""
ENV ENABLE_AUTH=false
ENV ENABLE_RCLONE=true
ENV DOMAIN=:80
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
ENV XDG_CACHE_HOME=/app/.cache
ENV RCLONE_CONFIG_BASE64=""
ENV ENABLE_APP_CHECKER=true
ENV CADDY_LOG_LEVEL=INFO
ENV RCLONE_AUTO_UPLOAD_PROVIDER=
ENV RCLONE_AUTO_UPLOAD_REMOTE_PATH=/downloads
ENV RCLONE_AUTO_UPLOAD_FILE_MIN_SIZE=1K
ENV RCLONE_AUTO_UPLOAD_FILE_MAX_SIZE=100G

ADD install.sh aria2c.sh caddy.sh Procfile init.sh start.sh rclone.sh new-version-checker.sh APP_VERSION /app/
ADD conf /app/conf
ADD Caddyfile SecureCaddyfile HerokuCaddyfile /usr/local/caddy/

COPY --from=build-forego /app/forego/forego /app

RUN ./install.sh

RUN rm ./install.sh

# For config files
VOLUME /app/conf/

# For file downloading
VOLUME /data

# For rclone cache and aria2 DHT files
VOLUME /app/.cache

EXPOSE 80 443 6881

HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost/ping || exit 1

CMD ["./start.sh"]
