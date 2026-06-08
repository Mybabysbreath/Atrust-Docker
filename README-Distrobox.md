## Distrobox运行aTrust

### 1. 创建容器

```
# 加上 --root（以 root 权限运行，以便修改路由表），增加 udev 解决设备访问问题，增加 libasound2t64 (24.04 新包名)，增加libproxy1v5解决新版核心服务启动问题
distrobox create --root --name atrust-box \
    --image ubuntu:24.04 \
    --init \
    --additional-packages "systemd libpam-systemd dbus udev libasound2t64 libproxy1v5" \
    --additional-flags "--privileged"
```

### 2. 进入容器安装依赖库

**解决 Spa seed out of time **

```
distrobox enter --root atrust-box

# 进入后，强制同步时区为上海
sudo ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
# 验证时间
date

# Ubuntu 24.04 的一些库文件名有变动，运行以下命令补齐 aTrust 所需的 UI 和系统环境：
sudo apt update && sudo apt install -y libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 \
    libxkbcommon0 libxcomposite1 libxdamage1 libxrandr2 libgbm1 \
    libpango-1.0-0 libcairo2 libasound2t64 libxtst6 libxshmfence1 \
    libnss3-dev net-tools iproute2 iptables \
    libqt5dbus5t64 libqt5core5t64 libqt5gui5t64 libqt5widgets5t64 libqt5network5t64 \
    libxss1 libxtst6 libxshmfence1 libxrender1 libxext6 libxft2 libdbus-1-3 libgtk-3-0
```

### 3. 安装 aTrust 

官网下载：https://atrustcdn.sangfor.com/standard/linux/2.5.16.30/ubuntu/amd64/aTrustInstaller_amd64.deb

```shell
sudo dpkg -i aTrustInstaller_amd64.deb
```

### 4. 启动服务

```
# 默认自启
sudo systemctl start aTrustDaemon

# ps -ef | grep aTrust 如果没以下命令，需要手动运行
nohup /usr/share/sangfor/aTrust/resources/bin/aTrustAgent --plugin plugins/aTrustCore --enable-http --enable-event-center &

# 启动aTrust客户端
/usr/share/sangfor/aTrust/aTrustTray --no-sandbox
```

> 宿主机需要用`ip a`来查看是否有utun网卡，同时可以用ip route看是否有路由接管

>DNS 解析内网域名失败: aTrust 通常会修改 /etc/resolv.conf。但 Fedora 默认使用 systemd-resolved 托管 DNS。如果发现能 Ping 通内网 IP，但打不开内网域名，请在 Fedora 宿主机上临时修改 DNS，或者直接使用域名对应的内网ip进行访问

------