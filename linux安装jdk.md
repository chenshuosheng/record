1. 确认系统：

   - ```shell
     uname -m
     
     [root@localhost BI]# uname -a
     Linux localhost.localdomain 3.10.0-1160.el7.x86_64 #1 SMP Mon Oct 19 16:18:59 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
     ```

     

2. 上官网https://www.oracle.com/java/technologies/javase/javase8-archive-downloads.html?spm=5176.28103460.0.0.7ef45d27Sbgaiw下载对应的jdk，并上传到服务器目录下，如：/home/BI/jdk-8u202-linux-x64.tar.gz

   

3. 使用 `tar` 命令来解压 `.tar.gz` 文件

   - ```shell
     sudo tar zxvf jdk-8u202-linux-x64.tar.gz -C /usr/lib/jvm/   # 目录不存在的话先创建
     ```

   

4. 添加环境变量

   - ```shell
     vi ~/.bashrc
     
     # 在文件末尾添加以下内容
     # Set JDK 1.8 environment variables
     export JAVA_HOME=/usr/lib/jvm/jdk1.8.0_202
     export PATH=$JAVA_HOME/bin:$PATH
     
     # 按 Esc 键退出插入模式，然后输入 :wq 并按 Enter
     
     不想保存可输入 :q!
     ```

   

5. 使更改生效

   - ```shell
     source ~/.bashrc
     ```

   

6. 验证

   - ```shell
     [root@localhost BI]# java -version
     java version "1.8.0_202"
     Java(TM) SE Runtime Environment (build 1.8.0_202-b08)
     Java HotSpot(TM) 64-Bit Server VM (build 25.202-b08, mixed mode)
     [root@localhost BI]# javac -version
     javac 1.8.0_202
     ```

     

