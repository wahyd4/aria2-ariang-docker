FROM lsiobase/alpine:3.10

LABEL AUTHOR=Junv<wahyd4@gmail.com>

WORKDIR /app

ENV RPC_SECRET=""
ENV ENABLE_AUTH=false
ENV DOMAIN=0.0.0.0:80
ENV ARIA2_USER=user
ENV ARIA2_PWD=password
ENV SSL=false

RUN apk update \
  && apk add wget bash curl openrc gnupg aria2 tar --no-cache \
  && curl https://getcaddy.com | bash -s personal \
  && curl -fsSL https://filebrowser.xyz/get.sh | bash \
  && wget -N https://bin.equinox.io/c/ekMN3bCZFUn/forego-stable-linux-amd64.tgz && tar -zxvf forego-stable-linux-amd64.tgz && rm -rf forego-stable-linux-amd64.tgz \
  && mkdir -p /usr/local/www && mkdir -p /usr/local/www/aria2 \
# AriaNg
  && cd /usr/local/www/aria2 \
  && version=1.1.0 \
  && wget -N --no-check-certificate https://github.com/mayswind/AriaNg/releases/download/${version}/AriaNg-${version}.zip && unzip AriaNg-${version}.zip && rm -rf AriaNg-${version}.zip \
  && sed -i 's/6800/80/g' /usr/local/www/aria2/js/aria-ng*.js \
  && apk del curl wget tar 

COPY root/ /

# folder for storing ssl keys
VOLUME /app/conf/key

# file downloading folder
VOLUME /data

EXPOSE 80 443

