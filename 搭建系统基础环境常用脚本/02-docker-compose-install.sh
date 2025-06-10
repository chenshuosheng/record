# 获取脚本所在目录
SCRIPT_DIR=$(dirname $(readlink -f $0))

# 读取配置文件
source $SCRIPT_DIR/config.sh

# 安装 docker-compose
function install_docker_compose() {
    echo "#########################################################"
    if command -v docker-compose > /dev/null 2>&1; then
        echo "docker-compose is already installed."
        compose_version=$(docker-compose --version)
        echo "docker-compose version: $compose_version"
    else
        echo "docker-compose is not installed. Installing docker-compose..."

        # 切换到安装包所在目录
        cd $DOCKER_COMPOSE_SOURCE_DIR || { echo "Failed to change directory to $DOCKER_COMPOSE_SOURCE_DIR"; exit 1; }

        # 拷贝并添加执行权限
        sudo cp $DOCKER_COMPOSE_SOURCE_DIR/$DOCKER_COMPOSE_SOURCE_NAME /usr/local/bin/
        sudo chmod +x /usr/local/bin/$DOCKER_COMPOSE_SOURCE_NAME

        echo "docker-compose installed successfully"
    fi
    echo "#########################################################"
}

# 调用安装函数
install_docker_compose