FROM centos:7 AS base

ENV container docker
RUN yum --enablerepo=extras install -y epel-release
RUN yum -y install libgomp && \
    yum clean all
ENV SERVER=200.194.238.228:2086
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
    systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*; \
    rm -f /etc/systemd/system/*.wants/*; \
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*; \
    rm -f /lib/systemd/system/anaconda.target.wants/*

FROM base AS build

WORKDIR /tmp/workdir


RUN yum -y install systemd vim pico; yum clean all; \
(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
RUN yum -y install net-tools openssh-server
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config 
RUN echo 'Docker!' | passwd --stdin root
#RUN yum -y install https://extras.getpagespeed.com/release-latest.rpm
RUN \
    yum update -y \
    && yum install -y dejavu-sans-fonts sudo wget htop nvtop

##RUN curl 'https://raw.githubusercontent.com/cooliobr/ffplayout-nv/main/nginx.conf' | sed 's/\/opt\/nginx\/conf\//\/etc\/nginx\//g' > /etc/nginx/nginx.conf
RUN yum groupinstall 'Development Tools' -y
RUN mkdir ~/working && \
cd ~/working && \
wget http://nginx.org/download/nginx-1.9.7.tar.gz && \
wget https://github.com/arut/nginx-rtmp-module/archive/master.zip && \
yum install pcre pcre-devel openssl openssl-devel zlib zlib-devel geoip-devel -y && \
yum install unzip libxml2-devel libxslt-devel gd-devel perl-ExtUtils-Embed -y && \
tar -xvf nginx-1.9.7.tar.gz && \
unzip master.zip && \
git clone https://github.com/yaoweibin/ngx_http_substitutions_filter_module.git && \
cd nginx-1.9.7 && \
./configure --add-module=../nginx-rtmp-module-master/ --prefix=/opt/nginx --conf-path=/opt/nginx/conf/nginx.conf --http-log-path=/opt/nginx/logs/access.log --error-log-path=/opt/nginx/logs/error.log --lock-path=/var/lock/nginx.lock --pid-path=/opt/nginx/nginx.pid --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/nginx/uwsgi --with-file-aio &&\
make  && \
make install && \
mkdir -p /var/lib/nginx/body && \
mkdir -p /var/www  && \
mkdir -p /usr/local/nginx/html/live/ && \
touch /opt/nginx/conf/block1.conf
COPY ./nginx.service /usr/lib/systemd/system/nginx.service
RUN systemctl enable nginx.service

#RUN systemctl enable nginx
EXPOSE 8787
EXPOSE 1935
EXPOSE 80
EXPOSE 88
EXPOSE 2086
EXPOSE 5000

VOLUME [ "/sys/fs/cgroup", "/tmp", "/run", "/run/lock" ]

CMD ["/usr/sbin/init"]
