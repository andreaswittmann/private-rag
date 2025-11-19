#!/bin/bash
set -e

# Update system packages
apt update -y
apt upgrade -y
apt install -y docker.io git

# make a nice prompt for ubuntu user, append these commands to the ubuntu's ~/.bashrc file
UBUNTU_USER_HOME="/home/ubuntu"
echo "PROMPT_COMMAND=''" >> $UBUNTU_USER_HOME/.bashrc
echo "export PS1=\"\n\[\033[1;32m\]\u@\h\[\033[0m\]:\[\033[1;34m\]\w\[\033[0m\]\$ \"" >> $UBUNTU_USER_HOME/.bashrc
echo "alias ls='ls --color=auto'" >> $UBUNTU_USER_HOME/.bashrc
echo "alias grep='grep --color=auto'" >> $UBUNTU_USER_HOME/.bashrc
# Make sure the ubuntu user owns these changes
chown ubuntu:ubuntu $UBUNTU_USER_HOME/.bashrc

# Install Docker
systemctl enable docker
systemctl start docker

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Install Docker Compose v2
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

# Configure Docker daemon with production settings
cat > /etc/docker/daemon.json <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "userns-remap": "default"
}
EOF

systemctl restart docker