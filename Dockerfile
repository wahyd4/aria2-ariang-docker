FROM golang:1.27.3-trixie AS build-forego

RUN apt-get update \
    && apt-get install -y --no-install-recommends git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Pin the cloned dependency to a commit SHA instead of a floating branch name.
RUN git clone https://github.com/wahyd4/forego.git \
    && cd forego \
    && git checkout 9d06db3253778cd0780e38901e4eefd2ea3824fc \
    && go mod download \
    && go build -trimpath -o forego . \
    && chmod +x forego

FROM debian:trixie-slim

LABEL AUTHOR=Junv<wahyd4@gmail.com>

WORKDIR /app

ENV RPC_SECRET=""
ENV ENABLE_AUTH=false
ENV ENABLE_RCLONE=true
ENV DOMAIN=:80
ENV ARIA2_USER=user
ENV ARIA2_PWD=password
ENV ARIA2_SSL=false
# ARIA2_EXTERNAL_PORT is intentionally left unset: when it is empty, AriaNg
# derives the RPC port from the page's own URL, which is correct for any
# published port and for HTTPS. Setting it overrides that derivation.
ENV PUID=1000
ENV PGID=1000
ENV CADDYPATH=/app
ENV RCLONE_CONFIG=/app/conf/rclone.conf
ENV XDG_DATA_HOME=/app/.caddy/data
ENV XDG_CONFIG_HOME=/app/.caddy/config
ENV XDG_CACHE_HOME=/app/.cache
ENV RCLONE_CONFIG_BASE64=""
ENV ENABLE_APP_CHECKER=true
ENV ENABLE_FILEBROWSER=true
ENV CADDY_LOG_LEVEL=INFO
ENV RCLONE_AUTO_UPLOAD_PROVIDER=
ENV RCLONE_AUTO_UPLOAD_REMOTE_PATH=/downloads
ENV RCLONE_AUTO_UPLOAD_FILE_MIN_SIZE=1K
ENV RCLONE_AUTO_UPLOAD_FILE_MAX_SIZE=100G
ENV FIX_DATA_VOLUME_PERMISSIONS=false
ENV CADDY_FILE_SERVER_BROWSE_HTML=/app/browse.html

ADD install.sh aria2c.sh caddy.sh filebrowser.sh Procfile init.sh start.sh rclone.sh new-version-checker.sh APP_VERSION /app/
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

# For Caddy ACME certificates and account keys, so container recreation
# does not throw them away and trigger repeated certificate issuance.
VOLUME /app/.caddy

EXPOSE 80 443 6881

HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost/ping || exit 1

CMD ["./start.sh"]
