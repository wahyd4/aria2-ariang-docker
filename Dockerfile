FROM alpine:edge

LABEL AUTHOR=Junv<wahyd4@gmail.com>

WORKDIR /root

ENV RPC_SECRET=Hello
ENV ENABLE_AUTH=false
ENV DOMAIN=0.0.0.0:80
ENV ARIA2_USER=user
ENV ARIA2_PWD=password

RUN apk update \
  && apk add wget bash curl openrc gnupg screen aria2 tar --no-cache

RUN curl https://getcaddy.com | bash -s personal
RUN curl -fsSL https://filebrowser.xyz/get.sh | bash

RUN mkdir -p /usr/local/www && mkdir -p /usr/local/www/aria2
ADD conf /root/conf
COPY aria2c.sh /root
COPY Caddyfile SecureCaddyfile /usr/local/caddy/

# AriaNg
RUN mkdir /usr/local/www/aria2/Download && cd /usr/local/www/aria2 \
 && chmod +rw /root/conf/aria2.session \
 && version=1.1.0 \
 && wget -N --no-check-certificate https://github.com/mayswind/AriaNg/releases/download/${version}/AriaNg-${version}.zip && unzip AriaNg-${version}.zip && rm -rf AriaNg-${version}.zip \
 && chmod -R 755 /usr/local/www/aria2 \
 && chmod +x /root/aria2c.sh

#The folder to store ssl keys
VOLUME /root/conf/key
# User downloaded files
VOLUME /data

EXPOSE 6800 80 443

CMD ["/bin/sh", "/root/aria2c.sh" ]
