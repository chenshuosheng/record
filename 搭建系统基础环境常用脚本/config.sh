# config.sh 针对 /usr/init-data/install_scripts下脚本 的全局变量，需要根据实际情况修改

# 获取脚本所在目录
SCRIPT_DIR=$(dirname $(readlink -f $0))

CURRENT_IP="192.168.218.217"						# 当前服务器ip

IMAGES_DIR="$SCRIPT_DIR/images"   				# 容器镜像所在目录

DOCKER_SOURCE_DIR="$IMAGES_DIR/docker"				# docker安装包所在目录
DOCKER_SOURCE_NAME="docker-26.1.4.tgz"				# docker安装包名称

DOCKER_COMPOSE_SOURCE_DIR="$IMAGES_DIR/docker-compose"		# docker-compose安装包所在目录
DOCKER_COMPOSE_SOURCE_NAME="docker-compose"			# docker-compose安装包名称
