FROM centos:7

# 设置时区为上海
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#VOLUME ["${ATLAS_CONF_DIR}","${LOG_DIR}/mysql-cluster/atlas/"]

# Ubuntu软件源选择中国的服务器
#RUN sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
#
COPY ./atlas-2.2.1.el6.x86_64.rpm /tmp/
RUN rpm -i /tmp/atlas-2.2.1.el6.x86_64.rpm

#运行 Atlas，并利用持续打印 Atlas 日志
CMD /usr/local/mysql-proxy/bin/mysql-proxyd test start

