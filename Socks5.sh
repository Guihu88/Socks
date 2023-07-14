#!/bin/bash

# 备份原始配置文件
cp /etc/network/interfaces.d/50-cloud-init /etc/network/interfaces.d/50-cloud-init.bak

# 新的DNS服务器地址
new_dns_servers="8.8.8.8 8.8.4.4"

# 替换dns-nameservers行
sed -i "/^dns-nameservers/c\dns-nameservers $new_dns_servers" /etc/network/interfaces.d/50-cloud-init

# 重启网络服务
systemctl restart networking
