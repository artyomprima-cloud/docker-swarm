# Demo
In this demo you will be able to create a fully functional Docker Swarm cluster on AWS and deploy a WordPress website with a MySQL backend on top of the cluster.

## Pre-requisites
* Make sure you create and assign your own s3 bucket for terraform state in file main.tf
* Make sure that you configured your AWS environment with `aws configure` and have aws cli installed.

## Installation
To complete the full setup it requires two parts: terraform and docker config.

```
terraform init
terraform apply
```

You should now have a VPC, and an ec2 instance running with docker dependencies pre-installed.

Next we will be using command `docker --host` to transfer the docker-swarm configuration onto the ec2 instance that we just created. Before we do that we would need to setup ssh communication between docker and ec2 instance. Edit the file *~/.ssh/config*
```
Host ec2-docker
    HostName ["Your EC2 public IP]
    User ec2-user
    IdentityFile ~/.ssh/ec2-ssh.pem
    StrictHostKeyChecking no
```
Extract your ssh private key from terraform output
```
terraform output -raw private-key > ~/.ssh/ec2-ssh.pem
```
Finalize the docker swarm setup
```
docker --host ssh://ec2-docker swarm init
read -s WP_DB_PASSWORD # Type in your WP database password
docker --host ssh://ec2-docker secret create wp_db_password <<< "$WP_DB_PASSWORD"
read -s MYSQL_ROOT_PASSWORD # Type in your MYSQL password
docker --host ssh://ec2-docker secret create mysql_root_password <<< "$MYSQL_ROOT_PASSWORD"
docker --host ssh://ec2-docker stack deploy -c stack.yml my_stack
```
Check if your stack works properly with docker `--host ssh://ec2-docker stack ls`
