## Atrust Dokcer version

### 1. Dockerfile

```shell
docker build -t atrust .
```

### 2. Local Run

```shell
docker run -d --name atrust --privileged --net=host atrust
```

运行后docker中的atrust会在宿主机生成TUN网关，然后接管内网ip代理

> 宿主机需要用`ip a`来查看是否有utun网卡，同时可以用ip route看是否有路由接管

### 附：

可参考Distrobox运行环境

[README-Distrobox.md]: README-Distrobox.md

