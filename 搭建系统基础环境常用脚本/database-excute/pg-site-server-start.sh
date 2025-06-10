# 获取脚本所在目录
SCRIPT_DIR=$(dirname $(readlink -f $0))

sudo docker stop pg_for_sscms
sudo docker rm -f pg_for_sscms
sudo /usr/local/bin/docker-compose -f $SCRIPT_DIR/pg-site-server.yaml up -d