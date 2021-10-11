Aria2 + AriaNg

[English](https://github.com/wahyd4/aria2-ariang-docker/blob/master/README.md) | 简体中文

[![](https://images.microbadger.com/badges/image/wahyd4/aria2-ui.svg)](https://microbadger.com/images/wahyd4/aria2-ui "Get your own image badge on microbadger.com")
[![Docker Pulls](https://img.shields.io/docker/pulls/wahyd4/aria2-ui.svg)](https://hub.docker.com/r/wahyd4/aria2-ui/)
[![Github Build](https://github.com/wahyd4/aria2-ariang-docker/workflows/Docker%20Image%20CI/badge.svg)](https://github.com/wahyd4/aria2-ariang-docker/actions)

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/wahyd4/aria2-ariang-docker/tree/master)


[![Page Views Count](https://badges.toozhao.com/badges/01EJ791D8BB43PDS8D7PP7H0YE/green.svg)](https://badges.toozhao.com/stats/01EJ791D8BB43PDS8D7PP7H0YE "Get your own page views count badge on badges.toozhao.com")

<img src="https://raw.githubusercontent.com/wahyd4/work-in-australia/766592ac6318027d7b3c334d8c50ca80818eeff8/wepay.jpg" alt="buy me a drink" width="120"/>


本镜像包含 Aria2、AriaNg 和File Manager，主要方便那些用户期望只运行一个镜像就能实现图形化下载文件和在线播放文件。（类似离线下载的功能），只使用一个 Docker 镜像也方便用户在群晖NAS 中运行本程序。

- [功能特性](#功能特性)
- [推荐使用的docker image tag](#推荐使用的docker-image-tag)
- [安装与运行](#安装与运行)
  - [快速运行](#快速运行)
  - [开启所有功能](#开启所有功能)
  - [使用docker-compose 运行](#使用docker-compose-运行)
  - [支持的 Docker 环境变量](#支持的-docker-环境变量)
  - [支持的 Docker volume 属性](#支持的-docker-volume-属性)
- [自动 SSL](#自动-ssl)
- [自行构建镜像](#自行构建镜像)
- [Docker Hub](#docker-hub)
- [使用 Docker compose 来运行](#使用-docker-compose-来运行)
- [常见问题](#常见问题)

AriaNG
![Screenshot](https://github.com/wahyd4/aria2-ariang-x-docker-compose/raw/master/images/ariang.jpg)

File Browser
![File Browser](https://github.com/wahyd4/aria2-ariang-docker/raw/master/filemanager.png)

## 功能特性

  * [Aria2](https://aria2.github.io) 文件下载工具(支持SSL )
  * [AriaNg](https://github.com/mayswind/AriaNg) 通过 UI 来操作，下载文件
  * [Rclone](https://rclone.org) 同步文件到云盘
  * 自动 HTTPS （Let's Encrypt）
  * 支持绑定自定义用户ID，可以主机上的非`root`用户，也可以管理下载的文件
  * Basic Auth 用户认证
  * 文件管理和视频播放 ([FileBrowser](https://filebrowser.xyz/)，注意默认情况下，只能访问和管理 `/data` 目录下的文件)
  * 支持ARM CPU 架构，因此可以在树莓派等设备上运行，

## 推荐使用的docker image tag

* wahyd4/aria2-ui:latest

> Docker会为你自动选择对应CPU平台的image. e.g. arm64v8 或者 x86_64 平台

## 安装与运行

### 快速运行

```bash
  docker buildx build --platform linux/arm/v7,linux/arm64,linux/amd64 -t aria2-ui .
```

* Aria2: <http://yourip>
* Filebrowser: <http://yourip/files>
* Rclone: <http://yourip/rclone>
* 请使用 admin/admin 进行登录Filebrowser, 在如果没有修改`ARIA2_USER`,`ARIA2_PWD`的情况下，请使用`user`/`password`登录`Rclone`
### 开启所有功能
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
  -e ARIA2_PWD=pwd \
  -e ARIA2_EXTERNAL_PORT=443 \
  -v /yourdata:/data \
  -v /app/a.db:/app/filebrowser.db \
  -v /yoursslkeys/:/app/conf/key \
  -v <conf files folder>:/app/conf \
  wahyd4/aria2-ui
```
### 使用docker-compose 运行

如果你不想记住那些命令行，你也可以使用docker-compose来将配置放在`docker-compose.yaml`文件中
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
    volumes:
      - ./data:/data
```
然后使用 `docker-compose up -d` 运行即可

### 支持的 Docker 环境变量

  * `ENABLE_AUTH` 启用 Basic auth(网页简单认证) 用户认证
  * `ENABLE_RCLONE` 是否启用 RCLONE，由于Rclone 的初次运行需要从Github 下载文件，由于你懂的原因，可能文件下载失败，进而导致整个程序崩溃,这时你需要设置为`false`
  * `ARIA2_USER` Basic Auth 用户认证用户名，Rclone也使用该参数
  * `ARIA2_PWD` Basic Auth 密码，Rclone也使用该参数
  * `ARIA2_EXTERNAL_PORT` 从外部可以访问到的 Aria2 端口，默认为 HTTP 的`80`
  * `PUID` 需要绑定主机的Linux用户ID，可以通过`cat /etc/passwd` 查看用户列表， 默认UID 是`1000`
  * `PGID` 需要绑定的主机的Linux 用户组ID，默认GID 是`1000`
  * `RPC_SECRET` Aria2 RPC 加密 token
  * `DOMAIN` 绑定的域名, 当绑定的域名为`HTTPS`时，即为启用`HTTPS`， 例： `DOMAIN=https://toozhao.com`
  * `RCLONE_CONFIG_BASE64` 通过`base64` 字符串的形式配置rclone.conf。主要给在Heroku平台上运行时使用，请使用命令行 `cat /app/conf/rclone.conf | base64` 或者其他任何在线base64在线工具 [比如这个](https://www.base64encode.org/)来把`rclone.conf`的内容生成`base64`字符串。在使用本环境变量的同时，请确保`ENABLE_RCLONE`设置为`true`。

### 支持的 Docker volume 属性
  * `/data` 用来放置所有下载的文件的目录
  * `/app/conf/key` 用户来放置 Aria2 SSL `certificate`证书和 `key` 文件. `注意`: 证书的名字必须是 `aria2.crt`， Key 文件的名字必须是 `aria2.key`
  * `/app/conf` 该目录下可以放置你的自定义`aria2.conf`配置文件，`aria2.session`，且必须包含这两个文件。第一次使用`aria2.session`时，创建一个空文件即可，该文件会包含aria2当前的下载列表，这样即使容器被销毁也不用担心文件列表丢失了。你也可以直接拷贝当前项目下`conf`目录中的两个文件并使用。如需映射rclone.conf到容器内，请将其就放置于该目录下。因此配置文件目录支持的所有配置文件为：
    * aria2.conf
    * aria2.session
    * rclone.conf
  * `/app/filebrowser.db` File Browser 的内嵌数据库，升级Docker 镜像也不用担心之前的设置丢失。请确保在宿主机先创建一个空文件再使用。

## 自动 SSL

请在绑定域名前，设置`DNS`的一条`A`记录，将运行docker的主机IP绑定到该域名。然后你仅仅需要在运行时添加`e`设置即可。

```bash
docker run -d --name aria2-ui -p 80:80 -p 443:443 -e DOMAIN=https://toozhao.com wahyd4/aria2-ui
```

## 自行构建镜像

```
docker build -t aria2-ui .
```

## Docker Hub

  <https://hub.docker.com/r/wahyd4/aria2-ui/>

## 使用 Docker compose 来运行

  请参考 <https://github.com/wahyd4/aria2-ariang-x-docker-compose>

## 常见问题
  1. 当你以非其他`80` 端口或以启用了HTTPS`443`端口运行程序时，会出现`Aria2 状态 未连接`的错误，这是因为在最新版本里面，我们去掉aria2的独立6800端口，转而使用和网站同一个端口。你可以设置`ARIA2_EXTERNAL_PORT`后重建你的容器。
  2. 下载的BT或者磁力完全没有速度怎么办？ 建议先下载一个热门的BT种子文件，而不是磁力链接。这样可以帮助缓存DHT文件，渐渐地，速度就会起来了。比如试试下载树莓派操作系统的BT种子？[前往下载](https://www.raspberrypi.org/downloads/raspbian/)
  3. 如果你遇到了和 `setcap` 相关的错误，很大程度说明你说运行的Linux不支持使用非`root`用户来运行本Docker 镜像，因此请显式地设置环境变量`PUID`  `PGID` 为 `0` ，也就是使用`root` 来运行
  4. 如何配置`Rclone`? 如果你想连接`Google Drive` 类似的云存储平台，很遗憾你不能通过浏览器配置，因为网页版本`Oauth` 方式在这里是用不了的，你只能通过命令行的形式来配置，即`rclone config`. 详请请参考官网 [Configuring rclone on a remote / headless machine](https://rclone.org/remote_setup) 以及详细步骤请参考 [issue](https://github.com/wahyd4/aria2-ariang-docker/issues/118)
