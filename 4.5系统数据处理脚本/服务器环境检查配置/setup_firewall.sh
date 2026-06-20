#!/bin/bash

echo "========================================="
echo "        防火墙配置脚本"
echo "========================================="

# 检查是否以 root 运行
if [ "$EUID" -ne 0 ]; then 
    echo "请使用 root 权限运行: sudo $0"
    exit 1
fi

# 1. 安装 firewalld（如果未安装）
if ! command -v firewall-cmd &> /dev/null; then
    echo "安装 firewalld..."
    yum install -y firewalld
fi

# 2. 启动防火墙
echo "启动 firewalld..."
systemctl start firewalld
systemctl enable firewalld

# 3. 配置默认区域
echo "配置默认区域..."
firewall-cmd --set-default-zone=public

# 4. 开放 SSH（必须）
echo "开放 SSH 服务..."
firewall-cmd --add-service=ssh --permanent

# 5. 可选：开放其他常用服务（根据需要取消注释）
# echo "开放 HTTP/HTTPS 服务..."
# firewall-cmd --add-service=http --permanent
# firewall-cmd --add-service=https --permanent

# 6. 重载配置
echo "重载防火墙配置..."
firewall-cmd --reload

# 7. 显示当前配置
echo ""
echo "========================================="
echo "        防火墙当前配置"
echo "========================================="
firewall-cmd --list-all

echo ""
echo "✅ 防火墙配置完成！"
echo "当前开放的端口/服务:"
firewall-cmd --list-services