# iptables 完全指南



## 一、iptables 架构概述

### 1.1 核心概念

- **iptables**: 用户空间工具，用于配置防火墙规则
- **netfilter**: 内核空间框架，实际执行规则
- 工作模式：用户命令 → netfilter内核模块 → 处理数据包

### 1.2 数据包处理流程

```
网络数据包 → 网卡驱动 → netfilter框架（四表五链） → 本地进程/转发
```



## 二、四表五链架构

### 2.1 四表详解

| 表名       | 功能                                 | 包含链                          | 优先级顺序 |
| :--------- | :----------------------------------- | :------------------------------ | :--------- |
| **raw**    | 连接跟踪前处理，决定是否跳过状态跟踪 | PREROUTING, OUTPUT              | 1          |
| **mangle** | 修改数据包（TTL、TOS、MARK等）       | 所有五个链                      | 2          |
| **nat**    | 网络地址转换（SNAT、DNAT）           | PREROUTING, POSTROUTING, OUTPUT | 3          |
| **filter** | 数据包过滤（默认表）                 | INPUT, FORWARD, OUTPUT          | 4          |

### 2.2 五链详解

| 链名            | 触发时机                 | 主要用途           | 涉及表                   |
| :-------------- | :----------------------- | :----------------- | :----------------------- |
| **PREROUTING**  | 数据包进入后，路由决策前 | DNAT、mangle标记   | raw, mangle, nat         |
| **INPUT**       | 路由后，目标是本机       | 过滤进入本机的包   | mangle, filter           |
| **FORWARD**     | 路由后，需要转发         | 过滤转发的包       | mangle, filter           |
| **OUTPUT**      | 本机产生的包发出前       | 过滤发出的包、SNAT | raw, mangle, nat, filter |
| **POSTROUTING** | 数据包离开前，路由决策后 | SNAT、mangle标记   | mangle, nat              |



## 三、iptables 参数详解表

### 3.1 表选择参数

| 参数   | 全称    | 功能         | 示例                 | 备注         |
| :----- | :------ | :----------- | :------------------- | :----------- |
| **-t** | --table | 指定操作的表 | `iptables -t nat -L` | 默认：filter |

### 3.2 链管理参数

| 参数   | 全称           | 功能           | 示例                     | 备注               |
| :----- | :------------- | :------------- | :----------------------- | :----------------- |
| **-P** | --policy       | 设置链默认策略 | `iptables -P INPUT DROP` | ACCEPT/DROP/REJECT |
| **-F** | --flush        | 清空链规则     | `iptables -F INPUT`      | 不指定链则清空所有 |
| **-N** | --new-chain    | 创建自定义链   | `iptables -N MYCHAIN`    | 链名最多31字符     |
| **-X** | --delete-chain | 删除自定义链   | `iptables -X MYCHAIN`    | 需先清空规则       |
| **-E** | --rename-chain | 重命名自定义链 | `iptables -E OLD NEW`    | 仅限自定义链       |
| **-Z** | --zero         | 计数器清零     | `iptables -Z`            | 可指定链           |

### 3.3 规则管理参数

| 参数   | 全称      | 功能               | 示例                            | 备注         |
| :----- | :-------- | :----------------- | :------------------------------ | :----------- |
| **-A** | --append  | 追加规则到链尾     | `iptables -A INPUT -j ACCEPT`   | 最常用       |
| **-I** | --insert  | 插入规则到指定位置 | `iptables -I INPUT 1 -j ACCEPT` | 位置从1开始  |
| **-D** | --delete  | 删除规则           | `iptables -D INPUT 1`           | 按编号或内容 |
| **-R** | --replace | 替换规则           | `iptables -R INPUT 2 -j DROP`   | 保持位置不变 |

### 3.4 匹配条件参数

| 参数        | 全称               | 功能         | 示例                      | 依赖条件                   |
| :---------- | :----------------- | :----------- | :------------------------ | :------------------------- |
| **-s**      | --source           | 源IP匹配     | `iptables -s 192.168.1.1` | 支持CIDR                   |
| **-d**      | --destination      | 目标IP匹配   | `iptables -d 10.0.0.1`    | 支持CIDR                   |
| **-p**      | --protocol         | 协议匹配     | `iptables -p tcp`         | tcp/udp/icmp/all           |
| **--sport** | --source-port      | 源端口匹配   | `iptables --sport 80`     | 需配合-p tcp/udp           |
| **--dport** | --destination-port | 目标端口匹配 | `iptables --dport 22`     | 需配合-p tcp/udp           |
| **-i**      | --in-interface     | 入站接口匹配 | `iptables -i eth0`        | PREROUTING/INPUT/FORWARD   |
| **-o**      | --out-interface    | 出站接口匹配 | `iptables -o eth1`        | FORWARD/OUTPUT/POSTROUTING |

### 3.5 目标动作参数（-j）

| 动作           | 功能                     | 适用表 | 示例                            |
| :------------- | :----------------------- | :----- | :------------------------------ |
| **ACCEPT**     | 接受数据包               | filter | `-j ACCEPT`                     |
| **DROP**       | 丢弃数据包（无响应）     | filter | `-j DROP`                       |
| **REJECT**     | 拒绝数据包（发送拒绝包） | filter | `-j REJECT`                     |
| **RETURN**     | 返回调用链               | 所有表 | `-j RETURN`                     |
| **LOG**        | 记录日志                 | 所有表 | `-j LOG --log-prefix "DROP:"`   |
| **DNAT**       | 目标地址转换             | nat    | `-j DNAT --to 192.168.1.100:80` |
| **SNAT**       | 源地址转换               | nat    | `-j SNAT --to 1.2.3.4`          |
| **MASQUERADE** | 动态SNAT（拨号环境）     | nat    | `-j MASQUERADE`                 |
| **REDIRECT**   | 端口重定向               | nat    | `-j REDIRECT --to-ports 8080`   |

### 3.6 扩展模块参数（-m）

| 模块          | 功能         | 常用选项                | 示例                                         |
| :------------ | :----------- | :---------------------- | :------------------------------------------- |
| **state**     | 连接状态匹配 | --state NEW/ESTABLISHED | `-m state --state ESTABLISHED`               |
| **multiport** | 多端口匹配   | --dports/--sports       | `-m multiport --dports 22,80,443`            |
| **limit**     | 限制匹配速率 | --limit                 | `-m limit --limit 5/min`                     |
| **mac**       | MAC地址匹配  | --mac-source            | `-m mac --mac-source 00:11:22:33:44:55`      |
| **time**      | 时间匹配     | --timestart/--timestop  | `-m time --timestart 09:00 --timestop 18:00` |
| **connlimit** | 连接数限制   | --connlimit-above       | `-m connlimit --connlimit-above 10`          |
| **string**    | 字符串匹配   | --string/--algo         | `-m string --string "badword" --algo bm`     |

### 3.7 显示选项参数

| 参数               | 全称      | 功能               | 示例                         |
| :----------------- | :-------- | :----------------- | :--------------------------- |
| **-L**             | --list    | 列出规则           | `iptables -L`                |
| **-v**             | --verbose | 显示详细信息       | `iptables -L -v`             |
| **-n**             | --numeric | 数字显示（不解析） | `iptables -L -n`             |
| **--line-numbers** |           | 显示行号           | `iptables -L --line-numbers` |
| **-x**             | --exact   | 显示精确计数值     | `iptables -L -x`             |



## 四、状态跟踪机制

### 4.1 四种连接状态

```
# 状态类型说明
NEW         # 新建连接的第一个包
ESTABLISHED # 已建立的连接
RELATED     # 相关连接（如FTP数据连接）
INVALID     # 无法识别的连接
```



### 4.2 状态规则示例

```
# 允许已建立和相关连接
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# 限制新连接速率
iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m limit --limit 3/min -j ACCEPT
```



## 五、实用配置示例

### 5.1 基础服务器防火墙

```
#!/bin/bash
# 初始化
iptables -F
iptables -X
iptables -Z

# 默认策略
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# 允许本地回环
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# 允许已建立的连接
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# 允许ICMP（ping）
iptables -A INPUT -p icmp -j ACCEPT

# 开放服务端口
services=(22 80 443 53)
for port in "${services[@]}"; do
    iptables -A INPUT -p tcp --dport $port -j ACCEPT
done

# 允许DNS查询
iptables -A INPUT -p udp --dport 53 -j ACCEPT

# 记录拒绝的包（限制频率）
iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables denied: "
```



### 5.2 NAT网关配置

```
#!/bin/bash
# 启用IP转发
echo 1 > /proc/sys/net/ipv4/ip_forward

# 清空NAT表
iptables -t nat -F
iptables -t nat -X

# MASQUERADE：内网访问外网
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o eth0 -j MASQUERADE

# DNAT：端口映射
iptables -t nat -A PREROUTING -p tcp -d 203.0.113.1 --dport 80 -j DNAT --to 192.168.1.100:80
iptables -t nat -A PREROUTING -p tcp -d 203.0.113.1 --dport 2222 -j DNAT --to 192.168.1.100:22

# 允许转发
iptables -A FORWARD -i eth1 -o eth0 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i eth0 -o eth1 -m state --state ESTABLISHED,RELATED -j ACCEPT
```



### 5.3 防攻击规则

```
# 防SYN洪水攻击
iptables -A INPUT -p tcp --syn -m limit --limit 1/s --limit-burst 3 -j ACCEPT
iptables -A INPUT -p tcp --syn -j DROP

# 防ping洪水
iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s -j ACCEPT

# 防SSH暴力破解
iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --set --name SSH
iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 4 --name SSH -j DROP
```



## 六、规则管理技巧

### 6.1 查看规则技巧

```
# 查看filter表所有规则（带行号）
iptables -L -n --line-numbers

# 查看NAT表规则（详细）
iptables -t nat -L -v -n

# 查看指定链规则
iptables -L INPUT -n -v

# 查看计数器
iptables -L -v -x
```



### 6.2 规则编辑技巧

```
# 1. 备份当前规则
iptables-save > /etc/iptables.backup

# 2. 插入规则到指定位置
iptables -I INPUT 3 -s 10.0.0.0/8 -j ACCEPT

# 3. 替换规则
iptables -R INPUT 2 -s 192.168.1.0/24 -j ACCEPT

# 4. 批量删除规则
for i in $(iptables -L INPUT --line-numbers | grep DROP | awk '{print $1}' | tac); do
    iptables -D INPUT $i
done

# 5. 测试规则（不永久生效）
iptables-restore --test < rules.conf
```



### 6.3 调试规则

```
# 临时添加日志规则
iptables -I INPUT 1 -j LOG --log-prefix "INPUT packet: "

# 查看日志
tail -f /var/log/messages | grep iptables
# 或
dmesg | grep iptables

# 跟踪特定连接
iptables -t raw -A PREROUTING -p tcp --dport 80 -j TRACE
```



## 七、持久化配置

### 7.1 不同发行版的保存方式

```
# CentOS/RHEL 6及以前
service iptables save        # 保存到 /etc/sysconfig/iptables
service iptables restart

# CentOS/RHEL 7+
yum install iptables-services
systemctl enable iptables
iptables-save > /etc/sysconfig/iptables
systemctl restart iptables

# Ubuntu/Debian
apt-get install iptables-persistent
iptables-save > /etc/iptables/rules.v4  # IPv4
ip6tables-save > /etc/iptables/rules.v6 # IPv6

# 通用方法
iptables-save > /etc/iptables.rules
echo "pre-up iptables-restore < /etc/iptables.rules" >> /etc/network/interfaces
```



### 7.2 开机自动加载

```
# 方法1：rc.local（不推荐新系统）
iptables-restore < /etc/iptables.rules

# 方法2：创建systemd服务
cat > /etc/systemd/system/iptables.service << EOF
[Unit]
Description=Restore iptables rules
Before=network-pre.target
Wants=network-pre.target

[Service]
Type=oneshot
ExecStart=/sbin/iptables-restore /etc/iptables.rules

[Install]
WantedBy=multi-user.target
EOF

systemctl enable iptables.service
```



## 八、性能优化建议

### 8.1 规则顺序优化

```
# 原则：高频规则在前，低频规则在后
# 1. 先放行已建立连接（最高频）
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# 2. 再放行常用服务
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# 3. 最后是拒绝规则
iptables -A INPUT -j DROP
```



### 8.2 使用ipset处理大规则集

```
# 创建ipset集合
ipset create bad_ips hash:ip timeout 300
ipset add bad_ips 1.2.3.4
ipset add bad_ips 5.6.7.8

# 在iptables中使用
iptables -A INPUT -m set --match-set bad_ips src -j DROP
```



### 8.3 连接跟踪优化

```
# 调整连接跟踪表大小
echo 65536 > /proc/sys/net/netfilter/nf_conntrack_max
echo 120 > /proc/sys/net/netfilter/nf_conntrack_tcp_timeout_established
```



## 九、故障排查

### 9.1 常见问题

```
# 1. 规则不生效
# 检查顺序：iptables -L -n --line-numbers
# 检查默认策略：iptables -L | grep policy

# 2. 无法保存规则
# 检查权限：sudo iptables-save
# 检查iptables服务状态

# 3. NAT不工作
# 检查转发是否开启：cat /proc/sys/net/ipv4/ip_forward
# 检查MASQUERADE规则位置：应在POSTROUTING链

# 4. 连接被拒绝
# 检查state模块规则
# 检查RELATED连接是否允许
```



### 9.2 诊断命令

```
# 查看所有规则和计数器
iptables -L -n -v

# 查看NAT表规则
iptables -t nat -L -n -v

# 查看连接跟踪表
conntrack -L
cat /proc/net/nf_conntrack

# 数据包跟踪
tcpdump -i eth0 port 80
```



## 十、迁移到nftables

### 10.1 转换工具

```
# 将iptables规则转换为nftables
iptables-save > iptables.rules
iptables-restore-translate -f iptables.rules > nftables.rules

# 加载nftables规则
nft -f nftables.rules
```



### 10.2 兼容模式

```
# 使用iptables-over-nftables
update-alternatives --set iptables /usr/sbin/iptables-nft
update-alternatives --set ip6tables /usr/sbin/ip6tables-nft
```



------

## 附录：速查表

### A. 常用端口对照

| 端口 | 协议    | 服务  |
| :--- | :------ | :---- |
| 22   | TCP     | SSH   |
| 25   | TCP     | SMTP  |
| 53   | TCP/UDP | DNS   |
| 80   | TCP     | HTTP  |
| 443  | TCP     | HTTPS |
| 3306 | TCP     | MySQL |



### B. 快速参考命令

```
# 基本模板
iptables -A <链> -p <协议> --dport <端口> -s <源IP> -d <目标IP> -j <动作>

# 允许SSH
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# 允许ping
iptables -A INPUT -p icmp -j ACCEPT

# 端口转发
iptables -t nat -A PREROUTING -p tcp --dport 8080 -j REDIRECT --to-port 80
```



### C. 配置文件示例

```
# /etc/iptables/rules.v4
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -i lo -j ACCEPT
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -p tcp --dport 22 -j ACCEPT
-A INPUT -p tcp --dport 80 -j ACCEPT
-A INPUT -p tcp --dport 443 -j ACCEPT
-A INPUT -j LOG --log-prefix "iptables denied: "
COMMIT
```