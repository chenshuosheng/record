# config.sh ��� /usr/init-data/install_scripts�½ű� ��ȫ�ֱ�������Ҫ����ʵ������޸�

# ��ȡ�ű�����Ŀ¼
SCRIPT_DIR=$(dirname $(readlink -f $0))

CURRENT_IP="192.168.218.217"						# ��ǰ������ip

IMAGES_DIR="$SCRIPT_DIR/images"   				# ������������Ŀ¼

DOCKER_SOURCE_DIR="$IMAGES_DIR/docker"				# docker��װ������Ŀ¼
DOCKER_SOURCE_NAME="docker-26.1.4.tgz"				# docker��װ������

DOCKER_COMPOSE_SOURCE_DIR="$IMAGES_DIR/docker-compose"		# docker-compose��װ������Ŀ¼
DOCKER_COMPOSE_SOURCE_NAME="docker-compose"			# docker-compose��װ������
