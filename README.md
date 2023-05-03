Aria2 + AriaNg + Filebrowser

English | [简体中文](https://github.com/wahyd4/aria2-ariang-docker/blob/master/README.CN.md)

[![](https://images.microbadger.com/badges/image/wahyd4/aria2-ui.svg)](https://microbadger.com/images/wahyd4/aria2-ui "Get your own image badge on microbadger.com")
[![Docker Pulls](https://img.shields.io/docker/pulls/wahyd4/aria2-ui.svg)](https://hub.docker.com/r/wahyd4/aria2-ui/)
[![Github Build](https://github.com/wahyd4/aria2-ariang-docker/actions/workflows/dockerimage.yml/badge.svg)](https://github.com/wahyd4/aria2-ariang-docker/actions)

[![Page Views Count](https://badges.toozhao.com/svg/aria2-ariang-docker)](https://badges.toozhao.com/stats/aria2-ariang-docker "Page Views Count")



**If you like this project, please consider [sponsoring me](https://github.com/sponsors/wahyd4) / 如果喜欢本项目，请考虑打赏，谢谢！**

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
- [Download Automation 🤖](#download-automation-)
  - [Download file through iPhone/Mac Shortcuts app.](#download-file-through-iphonemac-shortcuts-app)
  - [Download file through cURL](#download-file-through-curl)
- [Build the image by yourself](#build-the-image-by-yourself)
- [Docker Hub](#docker-hub)
- [Running it on Kubernetes (My favorite)](#running-it-on-kubernetes-my-favorite)
- [Running it with Docker compose](#running-it-with-docker-compose)
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
  * [File Browser](https://filebrowser.org/): Files mangement and videos playing
  * Auto HTTPS （Let's Encrypt）
  * Bind non root user into container, so non root user can also manage downloaded files.
  * Basic Auth
  * Support ARM CPUs as well, all supported CPU platforms can be found [here](https://cloud.docker.com/repository/docker/wahyd4/aria2-ui/tags)
  * Cloud Storage platforms synchronization
  * Auto uploading files to 3rd party Cloud storage providers via Rclone after files been downloaded.

## Recommended versions

* wahyd4/aria2-ui:latest

> Docker will pick the the proper ARCH for you. e.g. arm64v8 or x86_64

## How to run

### Quick run

```shell
  docker run -d --name aria2-ui -p 8000:80 wahyd4/aria2-ui
```

* Aria2: <http://yourip:8000>
* FileManger: <http://yourip:8000/files>
* Rclone: <http://yourip:8000/rclone>
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
  -e CADDY_LOG_LEVEL=ERROR \
  -v /yourdata:/data \
  -v /app/.cache:/app/.cache \
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
| ENV | Description|
|:---|:---|
| `ENABLE_AUTH` | Whether to enable Basic auth |
| `ENABLE_RCLONE` | Whether to disable Rclone, if you running this container offline or do not have stable connection to Github, please set to `false`
| `ARIA2_USER` | Basic Auth username, Rclone GUI uses it as well. |
| `ARIA2_PWD` | Basic Auth password, Rclone GUI uses it as well. |
| `ARIA2_EXTERNAL_PORT` | The Aria2 port which exposed to public to access to |
| `PUID` | Bind Linux UID into container which means you can use non `root` user to manage downloaded files, default UID is `1000` |
| `PGID` | Bind Linux GID into container, default GID is 1000 |
| `RPC_SECRET` | The Aria2 RPC secret token |
| `DOMAIN` | The domain you'd like to bind, when domain is a `https://` thing, then auto TLS feature will be enabled |
| `RCLONE_CONFIG_BASE64` | Inject and config Rclone through `base64` string, which is the only way to use Rclone on Heroku. Please use `cat /app/conf/rclone.conf \| base64` or any base64 online tools such as [this](https://www.base64encode.org/) to encode your `rclone.conf` as bse64 string. Note, you need to set `ENABLE_RCLONE` to true as well. |
| `ENABLE_APP_CHECKER` | By default it's set to `true` to check if any new docker image version release on daily basis, which can help you get notification when new features released as well as some security vulnerabilities get fixed. You can set it to `false` to disable this feature. Note: you still need to manually pull the new image version and re run the docker container to complete upgrading. |
| `CADDY_LOG_LEVEL` | For specifying the log level of Caddy, set it to `WARN` or`ERROR` to reduce logs. Default: `INFO` |
| `RCLONE_AUTO_UPLOAD_PROVIDER` | The Rclone remote storage provider name, which can be found under `Rclone -> Configs`, default `""`, which means auto upload is disabled. When the value is not empty, then the files will be attempted to be uploaded.|
| `RCLONE_AUTO_UPLOAD_REMOTE_PATH` | The file folder in remote cloud storage provider, default `/downloads`|
| `RCLONE_AUTO_UPLOAD_FILE_MIN_SIZE` | Set the minimum file size of auto uploader, files smaller than it won't be uploaded, default `1K`  |
| `RCLONE_AUTO_UPLOAD_FILE_MAX_SIZE` | Set the limit of the Max file can be uploaded to 3rd party storage provider, default `100G`. |
| `FIX_DATA_VOLUME_PERMISSIONS` | Default value is `false`. When set to `true`, the container will run `chown -R` command against `/data` folder and `PUID` and `PGID` you set. Please set it to `true` when container complains you don't have enough permissions to manage the files and folders you mounted.|


### Supported Volumes

| Mountable folder | Description|
|:---|:---|
| `/data` | The folder contains all the files you download. |
| `/app/conf/key` | The folder which stores Aria2 SSL `certificate` and `key` |file. `Notice`: The certificate file should be named `aria2.crt` and the key file should be named `aria2.key` |
| `/app/conf` | The Aria2 configuration and file session folder. 🚨Please make sure you have `aria2.conf` and `aria2.session` file exist on your host, when yout mount /app/conf. For the first time `aria2.session` just need to be a empty file can be appended. You can also user the templates for these two file in the `conf` folder of this project. Please put your `rclone.conf` in this folder as well if you'd mount it to Rclone. So all the config files supported in this folder are: `aria2.conf`, `aria2.session`, `rclone.conf`. 🚨Warning🚨: if you don't mount `/app/conf`, whenever the container restarts, you'll lose your downloading progress. |
|`/app/conf/aria2.conf` | See description above👆🏼 |
|`/app/conf/aria2.session` | See description above👆🏼 |
|`/app/conf/rclone.conf` | See description above👆🏼 |
| `/app/conf/auto-upload.sh` | The bash script to be used for uploading downloaded files to remote storage provider via Rclone, mount your own script if you want to have custom logic. |
| `/app/filebrowser.db` | File Browser settings database, make sure you make a empty file first on your host. |
| `/app/.cache` | The folder for storing rclone caches and [aria2 DHT files](https://aria2.github.io/manual/en/html/aria2c.html#cmdoption-dht-file-path) |


## Auto HTTPS enabling

Make sure you have added proper `A` record point to the host you running to your domain `DNS` record list, then just add `e` option to bind the `https` domain when you run the image

```bash
docker run -d --name aria2-ui -p 80:80 -p 443:443 -e DOMAIN=https://toozhao.com wahyd4/aria2-ui
```
## Download Automation 🤖

### Download file through iPhone/Mac Shortcuts app.

First [Download Shortcut](https://www.icloud.com/shortcuts/7483b8cec7484c0f98b72882d0f1e3e2), then follow the promots to setup aria2-ui URL and RPC_SECRET. Then you are all ready to go, just to run the shortcut and provide the file URL which you want to download or the magnet/torrent file URL.

### Download file through cURL

```bash
curl http://<ip>:<port>/jsonrpc -d "{\"jsonrcp\":\"2.0\",\"id\":\"someID\",\"method\":\"aria2.addUri\",\"params\":[\"token:someToken\",[\"http://some_file_url\"],{\"dir\":\"/data/downloads\"}]}"
```

## Build the image by yourself

```bash
 docker buildx build --platform linux/arm/v7,linux/arm64,linux/amd64 -t aria2-ui .
```

## Docker Hub

  <https://hub.docker.com/r/wahyd4/aria2-ui/>

## Running it on Kubernetes (My favorite)

First of all, I have to say running this docker image on Kubernetes is more challenging and requires more knowledges than running it in raw Docker, but which is more powerful.
I couldn't tell you how to run it in Kubernetes step by step, but once you have a running Kubernetes cluster(You can install Kubernetes via `minikube`, `Docker desktop app`, `kubeadm` and many other tools.), then you can modify the [k8s-manifest.yaml](k8s-manifest.yaml) to satisfy all your requirements. Such as:

* NFS PV provider(Use your NAS as storage)
* Ingress access, Oauth login, more access controls via Nginx etc.
* VPN tunnel (Secure your traffic)
* Sidecars and so on.

## Running it with Docker compose

  Please refer <https://github.com/wahyd4/aria2-ariang-x-docker-compose>



## FAQ
  1. When you running the docker image with non `80` port or you have HTTPS enabled, you will meet the error says `Aria2 Status Disconnected`, then you will need to set `ARIA2_EXTERNAL_PORT` and recreate your container.
  2. If there is no speed at all when you downloading a BitTorrent file, please try to use a popular torrent file first to help the application to cache `DHT` file. Then the speed should get fast and fast, as well as downloading other links.
  3. If you see any errors related to `setcap` which probably means the Linux you are running doesn't support running this application with `non-root` user. So please specify the `PUID` and `PGID` to `0` explicitly to use `root` user to run it.
  4. How can I get `Rclone` authenticated? Due to Rclone is running in this docker image only as a component rather than an application, you can only interact with it via `/rclone` endpoint, and no other ports. So the web browser authentication mechanism doesn't work here. Please configure Rclone through command line within the container. You can follow the official doc [Configuring rclone on a remote / headless machine](https://rclone.org/remote_setup) or this [issue](https://github.com/wahyd4/aria2-ariang-docker/issues/118)
  5. Why the app stopped working when I have `- v /<some-folder>:/app/conf` mounted. It happens when you mount the entire `/app/conf` folder but you don't have any files under that folder on your host. To fix this issue, please simply copy all files under [`conf`](https://github.com/wahyd4/aria2-ariang-docker/tree/master/conf) folder to your local folder that you mount to `/app/conf` and then rerun the container.
