# 获取脚本所在目录
SCRIPT_DIR=$(dirname $(readlink -f $0))

sudo docker stop rabbitmq
sudo docker rm -f rabbitmq
sudo /usr/local/bin/docker-compose -f $SCRIPT_DIR/rabbitmq.yaml up -d