#!/bin/bash

# 服务器关键信息检查脚本
# 适用于全新 Linux 服务器（CentOS/RHEL/Ubuntu/Debian）

echo "========================================="
echo "        服务器关键信息报告"
echo "========================================="

# 1. 系统基本信息
echo -e "\n[1] 操作系统版本"
lsb_release -d 2>/dev/null || cat /etc/redhat-release 2>/dev/null || cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2

echo -e "\n[2] 内核版本"
uname -a

echo -e "\n[3] 主机名"
hostname

# 2. CPU 信息
echo -e "\n[4] CPU 型号与核心数"
lscpu | grep "Model name" | head -1
echo "CPU 核心数: $(nproc)"

# 3. 内存信息
echo -e "\n[5] 内存总量与使用情况"
free -h

# 4. 磁盘与分区
echo -e "\n[6] 磁盘分区与挂载"
lsblk
echo -e "\n分区使用情况:"
df -hT

# 5. 网络配置
echo -e "\n[7] 网络接口与 IP 地址"
ip addr show | grep -E "inet " | grep -v "127.0.0.1" | awk '{print $2, $NF}'

echo -e "\n[8] 默认网关"
ip route | grep default

echo -e "\n[9] DNS 服务器"
cat /etc/resolv.conf | grep nameserver

# 6. 服务与端口
echo -e "\n[10] 监听端口 (TCP/UDP)"
ss -tuln | grep LISTEN

# 7. 已安装的重要软件包
echo -e "\n[11] 常见软件安装情况"
for pkg in docker nginx httpd mysql postgresql redis openssh-server fail2ban ufw iptables; do
    if command -v $pkg &>/dev/null || dpkg -l | grep -q $pkg 2>/dev/null || rpm -qa | grep -q $pkg 2>/dev/null; then
        echo "$pkg: 已安装"
    else
        echo "$pkg: 未安装"
    fi
done

# 8. 系统时间与时区
echo -e "\n[12] 当前时间与时区"
date
timedatectl 2>/dev/null || echo "timedatectl 不可用"

# 9. 最近登录记录
echo -e "\n[13] 最近 5 次成功登录"
last -n 5 2>/dev/null || echo "无法获取登录记录"

echo -e "\n[14] 失败的登录尝试 (最近 5 条)"
sudo grep "Failed password" /var/log/auth.log 2>/dev/null | tail -5 || \
sudo grep "Failed password" /var/log/secure 2>/dev/null | tail -5 || echo "无权限或无记录"

# 10. 系统负载与进程
echo -e "\n[15] 系统负载 (1,5,15分钟)"
uptime

echo -e "\n[16] 占用 CPU 最高的 5 个进程"
ps aux --sort=-%cpu | head -6

echo -e "\n[17] 占用内存最高的 5 个进程"
ps aux --sort=-%mem | head -6

# 11. 防火墙状态
echo -e "\n[18] 防火墙状态"
systemctl status ufw 2>/dev/null | grep Active || \
systemctl status firewalld 2>/dev/null | grep Active || \
echo "防火墙未启用或未识别"

# 12. SELinux (仅 RHEL 系)
if command -v getenforce &>/dev/null; then
    echo -e "\n[19] SELinux 状态"
    getenforce
fi

echo -e "\n========================================="
echo "        报告生成完成"
echo "========================================="