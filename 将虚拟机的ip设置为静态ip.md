以下是将 CentOS 7 虚拟机的 IP 地址设置为静态 IP 的完整过程，包括前期准备、配置文件修改、故障排查和最终验证。请按照步骤操作，并注意每一步的提示。

### 前期准备

1. **获取当前网络信息**
   - 网络接口名称（如 `ens33`）
   - 当前 IP 地址
   - 子网掩码
   - 默认网关
   - DNS 服务器地址

2. **选择一个未被占用的静态 IP 地址**（例如 `192.168.30.128`）



### 步骤一：备份现有配置

在开始任何修改之前，请先备份你的网络配置文件：

```bash
sudo cp /etc/sysconfig/network-scripts/ifcfg-ens33 /etc/sysconfig/network-scripts/ifcfg-ens33.bak
```



### 步骤二：编辑网络配置文件

1. 使用文本编辑器打开网络配置文件：

    ```bash
    sudo vi /etc/sysconfig/network-scripts/ifcfg-ens33
    ```

2. 修改或添加以下内容：

    ```bash
    TYPE="Ethernet"
    PROXY_METHOD="none"
    BROWSER_ONLY="no"
    BOOTPROTO="static"  # 改为 static
    DEFROUTE="yes"
    IPV4_FAILURE_FATAL="no"
    IPV6INIT="yes"
    IPV6_AUTOCONF="yes"
    IPV6_DEFROUTE="yes"
    IPV6_FAILURE_FATAL="no"
    IPV6_ADDR_GEN_MODE="stable-privacy"
    NAME="ens33"
    UUID="your-network-interface-uuid"
    DEVICE="ens33"
    ONBOOT="yes"

    # 添加静态IP配置 ↓
    IPADDR=192.168.30.128  # 设置为你希望的固定IP
    NETMASK=255.255.255.0  # 根据实际情况调整
    GATEWAY=192.168.30.2   # 根据实际情况调整
    DNS1=8.8.8.8           # 主DNS
    DNS2=8.8.4.4           # 备用DNS
    ```



### 步骤三：检查 NetworkManager 和 network.service 的状态

为了避免 NetworkManager 和 network.service 之间的冲突，请确保两者不会同时管理同一个网络接口：

1. 检查 NetworkManager 是否正在运行：
   
    ```bash
    systemctl status NetworkManager
    ```

2. 如果 NetworkManager 正在运行，并且你不需要它，可以禁用并停止它：
   
    ```bash
    sudo systemctl stop NetworkManager
    sudo systemctl disable NetworkManager
    ```



### 步骤四：重启网络服务

保存配置文件后，重启网络服务以应用更改：

```bash
sudo systemctl restart network
```

如果遇到问题，可以尝试重新启动系统来强制加载新的网络配置。



### 步骤五：验证新配置是否生效

1. 检查新的 IP 地址是否已生效：

    ```bash
    ip addr show ens33
    ```

    你应该能看到类似如下输出：
    
    ```
    inet 192.168.30.128/24 brd 192.168.30.255 scope global ens33
    ```

2. 测试网络连通性：

    ```bash
    ping -c 4 8.8.8.8
    ```



### 步骤六：故障排查

如果重启网络服务失败或者无法连接到网络，请参考以下步骤进行故障排除：

1. 查看详细的错误日志：
   
    ```bash
    journalctl -xe
    ```

2. 检查是否有重复定义的网络配置文件：
   
    ```bash
    ls /etc/sysconfig/network-scripts/
    ```

3. 如果需要恢复到之前的配置，可以使用备份文件覆盖当前配置文件：

    ```bash
    sudo cp /etc/sysconfig/network-scripts/ifcfg-ens33.bak /etc/sysconfig/network-scripts/ifcfg-ens33
    sudo systemctl restart network
    ```

通过以上步骤，你应该能够成功地将 CentOS 7 虚拟机的 IP 地址设置为静态 IP。如果过程中遇到任何问题，可以通过查看详细的日志信息来进行进一步的诊断和解决。