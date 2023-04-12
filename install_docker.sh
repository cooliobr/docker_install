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
