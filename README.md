# docker-lnmp
centos7下基于docker-compose搭建的lnmp环境，本环境搭建过程使用的是yii2进行相关测试，所以默认支持yii2的运行

`LNMP（Docker + Docker-compose + Nginx + MySQL5.7 + PHP7.2 + Redis5.0 + Memcached1.5 + Mongodb4.2）`

LNMP项目特点：
1. 一键安装，简单实用
2. 包含lnmp常用服务
3. 各服务支持数据文件、配置文件、日志文件挂载
4. 默认支持`pdo_mysql`、`mysqli`、`swoole`、`gd`、`curl`、`opcache`等常用扩展
5. 包含基本的已优化的配置文件
6. 支持 MySQL+Atlas 读写分离

## 一. 目录结构

```
├── data                        数据库数据目录
│   ├── mongo                   MongoDB 数据目录
│   ├── mysql                   MySQL 数据目录
│   └── redis                   Redis 数据目录
│   └── mysql-cluster           MySQL 集群数据目录
├── services                    服务构建文件、配置文件目录
│   ├── mysql                   MySQL 配置、构建文件
│   ├── nginx                   Nginx 配置、构建文件
│   ├── php                     PHP 配置、构建文件
│   ├── memcached               Memcached 配置、构建文件
│   ├── mongo                   Mongo 配置、构建文件
│   └── redis                   Redis 配置、构建文件
│   └── mysql-cluster           MySQL 集群配置、构建文件
├── logs                        日志目录
│   └── mysql                   
│   └── nginx                   
│   └── php                   
│   └── memcached                   
│   └── mongo                   
│   └── redis        
│   └── mysql-cluster            
├── docker-compose.yml         Docker 默认服务配置文件，如果使用其它的，可以 docker-composer -f 文件名
├── docker-compose-mysql-cluster.yml              只包含mysql基于atlas读写分离
├── .env                       环境配置
└── www                        PHP 代码目录 可在.env中nginx的WEB_DIR中任意指定
└── compose                    docker-compose下载可能会很慢，这里附一个
```
php-fpm容器中 **/usr/local/etc/** 目录结构
> 该目录下是php和php-fpm的配置文件，默认的结构如下，建议把整个目录挂载出来，方便修改和调试；<br />
> 建议：对于所有的配置文件的挂载都先生成默认文件、目录，然后再修改、调优；
```
├── php                                          php配置目录
│   ├── php.ini-development                      php.ini开发环境
│   ├── php.ini-production                       php.ini生产环境
│   └── conf.d                                   php扩展配置目录
│       ├── swoole.ini                           swoole扩展配置文件
│       ├── docker-php-ext-mongodb.ini           mongodb扩展配置文件 
│       └── ... 
├── php-fpm.conf                                 php-fpm配置文件
├── php-fpm.conf.default                         
├── php-fpm.d                                    php-fpm.conf可以包含该目录下的相关文件             
```
## 二. 快速使用
1. 本地安装
    1. `docker` 安装完成后，推荐使用阿里云`docker`加速：[https://help.aliyun.com/document_detail/60750.html](https://help.aliyun.com/document_detail/60750.html)
    2. `docker-compose` 可能会下载很慢，上面`compose`目录附带一个
        1. 复制到 `/usr/local/bin`
        2. `chmod +x /usr/local/bin/docker-compose`
        3. `ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose`
        4. 测试安装：`docker-compose --version`

2. `clone`项目：
    $ `git clone https://github.com/nianzhi1202/docker-lnmp.git`

3. 如果不是`root`用户，还需将当前用户加入docker用户组：
    $ `sudo gpasswd -a ${USER} docker`

4. 可根据项目需要自行添加其它php扩展 

5. 启动本项目
    1. $ `docker network create --driver bridge lnmp-net` # 创建自定义bridge网络，这个**lnmp-net**在yml配置中用得到
    2. $ `docker-compose up --build --force-recreate`  #可以加 -d 后台运行，调试时不用加，方便查看日志；--force-recreate 这个参数也是为了调试方便，生产一定不用

## 三. docker常用命令
- $ `systemctl start docker`    # 启动docker
- $ `docker start containername` # 启动容器
- $ `docker stop containername` # 停止容器
- $ `docker exec -it 13a676bb9bff /bin/bash` # 进入容器
- $ `docker rm containername` # 删除容器
- $ `docker rmi image` # 删除镜像

- $ `docker-compose up` # 启动所有容器 
- $ `docker-compose up nginx php mysql` # 启动指定容器
- $ `docker-compose up -d nginx php mysql` # 后台运行方式启动指定容器 
- $ `docker-compose up --build --force-recreate` # 强制启动
- $ `docker-compose start php` # 启动服务
- $ `docker-compose stop php` # 停止服务
- $ `docker-compose restart php` # 重启服务
- $ `docker-compose build php` # 使用Dockerfile构建服务

## 四. docker网络模式
> docker 网络模式是学习docker不可或缺的一部分，搞懂这块才能轻松应对容器间的连接
+ 研读官方文档 [https://docs.docker.com/network/bridge](https://docs.docker.com/network/bridge)
+ 常用命令
    + $ `docker network ls` # bridge none host 三种模式
    + $ `docker network create --driver bridge lnmp-net` # **创建自定义网络**
    + $ `docker network connect lnmp-net 容器ID` # 给容器设置网络，使用docker-compose是无需这样单独设置的，直接在yml中指定networks即可
    + $ `docker network inspect lnmp-net` # 查看网络详情，显示哪些容器加入了该网络
    + $ `docker inspect --format='{{.Name}} - {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps -aq)` #查看为每个容器分配的ip
+ bridge模式
> bridge是默认模式也是最常用的模式，官方建议使用自定义bridge网络
1. bridge模式下可以通过**容器名称进行容器间的通信**
2. 多个容器可以使用同一个`docker-compose.yml`是**无需使用--link**来连接的
3. 本实例使用都是自定义bridge，关于docker网络模式更多知识，自行查阅文档
     
## 五. Mysql基本操作
+ 远程连接需要进入容器登录mysql授权
    + $ `docker exec -it mysql /bin/bash`
    + $ `mysql -uroot -p123456`
    + $ `select host,user,plugin,authentication_string from mysql.user;` # 查看有无 root对应 %
    + $ `update user set host ='％' where user ='root' and host ='localhost';` # 建议这样
    + $ `grant all privileges on *.* to 'root'@'%' identified by 'root' with grant option;` # 与update二选一
    + $ `flush privileges;`

## 六. mongo基本操作
+ 命令行连接mongo
    + $ `docker exec -it 容器 /bin/bash`
    + $ `mongo` 即可操作mongo命令行
+ 安装时已开启验证，账号在.env中配置
    + 选择数据库（admin数据库是默认创建的）：$ `use admin`
    + 输入验证：`db.auth("root","123456")`
+ php常用的mongo客户端有两个：mongo和mongodb，这里使用mongodb
    + php中查询测试：
    ```
        <?php
        	$manager = new MongoDB\Driver\Manager("mongodb://root:123456@mongo:27017");  
        	// 插入数据
        	$bulk = new MongoDB\Driver\BulkWrite;
        	$bulk->insert(['x' => 1, 'name'=>'测试1', 'url' => 'http://www.baidu.com']);
        	$bulk->insert(['x' => 2, 'name'=>'测试2', 'url' => 'http://www.google.com']);
        	$bulk->insert(['x' => 3, 'name'=>'测试3', 'url' => 'http://www.taobao.com']);
        	$manager->executeBulkWrite('test.sites', $bulk);
        	$filter = ['x' => ['$gt' => 1]];
        	$options = [
        	    'projection' => ['_id' => 0],
        	    'sort' => ['x' => -1],
        	];
        	// 查询数据
        	$query = new MongoDB\Driver\Query($filter, $options);
        	$cursor = $manager->executeQuery('test.sites', $query);
        	foreach ($cursor as $document) {
        	    print_r($document);
        	}
        ?>
    ```
    
## 七. nginx配置说明
+ 默认的nginx配置已支持yii2的运行
+ 如项目放在 `/var/www/order`
    + .env中，`WEB_DIR=/var/www/order`
    + nginx.conf中， `root /var/www/order/backend/web;`
+ nginx和php-fpm必须挂载相同的项目目录，否则会导致静态文件可以访问，php无法访问

## 八. memcached使用
1. mem常用的php客户端有两个：`memcached`和`memcache`，这里使用`memcached`
2. yii2默认支持`memcached`作为缓存系统，只需如下配置：在`common/config/main-local.php`中
    ```
   'cache' => [
            'class' => 'yii\caching\MemCache',
            'servers' => [
                [
                    'host' => 'memcached',
                    'port' => 11211
                ],
            ],
            'useMemcached'=>true,
            'keyPrefix'=>'yikong'
    ],
   ```
    
3. 其他框架的环境正常连接即可，只需注意host是容器的名称，不能使用ip

## 九. redis使用
1. 使用`predis`客户端，直接在项目中`composer require predis/predis`安装即可
2. 连接测试，需注意host是容器名称
   ```
   <?php
   namespace backend\controllers;
   use Predis\Autoloader;
   use Predis\Client;
   use yii\web\Controller;
   
   class TestController extends Controller
   {
       public function actionIndex()
       {
           $client =new Client([
               'scheme' => 'tcp',
               'host'   => 'redis',
               'port'   => 6379,
           ]);
           var_dump($client);
           $client->set('foo', 'bar5');
           echo $value = $client->get('foo');
       }
   }
   ```

## 十. cron的使用
1. 区分`cron`和`crond`：都是做计划任务的，不同的系统中进程名称不一样。由于容器中没有yum命令（当然也可以安装），就用了Ubuntu的apt-get下载相关应用
2. `/etc/crontab`任务文件挂载到了`services/php/cron/crontab`，直接修改即可（和`crontab -e`的区别：百度），挂载到项目目录修改更方便
3. 一定注意`crontab`文件的权限只能是`644`，否则任务不会被执行，如果是启动后才修改权限为644，需要进容器重启cron
4. cron的相关命令
    1. `service cron status` # 查看cron状态
    2. `service cron start`  # 启动cron
    3. `service cron stop`   # 停止cron
5. 测试 `* * * * * root echo 123 >> /tmp/60.txt`
6. 容器中使用cron的三种方式分析
    1. 使用主机中的cron
    2. 创建一个新容器专门用于cron
    3. cron和其他进程共用一个容器（比如本次搭建cron和php-fpm共用一个容器）
    
## 十一. 基于docker的mysql配置主从同步
### 配置文件
1. 关键点
    ```
   [mysqld]
   log-bin=mysql-bin #一般默认开启
   server-id=1       #不一定是1，但一定要唯一，不能和从服务器重复
    ```
### 主服务器配置步骤 master
1. 在master服务器上需要创建一个账号，专门用来复制binlog
   ```
   $ grant replication slave on *.* to 'masterslave'@'%' identified by '123456' with grant option; # 用户名 masterslave,host为%，从slave登录到master属于远程登录
   $ flush privileges;
   $ mysql -umasterslave -hmaster -p123456 # 在从服务器slave上登录master，测试账号是否可用
   ```
2. 查看master节点的binlog状态，记住这个File和Position的值。
    最好每次`show master status;`前都 `flush privileges;`获取的值才准确
    ```
    mysql> show master status;
    +------------------+----------+--------------+------------------+-------------------+
    | File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
    +------------------+----------+--------------+------------------+-------------------+
    | mysql-bin.000010 |     1994 |              |                  |                   |
    +------------------+----------+--------------+------------------+-------------------+
    1 row in set (0.00 sec)
    ```
### 从服务器配置步骤 slave
1. $ `stop slave;` # 关闭slave
2. $ `change master to master_host='master',master_user='masterslave',master_log_file='mysql-bin.000010',master_log_pos=4334,master_port=3306,master_password='123456';` 
    0. 构建时`master`和`slave`是不同的容器，但是在相同的网络下
    1. `master_host` 不是ip，而是容器名称
    2. `master_user` 是在master上建立的复制账号
    3. `master_password` master上建立的复制账号密码
    4. `master_port` 一定是master容器中mysql的端口，而不是映射到主机的端口
3. $ `start slave;` # 开启
4. 查看主从是否成功
```
mysql> show slave status\G;
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: master
                  Master_User: masterslave
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000010
          Read_Master_Log_Pos: 4334
               Relay_Log_File: 692d43f1f112-relay-bin.000002
                Relay_Log_Pos: 320
        Relay_Master_Log_File: mysql-bin.000010
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
```
5. 到此主从就可以正常使用了，**平滑重启mysql** `docker stop name`、`docker start name`，不要去--force-recreate，这样就只能重新查看File、Position来重新配置了

## 十二. 主从同步的基础上加入atlas
### 安装前
1. `atlas` 官方文档 `https://github.com/Qihoo360/Atlas/wiki`
2. 本实例是在`centos`镜像下使用使用官方推荐的rpm方式安装了`atlas`
3. 有关配置项的解释以及可能出现的问题请研读官方文档
4. 配置文件中需要注意的点：
    1. `proxy-backend-addresses = master:3306` # 容器名称:容器内mysql端口
    2. `proxy-read-only-backend-addresses = slave:3306@1` # 容器名称:容器内mysql端口
    3. `daemon = false` # 不要设置后台运行，当容器中没有前台进程在运行，容器会自动退出
    
### 安装后
1. $ `mysql -hcentos -uroot -p12345678 -P2345` # 在mysql容器中（master或slave）尝试连接atlas
    1. 注意：-h 不是ip而是容器名，由于atlas是基于centos镜像的，所以这里是centos
    2. -u -p 用户名和密码是在`test.cnf`中配置的管理接口的用户名、密码
    3. -P 端口是在`test.cnf`中配置的管理接口的端口
2. $ `select * from help;` # 进入atlas后，命令帮助来显示所有命令
3. 命令记录
```
mysql> select * from help;
+----------------------------+---------------------------------------------------------+
| command                    | description                                             |
+----------------------------+---------------------------------------------------------+
| SELECT * FROM help         | shows this help                                         |
| SELECT * FROM backends     | lists the backends and their state                      |
| SET OFFLINE $backend_id    | offline backend server, $backend_id is backend_ndx's id |
| SET ONLINE $backend_id     | online backend server, ...                              |
| ADD MASTER $backend        | example: "add master 127.0.0.1:3306", ...               |
| ADD SLAVE $backend         | example: "add slave 127.0.0.1:3306", ...                |
| REMOVE BACKEND $backend_id | example: "remove backend 1", ...                        |
| SELECT * FROM clients      | lists the clients                                       |
| ADD CLIENT $client         | example: "add client 192.168.1.2", ...                  |
| REMOVE CLIENT $client      | example: "remove client 192.168.1.2", ...               |
| SELECT * FROM pwds         | lists the pwds                                          |
| ADD PWD $pwd               | example: "add pwd user:raw_password", ...               |
| ADD ENPWD $pwd             | example: "add enpwd user:encrypted_password", ...       |
| REMOVE PWD $pwd            | example: "remove pwd user", ...                         |
| SAVE CONFIG                | save the backends to config file                        |
| SELECT VERSION             | display the version of Atlas                            |
+----------------------------+---------------------------------------------------------+
16 rows in set (0.00 sec)

mysql> SELECT * FROM backends
    -> ;
+-------------+-----------------+-------+------+
| backend_ndx | address         | state | type |
+-------------+-----------------+-------+------+
|           1 | 172.20.0.4:3306 | up    | rw   |
|           2 | 172.20.0.7:3306 | up    | ro   |
+-------------+-----------------+-------+------+
2 rows in set (0.00 sec)
```
4. `Navicat`远程连接`atlas`
    1. IP：192.168.157.134 主机的ip
    2. 端口：1234  atlas配置文件中的 `proxy-address`
    3. 用户：atlas配置文件中的 `pwds` 
5. `yii2.0`中连接atlas，测试curd
> 在/common/config/main-local.php中：
 ```
'db' => [
    'class' => 'yii\db\Connection',
    'dsn' => 'mysql:host=centos;port=1234;dbname=order',#用php连接atlas使用容器名
    'username' => 'root',
    'password' => '123456',
    'charset' => 'utf8',
],
 ```
> 测试写入
```
return Yii::$app->db->createCommand()->insert('user', [
            'name' => 'Sam',
            'age' => 30,
            'sex' => 0
        ])->execute();
```
6. 通过sql日志查看读写分离是否生效
> 开启日志，在atlas配置文件test.cnf中
```
log-level = message
log-path = /usr/local/mysql-proxy/log
sql-log = REALTIME # sql日志需开启（默认关闭）且模式是REALTIME（实时写入磁盘）,ON的话写入磁盘不实时，sql_test.log为空
#sql-log-slow = 1000 # 慢日志必须关闭，否则只记录慢日志
```
> 查看日志，在logs/mysql-cluster/atlas/sql_test.log
```
以下对比可发现读的IP是.5，写的IP是.3
[04/03/2020 22:16:35] C:172.21.0.4:48606 S:172.21.0.5:3306 OK 102.693 "SHOW FULL COLUMNS FROM `user`"
[04/03/2020 22:16:35] C:172.21.0.4:48606 S:172.21.0.3:3306 OK 19.518 "INSERT INTO `user` (`name`, `age`, `sex`) VALUES ('Sam', 30, '0')"
```
## 十三. 官方文档
1. [https://docs.docker.com/compose/compose-file/](https://docs.docker.com/compose/compose-file/) # `docker-compose.yml`规范文档
