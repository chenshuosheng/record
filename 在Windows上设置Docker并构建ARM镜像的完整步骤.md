## 1. 安装WSL Linux发行版

```shell
PS C:\Users\Administrator> wsl --install
版权所有(c) Microsoft Corporation。保留所有权利。

用法: wsl.exe [Argument] [Options...] [CommandLine]

运行 Linux 二进制文件的参数:

    如果未提供命令行，wsl.exe 将启动默认 shell。

    --exec, -e <CommandLine>
        在不使用默认 Linux Shell 的情况下执行指定的命令。

    --
        按原样传递其余命令行。

选项:
    --cd <Directory>
        将指定目录设置为当前工作目录。
        如果使用了 ~，则将使用 Linux 用户的主页路径。如果路径
        以 / 字符开头，将被解释为绝对 Linux 路径。
        否则，该值一定是绝对 Windows 路径。

    --distribution, -d <Distro>
        运行指定分发。

    --user, -u <UserName>
        以指定用户身份运行。

管理适用于 Linux 的 Windows 子系统的参数:

    --help
        显示用法信息。

    --install [选项]
        安装额外的适用于 Linux 的 Windows 子系统分发。
         要获得有效分发列表，请使用“wsl --list --online”。

        选项:
            --distribution, -d [参数]
                按名称下载并安装分发。

                参数:
                    有效分发名称(不区分大小写)。

                示例:
                    wsl --install -d Ubuntu
                    wsl --install --distribution Debian

    --set-default-version <Version>
        更改新分发的默认安装版本。

    --shutdown
         立即终止所有运行的分发及 WSL 2
        轻型实用工具虚拟机。

    --status
        显示适用于 Linux 的 Windows 子系统的状态。

    --update [Options]
        如果未指定任何选项，则将 WSL 2 内核更新
        为最新版本。

        选项:
            --rollback
                恢复为 WSL 2 内核的先前版本。

            --inbox
                仅更新收件箱 WSL 2 内核。不要从 Microsoft Store 下载 WSL。

            --web-download
                从 Internet 而不是 Microsoft Store 下载最新版本的 WSL。

用于管理适用于 Linux 的 Windows 子系统中的分发的参数:

    --export <Distro> <FileName>
        将分发导出到 tar 文件。
        对于标准输出，文件名可以是 -。

    --import <Distro> <InstallLocation> <FileName> [Options]
        将指定的 tar 文件作为新分发导入。
        对于标准输入，文件名可以是 -。

        选项:
            --version <Version>
                指定要用于新分发的版本。

    --list, -l [Options]
        列出分发。

        选项:
            --all
                列出所有分发，包括
                当前正在安装或卸载的分发。

            --running
                仅列出当前正在运行的分发。

            --quiet, -q
                仅显示分发名称。

            --verbose, -v
                显示所有分发的详细信息。

            --online, -o
                显示使用“wsl --install”进行安装的可用分发列表。

    --set-default, -s <分发>
        将分发设置为默认值。

    --set-version <分发> <版本>
        更改指定分发的版本。

    --terminate, -t <分发>
        终止指定的分发。

    --unregister <分发>
        注销分发并删除根文件系统。
PS C:\Users\Administrator> wsl.exe --list --online
以下是可安装的有效分发的列表。
请使用“wsl --install -d <分发>”安装。

NAME                            FRIENDLY NAME
Ubuntu                          Ubuntu
Debian                          Debian GNU/Linux
kali-linux                      Kali Linux Rolling
Ubuntu-20.04                    Ubuntu 20.04 LTS
Ubuntu-22.04                    Ubuntu 22.04 LTS
Ubuntu-24.04                    Ubuntu 24.04 LTS
OracleLinux_7_9                 Oracle Linux 7.9
OracleLinux_8_10                Oracle Linux 8.10
OracleLinux_9_5                 Oracle Linux 9.5
openSUSE-Leap-15.6              openSUSE Leap 15.6
SUSE-Linux-Enterprise-15-SP6    SUSE Linux Enterprise 15 SP6
openSUSE-Tumbleweed             openSUSE Tumbleweed


PS C:\Users\Administrator> wsl --install -d Ubuntu-22.04
正在安装: Ubuntu 22.04 LTS
已安装 Ubuntu 22.04 LTS。
正在启动 Ubuntu 22.04 LTS…
PS C:\Users\Administrator>
PS C:\Users\Administrator>
```



## 2. 安装完成启动linux环境，设置WSL中的用户账户

```shell
Installing, this may take a few minutes...
Please create a default UNIX user account. The username does not need to match your Windows username.
For more information visit: https://aka.ms/wslusers
Enter new UNIX username: root
adduser: The user `root' already exists.
Enter new UNIX username: css
New password:Xinxibu1717...
Retype new password:Xinxibu1717...
passwd: password updated successfully
Installation successful!
适用于 Linux 的 Windows 子系统现已在 Microsoft Store 中可用!
你可以通过运行“wsl.exe --update”或通过访问 https://aka.ms/wslstorepage 进行升级
从 Microsoft Store 安装 WSL 将可以更快地获取最新的 WSL 更新。
有关详细信息，请访问 https://aka.ms/wslstoreinfo

To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

Welcome to Ubuntu 22.04.5 LTS (GNU/Linux 4.4.0-19041-Microsoft x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Tue Sep 23 00:22:00 CST 2025

  System load:            0.52
  Usage of /home:         unknown
  Memory usage:           55%
  Swap usage:             0%
  Processes:              8
  Users logged in:        0
  IPv4 address for wifi0: 192.168.43.79
  IPv6 address for wifi0: 240a:42cc:c02:23dd:f4a7:57ed:f426:5bfb
  IPv6 address for wifi0: 240a:42c6:c01:3673:8f07:9165:72dc:548d
  IPv6 address for wifi0: 240a:42c6:c01:3673:5509:42db:4dff:c294
  IPv6 address for wifi0: 240a:42cc:c02:23dd:5509:42db:4dff:c294


This message is shown once a day. To disable it please create the
/home/css/.hushlogin file.
css@OS-20241205RSYY:~$
```



## 3. 升级版本

```shell
PS C:\Users\Administrator> wsl --list --verbose
  NAME            STATE           VERSION
* Ubuntu-22.04    Stopped         1

PS C:\Users\Administrator> wsl --update
正在安装: 适用于 Linux 的 Windows 子系统
已安装 适用于 Linux 的 Windows 子系统。
PS C:\Users\Administrator>
PS C:\Users\Administrator>
PS C:\Users\Administrator> wsl --list --verbose
  NAME            STATE           VERSION
* Ubuntu-22.04    Stopped         2
PS C:\Users\Administrator> wsl --set-default-version 2
有关与 WSL 2 关键区别的信息，请访问 https://aka.ms/wsl2

操作成功完成。
PS C:\Users\Administrator> wsl --set-version Ubuntu-22.04 2
有关与 WSL 2 关键区别的信息，请访问 https://aka.ms/wsl2

正在进行转换，这可能需要几分钟时间。

该分发已是请求的版本。
错误代码: Wsl/Service/WSL_E_VM_MODE_INVALID_STATE			# 系统尝试转换，但发现它已经是 WSL 2，所以拒绝重复操作
PS C:\Users\Administrator> wsl -l -v
  NAME            STATE           VERSION
* Ubuntu-22.04    Stopped         2
PS C:\Users\Administrator>
```



## 4. 安装Docker Desktop

1. **下载Docker Desktop**
   - 访问 [Docker官网下载页面](https://www.docker.com/products/docker-desktop/)
   - 下载Docker Desktop for Windows
2. **安装Docker Desktop**
   - 运行下载的安装程序
   - 安装过程中确保勾选"Use WSL 2 instead of Hyper-V"选项
   - 完成安装后重启计算机
3. **配置Docker Desktop**
   - 启动Docker Desktop
   - 进入Settings → General
   - 确保"Use WSL 2 based engine"已勾选
   - 进入Settings → Resources → WSL Integration
   - 启用您安装的Ubuntu-22.04发行版



## 5. 在WSL中验证Docker安装

1. **打开WSL终端**

   ```shell
   # 在PowerShell中启动Ubuntu
   PS C:\Users\Administrator> wsl -d Ubuntu-22.04
   To run a command as administrator (user "root"), use "sudo <command>".
   See "man sudo_root" for details.
   ```

   

2. **检查Docker是否正常工作**

   ```shell
   # 在WSL终端中执行
   # docker --version
   # docker-compose --version
   # docker buildx version
   
   css@OS-20241205RSYY:/mnt/c/Users/Administrator$ docker --version
   Docker version 28.4.0, build d8eb465
   css@OS-20241205RSYY:/mnt/c/Users/Administrator$ docker-compose --version
   Docker Compose version v2.39.2-desktop.1
   css@OS-20241205RSYY:/mnt/c/Users/Administrator$ docker buildx version
   github.com/docker/buildx v0.28.0-desktop.1 8ad457cf5e291fcb7152ef6946162cc811a2fb29
   ```

   

## 6. 设置跨平台构建环境

在WSL终端中执行以下命令：

```shell
# 更新系统包
css@OS-20241205RSYY:/mnt/c/Users/Administrator$ sudo apt update
[sudo] password for css:
Get:1 http://security.ubuntu.com/ubuntu jammy-security InRelease [129 kB]
Get:2 http://security.ubuntu.com/ubuntu jammy-security/main amd64 Packages [2654 kB]
Hit:3 http://archive.ubuntu.com/ubuntu jammy InRelease
Get:4 http://archive.ubuntu.com/ubuntu jammy-updates InRelease [128 kB]
Get:5 http://archive.ubuntu.com/ubuntu jammy-backports InRelease [127 kB]
Get:6 http://archive.ubuntu.com/ubuntu jammy/universe amd64 Packages [14.1 MB]
Get:7 http://archive.ubuntu.com/ubuntu jammy/universe Translation-en [5652 kB]
Get:8 http://archive.ubuntu.com/ubuntu jammy/universe amd64 c-n-f Metadata [286 kB]
Get:9 http://archive.ubuntu.com/ubuntu jammy/multiverse amd64 Packages [217 kB]
Get:10 http://archive.ubuntu.com/ubuntu jammy/multiverse Translation-en [112 kB]
Get:11 http://archive.ubuntu.com/ubuntu jammy/multiverse amd64 c-n-f Metadata [8372 B]
Get:12 http://archive.ubuntu.com/ubuntu jammy-updates/main amd64 Packages [2904 kB]
Get:13 http://archive.ubuntu.com/ubuntu jammy-updates/main Translation-en [455 kB]
Get:14 http://archive.ubuntu.com/ubuntu jammy-updates/main amd64 c-n-f Metadata [19.0 kB]
Get:15 http://archive.ubuntu.com/ubuntu jammy-updates/restricted amd64 Packages [4473 kB]
Get:16 http://archive.ubuntu.com/ubuntu jammy-updates/restricted Translation-en [820 kB]
Get:17 http://archive.ubuntu.com/ubuntu jammy-updates/restricted amd64 c-n-f Metadata [672 B]
Get:18 http://archive.ubuntu.com/ubuntu jammy-updates/universe amd64 Packages [1227 kB]
Get:19 http://archive.ubuntu.com/ubuntu jammy-updates/universe Translation-en [305 kB]
Get:20 http://archive.ubuntu.com/ubuntu jammy-updates/universe amd64 c-n-f Metadata [29.5 kB]
Get:21 http://archive.ubuntu.com/ubuntu jammy-updates/multiverse amd64 Packages [57.6 kB]
Get:22 http://archive.ubuntu.com/ubuntu jammy-updates/multiverse Translation-en [13.2 kB]
Get:23 http://archive.ubuntu.com/ubuntu jammy-updates/multiverse amd64 c-n-f Metadata [600 B]
Get:24 http://archive.ubuntu.com/ubuntu jammy-backports/main amd64 Packages [68.8 kB]
Get:25 http://archive.ubuntu.com/ubuntu jammy-backports/main Translation-en [11.4 kB]
Get:26 http://archive.ubuntu.com/ubuntu jammy-backports/main amd64 c-n-f Metadata [392 B]
Get:27 http://archive.ubuntu.com/ubuntu jammy-backports/restricted amd64 c-n-f Metadata [116 B]
Get:28 http://archive.ubuntu.com/ubuntu jammy-backports/universe amd64 Packages [30.0 kB]
Get:29 http://archive.ubuntu.com/ubuntu jammy-backports/universe Translation-en [16.6 kB]
Get:30 http://archive.ubuntu.com/ubuntu jammy-backports/universe amd64 c-n-f Metadata [672 B]
Get:31 http://archive.ubuntu.com/ubuntu jammy-backports/multiverse amd64 c-n-f Metadata [116 B]
Get:32 http://security.ubuntu.com/ubuntu jammy-security/main Translation-en [390 kB]
Get:33 http://security.ubuntu.com/ubuntu jammy-security/main amd64 c-n-f Metadata [13.9 kB]
Get:34 http://security.ubuntu.com/ubuntu jammy-security/restricted amd64 Packages [4324 kB]
Get:35 http://security.ubuntu.com/ubuntu jammy-security/restricted Translation-en [797 kB]
Get:36 http://security.ubuntu.com/ubuntu jammy-security/restricted amd64 c-n-f Metadata [648 B]
Get:37 http://security.ubuntu.com/ubuntu jammy-security/universe amd64 Packages [996 kB]
Get:38 http://security.ubuntu.com/ubuntu jammy-security/universe Translation-en [218 kB]
Get:39 http://security.ubuntu.com/ubuntu jammy-security/universe amd64 c-n-f Metadata [22.1 kB]
Get:40 http://security.ubuntu.com/ubuntu jammy-security/multiverse amd64 Packages [56.9 kB]
Get:41 http://security.ubuntu.com/ubuntu jammy-security/multiverse Translation-en [11.9 kB]
Get:42 http://security.ubuntu.com/ubuntu jammy-security/multiverse amd64 c-n-f Metadata [520 B]
Fetched 40.7 MB in 41s (1000 kB/s)
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
121 packages can be upgraded. Run 'apt list --upgradable' to see them.



# 安装必要的工具
css@OS-20241205RSYY:/mnt/c/Users/Administrator$ sudo apt install -y qemu-user-static
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following additional packages will be installed:
  binfmt-support
The following NEW packages will be installed:
  binfmt-support qemu-user-static
0 upgraded, 2 newly installed, 0 to remove and 121 not upgraded.
Need to get 13.0 MB of archives.
Selecting previously unselected package binfmt-support.ill be used.
(Reading database ... 42578 files and directories currently installed.)
Preparing to unpack .../binfmt-support_2.2.1-2_amd64.deb ...
Unpacking binfmt-support (2.2.1-2) ...
Selecting previously unselected package qemu-user-static.
Preparing to unpack .../qemu-user-static_1%3a6.2+dfsg-2ubuntu6.27_amd64.deb ...
Unpacking qemu-user-static (1:6.2+dfsg-2ubuntu6.27) ...
Setting up qemu-user-static (1:6.2+dfsg-2ubuntu6.27) ...
Setting up binfmt-support (2.2.1-2) ...
Created symlink /etc/systemd/system/multi-user.target.wants/binfmt-support.service → /lib/systemd/system/binfmt-support.service.
Processing triggers for man-db (2.10.2-1) ...
css@OS-20241205RSYY:/mnt/c/Users/Administrator$

Get:2 http://archive.ubuntu.com/ubuntu jammy-updates/universe amd64 qemu-user-static amd64 1:6.2+dfsg-2ubuntu6.27 [13.0 MB]
css@OS-20241205RSYY:/mnt/c/Users/Administrator$



# 创建并启用多架构构建器
# docker buildx create --name arm-builder --use --platform linux/amd64,linux/arm64,linux/arm64
# docker buildx inspect --bootstrap
css@OS-20241205RSYY:/mnt/c/Users/Administrator$ docker buildx create --name arm-builder --use --platform linux/amd64,linux/arm64,linux/arm64
arm-builder

css@OS-20241205RSYY:/mnt/c/Users/Administrator$ docker buildx inspect --bootstrap
[+] Building 21.8s (1/1) FINISHED
 => ERROR [internal] booting buildkit                                                                                                                                                                                                  21.8s
 => => pulling image moby/buildkit:buildx-stable-1                                                                                                                                                                                     21.8s
------
 > [internal] booting buildkit:
------
ERROR: Error response from daemon: failed to resolve reference "docker.io/moby/buildkit:buildx-stable-1": failed to do request: Head "https://registry-1.docker.io/v2/moby/buildkit/manifests/buildx-stable-1": dialing registry-1.docker.io:443 container via direct connection because disabled has no HTTPS proxy: connecting to registry-1.docker.io:443: dial tcp 69.171.224.40:443: connectex: A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond.
# 无法连接到 Docker Hub（registry-1.docker.io）--- 未启用加速器

css@OS-20241205RSYY:/mnt/c/Users/Administrator$ docker buildx inspect --bootstrap
[+] Building 3.0s (1/1) FINISHED
 => ERROR [internal] booting buildkit                                                                                                                                                                                                   3.0s
 => => pulling image moby/buildkit:buildx-stable-1                                                                                                                                                                                      3.0s
------
 > [internal] booting buildkit:
------
ERROR: Error response from daemon: authentication required - email must be verified before using account
# 登录了 Docker Hub 账号（docker login），但该账号的邮箱未验证。Docker 自 2022 年起要求：未验证邮箱的账号无法拉取镜像（即使是公开镜像）。Buildx 需要拉取 moby/buildkit:buildx-stable-1 镜像来启动构建器，但被拒绝，打开注册时使用的邮箱，点击验证邮件进行验证即可！！

css@OS-20241205RSYY:/mnt/c/Users/Administrator$ docker buildx inspect --bootstrap
[+] Building 28.7s (1/1) FINISHED
 => [internal] booting buildkit                                                                                                                                                                                                        28.7s
 => => pulling image moby/buildkit:buildx-stable-1                                                                                                                                                                                     27.9s
 => => creating container buildx_buildkit_arm-builder0                                                                                                                                                                                  0.8s
Name:          arm-builder
Driver:        docker-container
Last Activity: 2025-09-22 16:52:25 +0000 UTC

Nodes:
Name:     arm-builder0
Endpoint: unix:///var/run/docker.sock
Error:    Get "http://%2Fvar%2Frun%2Fdocker.sock/v1.51/containers/buildx_buildkit_arm-builder0/json": context deadline exceeded
# 出现新问题：通常表示 Docker 守护进程（Docker daemon）在处理请求时超时了。这可能是由于网络问题、资源限制或 Docker 本身的问题，直接清理重新来一遍，如下：
css@OS-20241205RSYY:/mnt/c/Users/Administrator$ docker buildx rm arm-builder
ker buildx create --name arm-builder --use --platform linux/amd64,linux/arm64,linux/arm64
docker buildx inspect --bootstraparm-builder removed
css@OS-20241205RSYY:/mnt/c/Users/Administrator$ docker buildx create --name arm-builder --use --platform linux/amd64,linux/arm64,linux/arm64
arm-builder
css@OS-20241205RSYY:/mnt/c/Users/Administrator$ docker buildx inspect --bootstrap
[+] Building 3.4s (1/1) FINISHED
 => [internal] booting buildkit                                                                                                                                                                                                         3.4s
 => => pulling image moby/buildkit:buildx-stable-1                                                                                                                                                                                      2.8s
 => => creating container buildx_buildkit_arm-builder0                                                                                                                                                                                  0.5s
Name:          arm-builder
Driver:        docker-container
Last Activity: 2025-09-22 16:59:51 +0000 UTC

Nodes:
Name:                  arm-builder0
Endpoint:              unix:///var/run/docker.sock
Status:                running
BuildKit daemon flags: --allow-insecure-entitlement=network.host
BuildKit version:      v0.24.0
Platforms:             linux/amd64*, linux/arm64*, linux/arm64*, linux/amd64/v2, linux/amd64/v3, linux/riscv64, linux/ppc64, linux/ppc64le, linux/s390x, linux/386, linux/arm/v6
Labels:
 org.mobyproject.buildkit.worker.executor:         oci
 org.mobyproject.buildkit.worker.hostname:         575fea0d872b
 org.mobyproject.buildkit.worker.network:          host
 org.mobyproject.buildkit.worker.oci.process-mode: sandbox
 org.mobyproject.buildkit.worker.selinux.enabled:  false
 org.mobyproject.buildkit.worker.snapshotter:      overlayfs
GC Policy rule#0:
 All:            false
 Filters:        type==source.local,type==exec.cachemount,type==source.git.checkout
 Keep Duration:  48h0m0s
 Max Used Space: 488.3MiB
GC Policy rule#1:
 All:            false
 Keep Duration:  1440h0m0s
 Reserved Space: 9.313GiB
 Max Used Space: 93.13GiB
 Min Free Space: 188.1GiB
GC Policy rule#2:
 All:            false
 Reserved Space: 9.313GiB
 Max Used Space: 93.13GiB
 Min Free Space: 188.1GiB
GC Policy rule#3:
 All:            true
 Reserved Space: 9.313GiB
 Max Used Space: 93.13GiB
 Min Free Space: 188.1GiB

# 检查构建器状态
docker buildx ls
```



## 7. 测试跨平台构建

创建一个简单的测试项目来验证功能：

```
# 在WSL中创建测试目录
mkdir -p /home/$(whoami)/docker-test
cd /home/$(whoami)/docker-test

# 创建测试Dockerfile
cat > Dockerfile << 'EOF'
FROM arm64v8/alpine:3.18
RUN apk add --no-cache nodejs npm
RUN echo "ARM Docker build successful!" > /success.txt
CMD ["cat", "/success.txt"]
EOF

# 测试构建ARM镜像
docker buildx build --platform linux/arm64 -t test-arm-image --load .
```



## 8. 构建ARM镜像

```
# 将项目文件放在Windows目录中，比如 C:\docker-project
# 然后在WSL中访问该目录
cd /mnt/c/docker-project

# 使用buildx构建ARM镜像（推送到Docker Hub示例）
docker buildx build --platform linux/arm64 -t your-dockerhub-username/your-image-name:arm-latest --push .
```



实际使用

```shell
# 错误使用命令
css@OS-20241205RSYY:/mnt/c/Users/Administrator$ wsl -l
Command 'wsl' not found, but can be installed with:
sudo apt install wsl
css@OS-20241205RSYY:/mnt/c/Users/Administrator$ cp "F:\4.5系统搭建环境\arm\basicEnvironmentBuild\images\choicelink_java8.tar.gz" "\\wsl$\Ubuntu-22.04\home\css\choicelink_java8.tar.gz"
cp: cannot stat 'F:\4.5系统搭建环境\arm\basicEnvironmentBuild\images\choicelink_java8.tar.gz': No such file or directory

# 退出wsl
css@OS-20241205RSYY:/mnt/c/Users/Administrator$ exit
logout

# 正确使用，在windows下执行
PS C:\Users\Administrator> wsl -l -v
  NAME              STATE           VERSION
* Ubuntu-22.04      Running         2
  docker-desktop    Running         2
PS C:\Users\Administrator> cp "F:\4.5系统搭建环境\arm\basicEnvironmentBuild\images\choicelink_java8.tar.gz" "\\wsl$\Ubuntu-22.04\home\css\choicelink_java8.tar.gz"

# 进入wsl
PS C:\Users\Administrator> wsl -d Ubuntu-22.04

# 进入目录可看到拷贝成功了
css@OS-20241205RSYY:/mnt/c/Users/Administrator$ cd /home
css@OS-20241205RSYY:/home$ ls
css
css@OS-20241205RSYY:/home$ cd css
css@OS-20241205RSYY:~$ ls
choicelink_java8.tar.gz
css@OS-20241205RSYY:~$

# 加载镜像并列出所有镜像
css@OS-20241205RSYY:~$ docker load -i ~/choicelink_java8.tar.gz
Loaded image: choicelink_java8:1.2
css@OS-20241205RSYY:~$ docker images
REPOSITORY         TAG               IMAGE ID       CREATED         SIZE
moby/buildkit      buildx-stable-1   6eceb8971ce4   2 weeks ago     325MB
choicelink_java8   1.2               ed3294e0e52e   21 months ago   1.31GB

# 复制需要的字体到制作镜像目录下
css@OS-20241205RSYY:~$ exit
logout
PS C:\Users\Administrator> cp "F:\4.5系统搭建环境\arm\basicEnvironmentBuild\images\simhei.ttf" "\\wsl$\Ubuntu-22.04\home\css\simhei.ttf"
PS C:\Users\Administrator> wsl -d Ubuntu-22.04
css@OS-20241205RSYY:/mnt/c/Users/Administrator$ cd /home/css
css@OS-20241205RSYY:~$ ls
choicelink_java8.tar.gz  simhei.ttf
```



## ！！！构建升级版镜像（增加字体）

目标：

> 基于 `choicelink_java8:1.2`，添加 `simhei.ttf` 字体，生成新镜像 `choicelink_java8:1.2.1 

------

### 🔧 步骤 1：创建构建目录并准备文件

```
mkdir ~/build-java-fonts && cd ~/build-java-fonts
```

将字体文件复制进来：

```
cp ~/simhei.ttf ./
```

创建 `Dockerfile`：

```
nano Dockerfile
```

粘贴以下内容：

```
# 基于已有镜像
FROM choicelink_java8:1.2

# 创建字体目录并复制字体
COPY simhei.ttf /usr/share/fonts/Fonts/simhei.ttf

# 如果 /usr/share/fonts/Fonts 不存在，先创建
RUN mkdir -p /usr/share/fonts/Fonts && \
    # 更新字体缓存
    fc-cache -fv && \
    echo "Font cache updated."

# 可选：验证字体是否生效
RUN fc-list | grep -i "simhei"

# 保留原有环境（JRE、RASP、时区、locale 等）
```

> ✅ 说明：
>
> - 直接继承 `choicelink_java8:1.2` 的所有配置；
> - 只新增字体和更新缓存；
> - `fc-cache -fv` 是关键，否则系统可能无法识别新字体。

保存并退出（`Ctrl+O` → 回车 → `Ctrl+X`）。

------

### 🔧 步骤 2：使用 Buildx 构建 ARM 镜像

确保arm-builder` 正在运行：（应该看到 `arm-builder` 状态为 `running`）

```
docker buildx ls
```

开始构建（目标平台：`linux/arm64`）：

```shell
docker buildx build \
  --platform linux/arm64 \
  -t choicelink_java8:1.2.1 \
  --load .
  
# !!!!!!!可能报错：
css@OS-20241205RSYY:~/build-java-fonts$ docker buildx build \
>   --platform linux/arm64 \
>   -t choicelink_java8:1.2.1 \
>   --load .
[+] Building 31.2s (3/3) FINISHED                                                                                                                                                                               docker-container:arm-builder
 => [internal] load build definition from Dockerfile                                                                                                                                                                                    0.0s
 => => transferring dockerfile: 475B                                                                                                                                                                                                    0.0s
 => ERROR [internal] load metadata for docker.io/library/choicelink_java8:1.2                                                                                                                                                          31.2s
 => [auth] library/choicelink_java8:pull token for registry-1.docker.io                                                                                                                                                                 0.0s
------
 > [internal] load metadata for docker.io/library/choicelink_java8:1.2:
------
Dockerfile:2
--------------------
   1 |     # 基于已有镜像
   2 | >>> FROM choicelink_java8:1.2
   3 |
   4 |     # 创建字体目录并复制字体
--------------------
ERROR: failed to build: failed to solve: failed to fetch oauth token: Post "https://auth.docker.io/token": dial tcp 157.240.2.50:443: i/o timeout
css@OS-20241205RSYY:~/build-java-fonts$



 
# 若镜像是本地的，且只需要构建 ARM 镜像并加载回本地，建议直接使用：docker build（推荐，简单直接）
css@OS-20241205RSYY:~/build-java-fonts$ docker build \
>   --platform linux/arm64 \
>   -t choicelink_java8:1.2.1 \
>   .

# 处理过程
[+] Building 5.2s (7/8)                                                                                                                                                                                                       docker:default
[+] Building 5.4s (9/9) FINISHED                                                                                                                                                                                              docker:default
 => [internal] load build definition from Dockerfile                                                                                                                                                                                    0.0s
 => => transferring dockerfile: 475B                                                                                                                                                                                                    0.0s
 => [internal] load metadata for docker.io/library/choicelink_java8:1.2                                                                                                                                                                 0.1s
 => [internal] load .dockerignore                                                                                                                                                                                                       0.0s
 => => transferring context: 2B                                                                                                                                                                                                         0.0s
 => [internal] load build context                                                                                                                                                                                                       0.0s
 => => transferring context: 34B                                                                                                                                                                                                        0.0s
 => [1/4] FROM docker.io/library/choicelink_java8:1.2@sha256:ed3294e0e52e024ac47b639c8e6d8608fe69e9fca021ee64e0c9917dd4a4bcee                                                                                                           0.0s
 => => resolve docker.io/library/choicelink_java8:1.2@sha256:ed3294e0e52e024ac47b639c8e6d8608fe69e9fca021ee64e0c9917dd4a4bcee                                                                                                           0.0s
 => CACHED [2/4] COPY simhei.ttf /usr/share/fonts/Fonts/simhei.ttf                                                                                                                                                                      0.0s
 => [3/4] RUN mkdir -p /usr/share/fonts/Fonts &&     fc-cache -fv &&     echo "Font cache updated."                                                                                                                                     4.7s
 => [4/4] RUN fc-list | grep -i "simhei"                                                                                                                                                                                                0.3s
 => exporting to image                                                                                                                                                                                                                  0.2s
 => => exporting layers                                                                                                                                                                                                                 0.1s
 => => exporting manifest sha256:cc0601f578b6ce0731480a78443a59f51cb8e4d1487eca35fac5a1bc8e64a2c9                                                                                                                                       0.0s
 => => exporting config sha256:5ce434bbc145632defd2710db43a3224b6afca1b543299a4dd1fb877ddd36e71                                                                                                                                         0.0s
 => => exporting attestation manifest sha256:d9110973cd822b737f95f3113ee20a9626b1e849bb5ec884b40b85ff41ee505d                                                                                                                           0.0s
 => => exporting manifest list sha256:beb46fad9a7926c788e138c2eb11b7451e621428bd6f2eab3647a848714cd864                                                                                                                                  0.0s
 => => naming to docker.io/library/choicelink_java8:1.2.1
 
# 列出当前镜像
css@OS-20241205RSYY:~/build-java-fonts$ docker images
REPOSITORY         TAG               IMAGE ID       CREATED          SIZE
choicelink_java8   1.2.1             f23356646087   15 seconds ago   1.31GB
moby/buildkit      buildx-stable-1   6eceb8971ce4   2 weeks ago      325MB
choicelink_java8   1.2               ed3294e0e52e   21 months ago    2.64GB
```

------



### 🔧 步骤 3：测试字体是否生效：

```shell
docker run --rm choicelink_java8:1.2.1 fc-list | grep -i simhei

# 预期输出：版本不兼容，但是可找到字体
css@OS-20241205RSYY:~/build-java-fonts$ docker run --rm choicelink_java8:1.2.1 fc-list | grep -i simhei
WARNING: The requested image's platform (linux/arm64) does not match the detected host platform (linux/amd64/v3) and no specific platform was requested
/usr/share/fonts/Fonts/simhei.ttf: SimHei,黑体:style=Regular,Normal,obyčejné,Standard,Κανονικά,Normaali,Normál,Normale,Standaard,Normalny,Обычный,Normálne,Navadno,Arrunta
```



------

### 🔧 步骤 4：导出新镜像供 ARM 设备使用

```
docker save choicelink_java8:1.2.1 | gzip > ~/choicelink_java8_1.2.1_arm64.tar.gz
```

然后从 Windows 访问：

- 路径：`\\wsl$\Ubuntu-22.04\home\css\choicelink_java8_1.2.1_arm.tar.gz`
- 或直接在 WSL 中复制回 Windows：

```
cp ~/choicelink_java8_1.2.1_arm64.tar.gz /mnt/f/4.5系统搭建环境/arm/basicEnvironmentBuild/images/
```





## 访问Windows文件系统的路径映射

在WSL中，Windows的C盘对应`/mnt/c/`：

- `C:\Users\Administrator\projects` → `/mnt/c/Users/Administrator/projects`
- `C:\docker` → `/mnt/c/docker`



## 常用命令参考

```
# 启动WSL Ubuntu
wsl -d Ubuntu-22.04

# 在WSL中查看Windows文件
ls /mnt/c/Users/Administrator/

# 构建并推送多平台镜像
docker buildx build --platform linux/amd64,linux/arm64 -t username/image:tag --push .

# 仅构建ARM64镜像
docker buildx build --platform linux/arm64 -t username/image:arm-latest --push .
```



## 故障排除

如果遇到问题：

1. **WSL启动失败**：

   ```
   # 在PowerShell中以管理员身份运行
   wsl --shutdown
   wsl -d Ubuntu-22.04
   ```

   

2. **Docker权限问题**：

   ```
   # 在WSL中将用户加入docker组
   sudo usermod -aG docker $USER
   # 然后退出WSL重新登录
   exit
   ```

   

3. **Buildx构建失败**：

   ```
   # 重新初始化buildx
   docker buildx rm arm-builder
   docker buildx create --name arm-builder --use
   docker buildx inspect --bootstrap
   ```

   

按照这个流程，您应该能够在Windows上成功构建ARM架构的Docker镜像。整个过程的核心就是利用WSL 2提供的Linux环境，结合Docker Buildx的跨平台构建能力。