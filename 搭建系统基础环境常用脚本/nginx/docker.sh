docker stop nginx
docker rm nginx
docker-compose -f docker-compose.yml -p nginx up -d