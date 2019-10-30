#!/bin/bash

set -e

export DEBIAN_FRONTEND=noninteractive

# Create `deployer` user
adduser --disabled-password deployer < /dev/null
mkdir -p /home/deployer/.ssh
cp /root/.ssh/authorized_keys /home/deployer/.ssh
chown -R deployer:deployer /home/deployer/.ssh
chmod 600 /home/deployer/.ssh/authorized_keys
mkdir -p /var/www
chown deployer:deployer /var/www
mkdir -p /var/lib/systemd/linger
touch /var/lib/systemd/linger/deployer

# Packages needed for ruby, etc.
apt-get -y update
apt-get -y install build-essential zlib1g-dev libssl-dev libreadline-dev \
                   git-core curl locales libsqlite3-dev

apt-get -y install tzdata \
        -o DPkg::options::="--force-confdef" \
        -o DPkg::options::="--force-confold"

locale-gen en_US.UTF-8

# Install and configure sshd
apt-get -y install openssh-server
echo "Port 22" >> /etc/ssh/sshd_config
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config
mkdir /var/run/sshd
chmod 0755 /var/run/sshd
