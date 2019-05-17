Aria2 + AriaNg

[English](https://github.com/wahyd4/aria2-ariang-docker/blob/master/README.EN.md) | 简体中文

[![](https://images.microbadger.com/badges/image/wahyd4/aria2-ui.svg)](https://microbadger.com/images/wahyd4/aria2-ui "Get your own image badge on microbadger.com")
[![Docker Pulls](https://img.shields.io/docker/pulls/wahyd4/aria2-ui.svg)](https://hub.docker.com/r/wahyd4/aria2-ui/)
[![Build Status](https://travis-ci.org/wahyd4/aria2-ariang-docker.svg?branch=master)](https://travis-ci.org/wahyd4/aria2-ariang-docker)


本镜像包含 Aria2、AriaNg 和File Manager，主要方便那些用户期望只运行一个镜像就能实现图形化下载文件和在线播放文件。（类似离线下载的功能），只使用一个 Docker 镜像也方便用户在群晖NAS 中运行本程序。

- [功能特性](#功能特性)
- [推荐使用的docker image tag](#推荐使用的docker-image-tag)
- [安装于运行](#安装于运行)
  - [快速运行](#快速运行)
  - [开启所有功能](#开启所有功能)
  - [支持的 Docker 环境变量](#支持的-docker-环境变量)
  - [支持的 Docker volume 属性](#支持的-docker-volume-属性)
- [自行构建镜像](#自行构建镜像)
- [Docker Hub](#docker-hub)
- [使用 Docker compose 来运行](#使用-docker-compose-来运行)
- [常见问题](#常见问题)

Aria2
![Screenshot](https://github.com/wahyd4/aria2-ariang-x-docker-compose/raw/master/images/ariang.png)

File Browser
![File Browser](https://github.com/wahyd4/aria2-ariang-docker/raw/master/filemanager.png)
## 功能特性

  * Aria2 (SSL 支持)
  * AriaNg 通过 UI 来操作，下载文件
  * 自动 HTTPS （Let's Encrypt）
  * Basic Auth 用户认证
  * 文件管理和视频播放 ([File Browser](https://filebrowser.xyz/)，注意默认情况下，只能访问和管理 `/data` 目录下的文件)
  * 支持ARM CPU 架构，因此可以在树莓派中运行，请下载对应的[ARM TAG](https://cloud.docker.com/repository/docker/wahyd4/aria2-ui/tags) 版本, `arm32`或`arm64`

## 推荐使用的docker image tag

* latest
* arm32
* arm64

## 安装于运行

### 快速运行

```shell
  docker run -d --name aria2-ui -p 80:80 -p 6800:6800 wahyd4/aria2-ui
```

* Aria2: <http://yourip/ui/>   **最后的斜线必须带上!**
* FileManger: <http://yourip>
* 请使用 admin/admin 进行登录
### 开启所有功能
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

### 支持的 Docker 环境变量

  * ENABLE_AUTH 启用 Basic auth 用户认证
  * ARIA2_USER Basic Auth 用户认证用户名
  * ARIA2_PWD Basic Auth 密码
  * RPC_SECRET Aria2 RPC 加密 token
  * DOMAIN 绑定的域名, 当绑定的域名为`HTTPS`时，即为启用`HTTPS`， 例： `DOMAIN=https://toozhao.com`


### 支持的 Docker volume 属性
  * `/data` 用来放置所有下载的文件的目录
  * `/root/conf/key` 用户来放置 Aria2 SSL `certificate`证书和 `key` 文件. `注意`: 证书的名字必须是 `aria2.crt`， Key 文件的名字必须是 `aria2.key`
  * `/root/conf/aria2.conf` 为 aria2 的配置文件，你可以映射自己的配置文件。
  * `/root/filebrowser.db` File Browser 的内嵌数据库，升级Docker 镜像也不用担心之前的设置丢失。请确保在宿主机先创建一个空文件再使用。

## 自行构建镜像

```
docker build -t aria2-ui .
```

## Docker Hub

  <https://hub.docker.com/r/wahyd4/aria2-ui/>

## 使用 Docker compose 来运行

  请参考 <https://github.com/wahyd4/aria2-ariang-x-docker-compose>

## 常见问题

  1. 下载的BT或者磁力完全没有速度怎么办？ 建议先下载一个热门的BT种子文件，而不是磁力链接。这样可以帮助缓存DHT文件，渐渐地，速度就会起来了。比如试试下载树莓派操作系统的BT种子？[前往下载](https://www.raspberrypi.org/downloads/raspbian/)
