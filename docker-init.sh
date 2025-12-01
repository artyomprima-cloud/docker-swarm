#!/bin/bash
set -xe

# Install Docker
yum update -y
amazon-linux-extras install docker -y || yum install docker -y

# Enable and start Docker service
systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user
