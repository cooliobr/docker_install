   #!/bin/bash
   apt install git curl build-essential wget -y
   update-grub
   curl -fsSL https://get.docker.com -o get-docker.sh
   sh get-docker.sh
   VERSION=$(curl --silent https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*\d')
   DESTINATION=/usr/local/bin/docker-compose
   sudo curl -L https://github.com/docker/compose/releases/download/${VERSION}/docker-compose-$(uname -s)-$(uname -m) -o $DESTINATION
   ls -l /usr/local/bin/docker-compose && chmod 755 /usr/local/bin/docker-compose
   /usr/local/bin/docker-compose -v
   ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
   mkdir /opt/ssl && mkdir /opt/conf && chmod 755 /opt/ssl && chmod 755 /opt/conf
   
tee /etc/systemd/system/astra.service <<EOF
[Unit]
Description=Astra Relay Service
After=network.target

[Service]
ExecStart=/usr/local/src/astra-4/astra --relay
Restart=always
User=root
# Substitua 'seu_usuario' pelo nome de usuário que executará o serviço
WorkingDirectory=/usr/local/src/astra-4/

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload \
  && sudo systemctl restart docker
  systemctl restart docker
cd /usr/local/src/
git clone https://github.com/cesbo/astra-4
cd astra-4 
./configure.sh
make && make install && systemctl enable astra && systemctl restart astra && systemctl start astra
cd /usr/local/src/
