# 获取脚本所在目录
SCRIPT_DIR=$(dirname $(readlink -f $0))

sudo docker stop nacos
sudo docker rm -f nacos
sudo /usr/local/bin/docker-compose -f $SCRIPT_DIR/nacos.yaml up -d
