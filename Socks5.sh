#!/bin/bash

# 检查代理是否已过期
check_proxy_expiration() {
    current_date=$(date +"%Y-%m-%d")
    expiration_date=$(cat /etc/socks_expiration.txt | grep "到期时间：" | cut -d ' ' -f 3)
    
    if [[ "$current_date" > "$expiration_date" ]]; then
        echo "代理已过期，请重新搭建。"
        exit 1
    fi
}

# 安装Privoxy和dante-server
apt-get update
apt-get install -y privoxy dante-server

# 配置Privoxy
echo 'forward-socks5 / 127.0.0.1:1080 .' >> /etc/privoxy/config

# 生成随机的SOCKS用户名和密码
socks_username=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8)
socks_password=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 12)

# 创建dante-server的认证文件
echo "$socks_username:$(openssl passwd -crypt $socks_password)" > /etc/danted.conf

# 启动Privoxy和dante-server
service privoxy restart
service danted restart

# 用户指定代理端口
read -p "请输入代理端口: " proxy_port

# 用户指定到期天数
read -p "请输入代理到期天数: " expiration_days
expiration_date=$(date -d "+$expiration_days days" +"%Y-%m-%d")

echo "SOCKS代理已搭建完成。"
echo "用户名：$socks_username"
echo "密码：$socks_password"
echo "端口：$proxy_port"
echo "到期时间：$expiration_date"

echo "到期时间：$expiration_date" > /etc/socks_expiration.txt

# 配置防火墙规则，允许指定的代理端口
iptables -A INPUT -p tcp --dport $proxy_port -j ACCEPT
iptables-save > /etc/iptables/rules.v4

# 检查代理是否已过期
check_proxy_expiration
