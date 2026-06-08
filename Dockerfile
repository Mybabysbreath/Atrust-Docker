FROM ubuntu:24.04

# 避免交互提问
ENV DEBIAN_FRONTEND=noninteractive

# 拷贝aTrust
COPY aTrustInstaller_amd64.deb /tmp/atrust.deb
COPY entrypoint.sh /entrypoint.sh

    # 1. 设置时区 (解决 Spa seed out of time 问题)
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    # 2. 安装基础环境和 VNC/UI 相关组件，--no-install-recommends会跳过非核心依赖，比如中文支持
    apt-get update && apt-get install -y --no-install-recommends \
    tzdata \
    tigervnc-tools \
    tigervnc-standalone-server tigervnc-common \
    openbox dbus-x11 x11-xserver-utils \
    net-tools iproute2 iptables ca-certificates sudo wget \
    # 3. 安装 aTrust 必需的依赖 (结合你提供的 MD 列表，适配 24.04 的 t64 包名)
    libproxy1v5 libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 \
    libxkbcommon0 libxcomposite1 libxdamage1 libxrandr2 libgbm1 \
    libpango-1.0-0 libcairo2 libasound2t64 libxtst6 libxshmfence1 \
    libnss3-dev libqt5dbus5t64 libqt5core5t64 libqt5gui5t64 \
    libqt5widgets5t64 libqt5network5t64 \
    libxss1 libxrender1 libxext6 libxft2 libdbus-1-3 libgtk-3-0 && \
    # 4. 安装 aTrust (使用 apt 安装本地包以自动补全缺失依赖)
    apt install -y /tmp/atrust.deb || apt-get install -f -y && \
    rm /tmp/atrust.deb && \
    apt-get purge -y --auto-remove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    # 5. 配置 VNC 密码 (123456)
    mkdir -p ~/.vnc && \
    echo "123456" | vncpasswd -f > ~/.vnc/passwd && \
    chmod 600 ~/.vnc/passwd && \
    # 6. 启动脚本
    chmod +x /entrypoint.sh

EXPOSE 5901

ENTRYPOINT ["/entrypoint.sh"]

# docker run -d --name atrust --privileged --net=host atrust