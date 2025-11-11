#!/bin/bash
set -e

# Update system packages
apt update -y
apt upgrade -y

# Install basic tools
apt install -y curl wget git htop unzip

# Install Docker
apt install -y docker.io
systemctl start docker
systemctl enable docker

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
  }
}
EOF

systemctl restart docker

# Create directories for RagFlow
mkdir -p /opt/ragflow/data
mkdir -p /opt/ragflow/logs
mkdir -p /opt/ragflow/uploads
chmod -R 755 /opt/ragflow

# Set up nice prompt for ubuntu user
UBUNTU_HOME="/home/ubuntu"
echo "PROMPT_COMMAND=''" >> $UBUNTU_HOME/.bashrc
echo "export PS1=\"\n\[\033[1;32m\]\u@\h\[\033[0m\]:\[\033[1;34m\]\w\[\033[0m\]\$ \"" >> $UBUNTU_HOME/.bashrc
echo "alias ls='ls --color=auto'" >> $UBUNTU_HOME/.bashrc
echo "alias grep='grep --color=auto'" >> $UBUNTU_HOME/.bashrc
# Make sure the ubuntu user owns these changes
chown ubuntu:ubuntu $UBUNTU_HOME/.bashrc