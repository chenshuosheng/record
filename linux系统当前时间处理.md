```shell
格式化获取当前系统时间：date "+%Y-%m-%d %H:%M:%S"

获取硬件时钟时间：sudo hwclock --show

同步硬件时钟和系统时间

方法 1：将硬件时钟同步到系统时间
如果硬件时钟是正确的，可以将硬件时钟的时间写入系统时间：
sudo hwclock --hctosys

方法 2：将系统时间同步到硬件时钟
如果当前系统时间是正确的，可以将系统时间写入硬件时钟：
sudo hwclock --systohc

强制启用 NTP 自动同步
如果希望系统时间自动与互联网时间服务器同步，可以启用 NTP 服务。
sudo timedatectl set-ntp true

检查同步状态：
timedatectl status


强制重新同步时间：
尝试手动触发时间同步：
sudo systemctl restart systemd-timesyncd

或者：

sudo chronyc makestep
```





```shell
[root@manager dynamic_template]# sudo timedatectl set-time " 2025-04-27 17:56:00"
Failed to set time: Automatic time synchronization is enabled

出现这个错误是因为系统启用了自动时间同步（NTP），导致无法手动设置时间。要解决这个问题，你需要先禁用自动时间同步，然后再手动设置时间。

以下是具体步骤：
1. 检查当前时间同步状态
运行以下命令查看当前的时间同步状态：
timedatectl status

在输出中，查找以下字段：
System clock synchronized：如果显示 yes，表示系统时间已同步。
NTP service：如果显示 active，表示 NTP 服务正在运行。

2. 禁用自动时间同步
使用以下命令禁用自动时间同步：
sudo timedatectl set-ntp false
再次检查状态以确认 NTP 已被禁用：

timedatectl status
此时，NTP service 应该显示为 inactive。

3. 手动设置时间
现在可以手动设置时间了：
sudo timedatectl set-time "2025-04-03 09:30:07"

4. （可选）重新启用自动时间同步
如果希望重新启用自动时间同步，可以运行以下命令：
sudo timedatectl set-ntp true
这将重新激活 NTP 服务，并自动校准时间。

！！！其他注意事项
如果系统使用的是 chrony 或 ntp 而不是 systemd-timesyncd，需要停止相关服务才能手动设置时间。例如：

sudo systemctl stop chronyd
或

sudo systemctl stop ntp
修改时间可能会影响依赖时间的服务或应用程序，请谨慎操作。
```

