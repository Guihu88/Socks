#!/bin/bash

# 检测到的国家
country=$(curl -s https://ipinfo.io/country)

# 定义 Shadowsocks 配置
ss_config_dir="/etc/shadowsocks-libev"
ss_config_file="$ss_config_dir/config.json"
ss_method="aes-256-gcm"

# 设置 DNS 服务器函数
set_dns_servers() {
    echo "清空原有 DNS 设置"
    echo -n | sudo tee /etc/resolv.conf

    echo "设置 DNS 服务器"
    for dns_server in "${dns_servers[@]}"; do
        echo "nameserver $dns_server" | sudo tee -a /etc/resolv.conf
    done

    if [ $? -ne 0 ]; then
        echo "更新 DNS 设置失败。"
        exit 1
    fi

    echo "DNS 设置已成功更新。"
}

# 安装 Shadowsocks 函数
install_shadowsocks() {
    sudo apt update
    sudo apt install -y shadowsocks-libev
}

# 创建 Shadowsocks 配置文件函数
create_ss_config() {
    sudo mkdir -p "$ss_config_dir"
    
    # 生成随机密码
    ss_password=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
    
    # 获取本机的公共 IP 地址
    public_ip=$(curl -s https://api64.ipify.org)
    
    # 写入 Shadowsocks 配置文件
    echo "{
        \"server\":\"$public_ip\",
        \"server_port\":$ss_port,
        \"password\":\"$ss_password\",
        \"method\":\"$ss_method\"
    }" | sudo tee "$ss_config_file"
    
    if [ $? -ne 0 ]; then
        echo "写入 Shadowsocks 配置文件失败。"
        exit 1
    fi
}

# 启动 Shadowsocks 函数
start_shadowsocks() {
    sudo systemctl start shadowsocks-libev
    
    if [ $? -ne 0 ]; then
        echo "启动 Shadowsocks 失败。"
        exit 1
    fi
    
    echo "Shadowsocks 已成功搭建并启动。"
    echo "Shadowsocks 配置链接：ss://$(echo -n "$ss_method:$ss_password@$public_ip:$ss_port" | base64 -w 0)"
}

# 主函数
main() {
    echo "检测到的国家：$country"
    
    case $country in
        "PH")
            dns_servers=("121.58.203.4" "8.8.8.8")
            ;;
        "VN")
            dns_servers=("183.91.184.14" "8.8.8.8")
            ;;
        "MY")
            dns_servers=("49.236.193.35" "8.8.8.8")
            ;;
        "TH")
            dns_servers=("61.19.42.5" "8.8.8.8")
            ;;
        "ID")
            dns_servers=("202.43.162.37" "8.8.8.8")
            ;;
        "TW")
            dns_servers=("168.95.1.1" "8.8.8.8")
            ;;
        *)
            echo "未识别的国家或不在列表中。"
            exit 1
            ;;
    esac
    
    # 生成随机端口
    ss_port=$(shuf -i 10000-65535 -n 1)
    
    # 设置 DNS 服务器
    set_dns_servers
    
    # 安装 Shadowsocks
    install_shadowsocks
    
    # 创建 Shadowsocks 配置文件
    create_ss_config
    
    # 启动 Shadowsocks
    start_shadowsocks
}

# 执行主函数
main
