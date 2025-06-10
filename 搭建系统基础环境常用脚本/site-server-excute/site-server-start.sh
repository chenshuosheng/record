# 获取脚本所在目录
SCRIPT_DIR=$(dirname $(readlink -f $0))

sudo docker stop site-server
sudo docker rm -f site-server

sudo /usr/local/bin/docker-compose -f $SCRIPT_DIR/site-server-install.yaml -p site-server up -d