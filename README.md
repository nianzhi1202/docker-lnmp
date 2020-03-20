# docker-lnmp
基于docker-compose搭建的lnmp环境

LNMP（Docker + Docker-compose + Nginx + MySQL5.7 + PHP7.2 + Redis5.0 + Memcached1.5 + Mongodb4.2）

LNMP项目特点：
1. `100%`开源，不含脚本运行，易学实用
2. `100%`遵循Docker标准
3. 支持数据文件、配置文件、日志文件挂载
4. 默认支持`pdo_mysql`、`mysqli`、`swoole`、`gd`、`curl`、`opcache`等常用扩展
5. 包含基本的配置文件

## 1.目录结构

```
/
├── data                        数据库数据目录
│   ├── mongo                   MongoDB 数据目录
│   ├── mysql                   MySQL 数据目录
│   └── redis                   Redis 数据目录
├── services                    服务构建文件、配置文件目录
│   ├── mysql                   MySQL8 配置、构建文件
│   ├── nginx                   Nginx 配置、构建文件
│   ├── php                     PHP 配置、构建文件
│   ├── memcached               Memcached 配置、构建文件
│   ├── mongo                   Mongo 配置、构建文件
│   └── redis                   Redis 配置、构建文件
├── logs                        日志目录
│   └── mysql                   
│   └── nginx                   
│   └── php                   
│   └── memcached                   
│   └── mongo                   
│   └── redis                   
├── docker-compose.yml         Docker 服务配置示例文件
├── .env                       环境配置
└── www                        PHP 代码目录 可在.env中nginx的WEB_DIR中任意指定
```

## 2.快速使用
1. 本地安装
    docker、docker-compose

2. clone项目：
    $ https://github.com/nianzhi1202/docker-lnmp.git

3. 如果不是root用户，还需将当前用户加入docker用户组：
    $ sudo gpasswd -a ${USER} docker

4. 可根据项目需要自行添加其它php扩展 

5. 启动本项目
$ docker-compose up --build --force-recreate  #可以加 -d 后台运行，调试时不用加，方便查看日志


## 3.docker常用命令
$ systemctl start docker                      # 启动docker   
$ docker start containername                  # 启动容器
$ docker stop containername                   # 停止容器    
$ docker exec -it 13a676bb9bff /bin/bash      # 进入容器 此模式下输入mongo即可进入mongo
$ docker rm containername                     # 删除容器
$ docker rmi image                            # 删除镜像

$ docker-compose up                           # 启动所有容器
$ docker-compose up nginx php mysql           # 启动指定容器
$ docker-compose up -d nginx php  mysql       # 后台运行方式启动指定容器
$ docker-compose up --build --force-recreate  # 强制启动

$ docker-compose start php                    # 启动服务
$ docker-compose stop php                     # 停止服务
$ docker-compose restart php                  # 重启服务
$ docker-compose build php                    # 使用Dockerfile构建服务

​

