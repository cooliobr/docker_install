FROM centos:7 AS base

ENV container docker
RUN yum --enablerepo=extras install -y epel-release
RUN yum -y install libgomp && \
    yum clean all

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

RUN curl 'https://raw.githubusercontent.com/cooliobr/ffplayout-nv/main/nginx.conf' | sed 's/\/opt\/nginx\/conf\//\/etc\/nginx\//g' > /etc/nginx/nginx.conf
RUN touch /etc/nginx/upstream_local.conf
RUN touch /etc/nginx/block1.conf
RUN echo 'server 200.194.238.228:2086;' > /etc/nginx/upstream.conf
RUN yum install pcre pcre-devel openssl openssl-devel zlib zlib-devel unzip libxml2-devel libxslt-devel gd-devel perl perl-devel perl-ExtUtils-Embed gperftools -y
RUN yum groupinstall 'Development Tools' -y
RUN mkdir ~/working
RUN cd ~/working
RUN wget https://github.com/arut/nginx-rtmp-module/archive/master.zip
RUN wget http://nginx.org/download/nginx-1.20.1.tar.gz
RUN tar -xvf nginx-1.20.1.tar.gz
RUN unzip v1.2.1.zip
RUN cd nginx-1.20.1
RUN ./configure --add-module=../nginx-rtmp-module-master/
RUN ./configure --prefix=/usr/share/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib64/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --http-client-body-temp-path=/var/lib/nginx/tmp/client_body --http-proxy-temp-path=/var/lib/nginx/tmp/proxy --http-fastcgi-temp-path=/var/lib/nginx/tmp/fastcgi --http-uwsgi-temp-path=/var/lib/nginx/tmp/uwsgi --http-scgi-temp-path=/var/lib/nginx/tmp/scgi --pid-path=/run/nginx.pid --lock-path=/run/lock/subsys/nginx --user=nginx --group=nginx --with-compat --with-debug --with-file-aio --with-google_perftools_module --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_degradation_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_image_filter_module=dynamic --with-http_mp4_module --with-http_perl_module=dynamic --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-http_xslt_module=dynamic --with-mail=dynamic --with-mail_ssl_module --with-pcre --with-pcre-jit --with-stream=dynamic --with-stream_ssl_module --with-stream_ssl_preread_module --with-threads --with-cc-opt='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -specs=/usr/lib/rpm/redhat/redhat-hardened-cc1 -m64 -mtune=generic' --with-ld-opt='-Wl,-z,relro -specs=/usr/lib/rpm/redhat/redhat-hardened-ld -Wl,-E' --add-module=../nginx-rtmp-module-master/
RUN make -j5
RUN make install
COPY ./rtmp.conf /etc/nginx/rtmp.conf

RUN mkdir -p /usr/share/nginx/logs/ && mkdir -p /opt/nginx/ && mkdir /var/www/ && mkdir -p /usr/share/nginx/logs/ && mkdir /opt/ssl && mkdir /opt/conf
RUN chmod 777 /usr/share/nginx/logs/ /opt/nginx/ /var/www/ /usr/share/nginx/logs/
RUN systemctl enable nginx
EXPOSE 8787
EXPOSE 1935
EXPOSE 80
EXPOSE 88

VOLUME [ "/sys/fs/cgroup", "/tmp", "/run", "/run/lock" ]

CMD ["/usr/sbin/init"]
