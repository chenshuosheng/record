# 获取脚本所在目录
SCRIPT_DIR=$(dirname $(readlink -f $0))

# 读取配置文件
source $SCRIPT_DIR/config.sh


# 安装docker
function install_docker() {
    echo "#########################################################"
    if command -v docker > /dev/null 2>&1; then
        echo "Docker is already installed."
        docker_version=$(docker -v)
        echo "Docker version: $docker_version"
    else
        echo "Docker is not installed. Installing Docker..."
        cd $DOCKER_SOURCE_DIR || { echo "Failed to change directory to $DOCKER_SOURCE_DIR"; exit 1; }
        tar xf $DOCKER_SOURCE_DIR/$DOCKER_SOURCE_NAME || { echo "Failed to extract the Docker archive"; exit 1; }

        # 使用sudo来复制文件
        sudo cp -r $DOCKER_SOURCE_DIR/docker/* /usr/bin/
		
		# 给执行脚本权限
		sudo chmod +x /usr/bin/docker* /usr/bin/containerd* /usr/bin/runc

        # 创建docker服务文件
	   sudo touch /etc/systemd/system/docker.service

        # 编写docker服务文件
        sudo sh -c 'cat > /etc/systemd/system/docker.service <<EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service
Wants=network-online.target
[Service]
Type=notify
ExecStart=/usr/bin/dockerd
ExecReload=/bin/kill -s HUP $MAINPID
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TimeoutStartSec=0
Delegate=yes
KillMode=process
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s
[Install]
WantedBy=multi-user.target
EOF'

        sudo chmod +x /etc/systemd/system/docker.service
        sudo systemctl daemon-reload
        sudo systemctl enable docker.service
        sudo systemctl start docker.service
        echo "Docker installed successfully"
    fi
    echo "#########################################################"
}

# 调用安装函数
install_docker