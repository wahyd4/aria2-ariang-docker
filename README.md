Aria2 + AriaNg + Filebrowser

English | [简体中文](https://github.com/wahyd4/aria2-ariang-docker/blob/master/README.CN.md)

[![](https://images.microbadger.com/badges/image/wahyd4/aria2-ui.svg)](https://microbadger.com/images/wahyd4/aria2-ui "Get your own image badge on microbadger.com")
[![Docker Pulls](https://img.shields.io/docker/pulls/wahyd4/aria2-ui.svg)](https://hub.docker.com/r/wahyd4/aria2-ui/)
[![Github Build](https://github.com/wahyd4/aria2-ariang-docker/workflows/Docker%20Image%20CI/badge.svg)](https://github.com/wahyd4/aria2-ariang-docker/actions)
[![Page Views Count](https://badges.toozhao.com/svg/aria2-ariang-docker)](https://badges.toozhao.com/stats/aria2-ariang-docker "Page Views Count")

**If you like this project, please consider support me / 如果喜欢本项目，请考虑打赏，谢谢！**

<img src="https://raw.githubusercontent.com/wahyd4/work-in-australia/766592ac6318027d7b3c334d8c50ca80818eeff8/wepay.jpg" alt="buy me a drink" width="120"/>

- [Features](#features)
- [Recommended versions](#recommended-versions)
- [How to run](#how-to-run)
  - [Quick run](#quick-run)
  - [Full features run](#full-features-run)
  - [Run with docker-compose](#run-with-docker-compose)
  - [Supported Environment Variables](#supported-environment-variables)
  - [Supported Volumes](#supported-volumes)
- [Auto HTTPS enabling](#auto-https-enabling)
- [Build the image by yourself](#build-the-image-by-yourself)
- [Docker Hub](#docker-hub)
- [Usage it in Docker compose](#usage-it-in-docker-compose)
- [FAQ](#faq)

One Docker image for file downloading, managing, sharing, as well as video playing and evening cloud storage synchronization.

Furthermore, it's pretty small and ARM CPU compatible which means you can also run it on Raspberry Pi🍓.

Last but not least, Auto HTTPS can't be more easy!

AriaNG
![Screenshot](https://github.com/wahyd4/aria2-ariang-x-docker-compose/raw/master/images/ariang.jpg)

File Browser
![File Browser](https://github.com/wahyd4/aria2-ariang-docker/raw/master/filemanager.png)

## Features

  * [Aria2 (SSL support)](https://aria2.github.io)
  * [AriaNg](https://github.com/mayswind/AriaNg)
  * [Rclone](https://rclone.org/)
  * [File Browser](https://filebrowser.xyz/): Files mangement and videos playing 
  * Auto HTTPS （Let's Encrypt）
  * Bind non root user into container, so non root user can also manage downloaded files.
  * Basic Auth
  * Support ARM CPUs as well, all supported CPU platforms can be found [here](https://cloud.docker.com/repository/docker/wahyd4/aria2-ui/tags)
  * Cloud Storage platforms synchronization

## Recommended versions

* wahyd4/aria2-ui:latest

> Docker will pick the the proper ARCH for you. e.g. arm64v8 or x86_64

## How to run

### Quick run

```shell
  docker run -d --name aria2-ui -p 80:80 wahyd4/aria2-ui
```

* Aria2: <http://yourip>
* FileManger: <http://yourip/files>
* Rclone: <http://yourip/rclone>
* Please use `admin`/`admin` as username and password to login `Filebrowser` for the first time. And use `user`/`password` to login `Rclone` if you don't update `ARIA2_USER` and `ARIA2_PWD`

### Full features run

```bash
  docker run -d --name ariang \
  -p 80:80 \
  -p 443:443 \
  -e PUID=1000 \
  -e PGID=1000 \
  -e ENABLE_AUTH=true \
  -e RPC_SECRET=Hello \
  -e DOMAIN=https://example.com \
  -e ARIA2_SSL=false \
  -e ARIA2_USER=user \
  -e ARIA2_PWD=password \
  -e ARIA2_EXTERNAL_PORT=443 \
  -v /yourdata:/data \
  -v /app/a.db:/app/filebrowser.db \
  -v /to_yoursslkeys/:/app/conf/key \
  -v <conf files folder>:/app/conf \
  wahyd4/aria2-ui
```
### Run with docker-compose

If you would like to get rid of those annoying command line commands, then just put the following sample content into `docker-compose.yaml`
```yaml
version: "3.5"
services:
  aria2-ui:
    restart: unless-stopped
    image: wahyd4/aria2-ui:latest
    environment:
      - ENABLE_AUTH=true
      - ARIA2_USER=hello
      - ARIA2_PWD=world
      - DOMAIN=http://toozhao.com
    ports:
      - "80:80"
    volumes:
      - ./data:/data
```
Then simply run `docker-compose up -d`, that's it!

### Supported Environment Variables

  * ENABLE_AUTH whether to enable Basic auth
  * ENABLE_RCLONE whether to disable Rclone, if you running this container offline or do not have stable connection to Github, please set to `false`
  * ARIA2_USER Basic Auth username, Rclone GUI uses it as well.
  * ARIA2_PWD Basic Auth password, Rclone GUI uses it as well.
  * ARIA2_EXTERNAL_PORT The Aria2 port which exposed to public to access to
  * PUID Bind Linux UID into container which means you can use non `root` user to manage downloaded files, default UID is `1000`
  * PGID Bind Linux GID into container, default GID is 1000
  * RPC_SECRET The Aria2 RPC secret token
  * DOMAIN The domain you'd like to bind, when domain is a `https://` thing, then auto SSL feature will be enabled


### Supported Volumes
  * `/data` The folder contains all the files you download.
  * `/app/conf/key` The folder which stores Aria2 SSL `certificate` and `key` file. `Notice`: The certificate file should be named `aria2.crt` and the key file should be named `aria2.key`
  * `/app/conf` The Aria2 configuration and file session folder. Make sure you have `aria2.conf` and `aria2.session` file. For the first time `aria2.session` just need to be a empty file can be appended. You can also user the templates for these two file in the `conf` folder of this project. Please put your `rclone.conf` in this folder as well if you'd mount it to Rclone. So all the config files supported in this folder are:
    * aria2.conf
    * aria2.session
    * rclone.conf

    **Warning: if you don't mount `/app/conf`, whenever the container restarts, you'll lose your downloading progress.**
  * `/app/filebrowser.db` File Browser settings database, make sure you make a empty file first on your host.

## Auto HTTPS enabling

Make sure you have added proper `A` record point to the host you running to your domain `DNS` record list, then just add `e` option to bind the `https` domain when you run the image

```bash
docker run -d --name aria2-ui -p 80:80 -p 443:443 -e DOMAIN=https://toozhao.com wahyd4/aria2-ui
```
## Build the image by yourself

```bash
 docker buildx build --platform linux/arm/v7,linux/arm64,linux/amd64 -t aria2-ui .
```

## Docker Hub

  <https://hub.docker.com/r/wahyd4/aria2-ui/>

## Usage it in Docker compose

  Please refer <https://github.com/wahyd4/aria2-ariang-x-docker-compose>

## FAQ
  1. When you running the docker image with non `80` port or you have HTTPS enabled, you will meet the error says `Aria2 Status Disconnected`, then you will need to set `ARIA2_EXTERNAL_PORT` and recreate your container.
  2. If there is no speed at all when you downloading a BitTorrent file, please try to use a popular torrent file first to help the application to cache `DHT` file. Then the speed should get fast and fast, as well as downloading other links.
  3. If you see any errors related to `setcap` which probably means the Linux you are running doesn't support running this application with `non-root` user. So please specify the `PUID` and `PGID` to `0` explicitly to use `root` user to run it.
  4. How can I get `Rclone` authenticated? Due to Rclone is running in this docker image only as a component rather than an application, you can only interact with it via `/rclone` endpoint, and no other ports. So the web browser authentication mechanism doesn't work here. Please configure Rclone through command line within the container. You can follow the official doc [Configuring rclone on a remote / headless machine](https://rclone.org/remote_setup) or this [issue](https://github.com/wahyd4/aria2-ariang-docker/issues/118)
