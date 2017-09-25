Aria2 + AriaNg

[English](https://github.com/wahyd4/aria2-ariang-docker/blob/master/README.EN.md) | 简体中文

[![](https://images.microbadger.com/badges/image/wahyd4/aria2-ui.svg)](https://microbadger.com/images/wahyd4/aria2-ui "Get your own image badge on microbadger.com")

本镜像包含 Aria2、AriaNg 和File Manager，主要方便那些用户期望只运行一个镜像就能实现图形化下载文件和在线播放文件。（类似离线下载的功能），只使用一个 Docker 镜像也方便用户在群晖NAS 中运行本程序。

<!-- TOC -->

- [功能特性](#功能特性)
- [安装于运行](#安装于运行)
  - [快速运行](#快速运行)
  - [开启所有功能](#开启所有功能)
  - [支持的 Docker 环境变量](#支持的-docker-环境变量)
  - [支持的 Docker volume 属性](#支持的-docker-volume-属性)
- [Docker Hub](#docker-hub)
- [使用 Docker compose 来运行](#使用-docker-compose-来运行)

<!-- /TOC -->
Aria2
![Screenshot](https://github.com/wahyd4/aria2-ariang-x-docker-compose/raw/master/images/ariang.png)

File Manager
![Filemanager](https://github.com/wahyd4/aria2-ariang-docker/raw/master/filemanager.png)
## 功能特性

  * Aria2 (SSL 支持)
  * AriaNg 通过 UI 来操作，下载文件
  * 自动 HTTPS （Let's Encrypt）
  * Basic Auth 用户认证
  * 文件管理和视频播放 ([File Manager](https://henriquedias.com/filemanager/)，注意默认情况下，只能访问和管理 `/data` 目录下的文件)

## 安装于运行

### 快速运行

```shell
  docker run -d --name ariang -p 80:80 -p 6800:6800 wahyd4/aria2-ariang
```


### 开启所有功能
```shell
  docker run -d --name ariang -p 80:80 -p 6800:6800 -p 443:443 -e ENABLE_AUTH=true -e RPC_SECRET=Hello -e DOMAIN=example.com -e ARIA2_USER=user -e ARIA2_PWD=pwd -v /yourdata:/data -v /yoursslkeys/:/root/conf/key wahyd4/aria2-ariang
```

### 支持的 Docker 环境变量

  * ENABLE_AUTH 启用 Basic auth 用户认证
  * ARIA2_USER Basic Auth 用户认证用户名
  * ARIA2_PWD Basic Auth 密码
  * RPC_SECRET Aria2 RPC 加密 token
  * DOMAIN 绑定的域名


### 支持的 Docker volume 属性
  * `/data` 用来放置所有下载的文件的目录
  * `/root/conf/key` 用户来放置 Aria2 SSL `certificate`证书和 `key` 文件. `注意`: 证书的名字必须是 `aria2.crt`， Key 文件的名字必须是 `aria2.key`


## Docker Hub

  <https://hub.docker.com/r/wahyd4/aria2-ui/>

## 使用 Docker compose 来运行

  请参考 <https://github.com/wahyd4/aria2-ariang-x-docker-compose>
