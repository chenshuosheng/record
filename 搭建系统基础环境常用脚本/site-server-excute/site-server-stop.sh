# 获取脚本所在目录
SCRIPT_DIR=$(dirname $(readlink -f $0))

sudo /usr/local/bin/docker-compose -f $SCRIPT_DIR/site-server-install.yaml down