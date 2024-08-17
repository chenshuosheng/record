其实条件，有sscms7.3.tar镜像

1. 使用以下命令加载镜像

   - ```shell
     docker load -i sscms7.3.tar
     ```

   

2. 镜像加载完毕可以使用下列命令查看

   - ```shell
     docker images
     ```



3. 在适当位置定义文件dokcer-compose.yml，内容如下

   - ```yaml
     #启动sscms服务，数据库用pg，sscms版本为7.3
     version: "3"
     networks:
       servicenet:
         external: true
     services: 
       site-server:
         image: sscms:7.3
         ports:
           - "5000:80"  
         restart: "always"								#自动启动
         container_name: site-server
         environment:
           - TZ=Asia/Shanghai
           - SLEEP_SECOND=5 
         volumes:  
           - /mnt/b/sscms7.3/wwwroot:/var/www/wwwroot     #资源挂载路径，第一次启动不要挂载
           - /usr/jars/wait.sh:/wait.sh
           - /usr/jars/sscms7.3/docker/log:/log
         entrypoint: /wait.sh -d 数据库ip:port -c "service nginx restart && cd /var/www && dotnet SSCMS.Web.dll"
         networks:
          servicenet: {}
     ```

4. 定义启动文件docker.sh

   - ```sh
     docker stop site-server
     docker rm -f site-server
     # 在包含docker-compose.yml的目录下运行
     docker-compose -f  docker-compose.yml -p site-server up -d
     ```

     

5. 定位到docker.sh所在目录，执行下列命令

   - ```shell
     ./docker.sh
     
     #若执行失败，需执行chmod +x docker.sh，给该文件执行权限
     ```

     

6. 执行成功后，使用ip+/ss-admin/install/访问site server

   - ```shell
     #成功访问，执行命令：
     docker cp site server容器id:/var/www/wwwroot 挂载目录
     
     #若失败，查看原因
     ```

   

7. 将挂载目录的配置加上（解除注释）,重新创建site server容器

   - ```
     ./docker.sh
     ```

     

8. 使用ip+/ss-admin/install/访问site server，并根据指引进行配置

   

9. 创建一个站点，创建完毕后，查看挂载目录下是否新增了相应的目录，若有则说明挂载成功

   

