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
    && yum install -y dejavu-sans-fonts sudo wget htop nvtop nginx psmisc certbot python-certbot-nginx

##RUN curl 'https://raw.githubusercontent.com/cooliobr/ffplayout-nv/main/nginx.conf' | sed 's/\/opt\/nginx\/conf\//\/etc\/nginx\//g' > /etc/nginx/nginx.conf
RUN touch /etc/nginx/upstream_local.conf
RUN touch /etc/nginx/block1.conf
RUN echo 'server $SERVER;' > /etc/nginx/upstream.conf
RUN yum install pcre pcre-devel openssl openssl-devel zlib zlib-devel unzip libxml2-devel libxslt-devel gd-devel perl perl-devel perl-ExtUtils-Embed gperftools -y
RUN yum groupinstall 'Development Tools' -y
COPY ./rtmp.conf /etc/nginx/rtmp.conf
COPY ./nginx.conf /etc/nginx/nginx.conf
RUN mkdir -p /usr/share/nginx/logs/ && mkdir -p /opt/nginx/ && mkdir /var/www/ && mkdir -p /usr/share/nginx/logs/ && mkdir /opt/ssl && mkdir /opt/conf
RUN chmod 777 /usr/share/nginx/logs/ /opt/nginx/ /var/www/ /usr/share/nginx/logs/
RUN systemctl enable nginx
EXPOSE 8787
EXPOSE 1935
EXPOSE 80
EXPOSE 88
EXPOSE 2086
EXPOSE 5000

VOLUME [ "/sys/fs/cgroup", "/tmp", "/run", "/run/lock" ]

CMD ["/usr/sbin/init"]
