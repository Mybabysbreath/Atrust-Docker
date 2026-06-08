#!/bin/bash

# 1. 基础环境变量
export USER=root
export HOME=/root
export DISPLAY=:99
export VNC_PORT=5999

# 2. 解决主机名识别问题
echo "127.0.0.1 $(hostname)" >> /etc/hosts
touch /root/.Xauthority

# 3. 启动 D-Bus (aTrust 必需)
mkdir -p /var/run/dbus
service dbus start

# 4. 【关键】强制清理残留的锁和套接字
# 即使屏幕号是 99，也要清理一次
vncserver -kill :99 || true
rm -rf /tmp/.X11-unix/X99 /tmp/.X99-lock /tmp/.X11-unix/X1 /tmp/.X1-lock

# 5. 【核心修复】以 99 号屏幕启动 VNC
# 使用 -localhost no 允许外部连接，-SecurityTypes VncAuth 强制密码
echo "Starting VNC server on :99 (Port 5999)..."
vncserver :99 \
    -geometry 1280x800 \
    -depth 24 \
    -localhost no \
    -SecurityTypes VncAuth

# 6. 启动窗口管理器
openbox-session &

# 7. 启动 aTrust 守护进程
echo "Starting aTrust services..."
/usr/share/sangfor/aTrust/resources/shell/aTrustDaemon.sh start
sleep 2

# 8. 启动 aTrust Agent
nohup /usr/share/sangfor/aTrust/resources/bin/aTrustAgent \
    --plugin plugins/aTrustCore \
    --enable-http \
    --enable-event-center > /tmp/agent.log 2>&1 &

# 9. 启动 aTrust UI
# 设置延迟确保 VNC 桌面已就绪
sleep 2
DISPLAY=:99 /usr/share/sangfor/aTrust/aTrustTray --no-sandbox &

echo "Success! Please connect to VNC at IP:5999"

tail -f /dev/null