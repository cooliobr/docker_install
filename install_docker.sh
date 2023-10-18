   #!/bin/bash
   curl -fsSL https://get.docker.com -o get-docker.sh
   sh get-docker.sh
   VERSION=$(curl --silent https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*\d')
   DESTINATION=/usr/local/bin/docker-compose
   sudo curl -L https://github.com/docker/compose/releases/download/${VERSION}/docker-compose-$(uname -s)-$(uname -m) -o $DESTINATION
   ls -l /usr/local/bin/docker-compose && chmod 755 /usr/local/bin/docker-compose
   /usr/local/bin/docker-compose -v
   ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
   mkdir /opt/ssl && mkdir /opt/conf && chmod 755 /opt/ssl && chmod 755 /opt/conf
   distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
      && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
      && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
            sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
            sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
apt-get update
apt-get install -y nvidia-container-toolkit
mkdir -p /etc/systemd/system/docker.service.d
tee /etc/systemd/system/docker.service.d/override.conf <<EOF
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd --host=fd:// --add-runtime=nvidia=/usr/bin/nvidia-container-runtime
EOF
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
  nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
nvidia-ctk runtime configure --runtime=docker --set-as-default
systemctl restart docker
