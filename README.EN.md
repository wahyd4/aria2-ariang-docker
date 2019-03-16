Aria2 + AriaNg

English | [简体中文](https://github.com/wahyd4/aria2-ariang-docker/blob/master/README.md)

[![](https://images.microbadger.com/badges/image/wahyd4/aria2-ui.svg)](https://microbadger.com/images/wahyd4/aria2-ui "Get your own image badge on microbadger.com")

- [Features](#features)
- [How to run](#how-to-run)
  - [Simple Usage](#simple-usage)
  - [Fully Usage](#fully-usage)
  - [Supported Environment Variables](#supported-environment-variables)
  - [Supported Volumes](#supported-volumes)
- [Docker Hub](#docker-hub)
- [Usage it in Docker compose](#usage-it-in-docker-compose)
- [FAQ](#faq)

Aria2
![Screenshot](https://github.com/wahyd4/aria2-ariang-x-docker-compose/raw/master/images/ariang.png)

File Browser
![File Browser](https://github.com/wahyd4/aria2-ariang-docker/raw/master/filemanager.png)
## Features

  * Aria2 (SSL support)
  * AriaNg
  * Auto HTTPS （Let's Encrypt）
  * Basic Auth
  * File indexing and video playing ([File Browser](https://filebrowser.xyz/))
  * Add support for ARM CPUs, please choose correct [docker image TAG](https://cloud.docker.com/repository/docker/wahyd4/aria2-ui/tags)

## How to run

### Simple Usage

```shell
  docker run -d --name aria2-ui -p 80:80 -p 6800:6800 wahyd4/aria2-ui
```

* Aria2: <http://yourip/ui/> **The tailling `/` is necessary**
* FileManger: <http://yourip>
* Please use admin/admin as username and password to login

### Fully Usage
```bash
  docker run -d --name ariang \
  -p 80:80 -p 6800:6800 -p 443:443 \
  -e ENABLE_AUTH=true \
  -e RPC_SECRET=Hello \
  -e DOMAIN=example.com \
  -e ARIA2_USER=user \
  -e ARIA2_PWD=pwd \
  -v /yourdata:/data \
  -v /root/a.db:/root/filebrowser.db \
  -v /yoursslkeys/:/root/conf/key \
  -v <to your aria2.conf>:/root/conf/aria2.conf \
  wahyd4/aria2-ui
```

### Supported Environment Variables

  * ENABLE_AUTH enable Basic auth
  * ARIA2_USER Basic Auth username
  * ARIA2_PWD Basic Auth
  * RPC_SECRET The Aria2 RPC secret token
  * DOMAIN The domain you'd like to bind


### Supported Volumes
  * `/data` The folder of all Aria2 downloaded files.
  * `/root/conf/key` The folder which stored Aria2 SSL `certificate` and `key` file. `Notice`: The certificate file should be named `aria2.crt` and the key file should be named `aria2.key`
  * `/root/conf/aria2.conf` The Aria2 configuration file.
  * `/root/filebrowser.db` File Browser settings db, make sure you make a empty file first on your host.


## Docker Hub

  <https://hub.docker.com/r/wahyd4/aria2-ui/>

## Usage it in Docker compose

  Please refer <https://github.com/wahyd4/aria2-ariang-x-docker-compose>

## FAQ

  1. If there is no speed at all when you downloading a BitTorrent file, please try to use a popular torrent file first to help the application to cache `DHT` file. Then the speed should get fast and fast, as well as downloading other links.
