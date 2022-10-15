# Nexus-Repository

Nexus Repository is an open source repository that supports many artifact formats, including Docker, Java™, and npm. With the Nexus tool integration, pipelines in your toolchain can publish and retrieve versioned apps and their dependencies by using central repositories that are accessible from other environments.

## Setup

Install [Docker](https://docs.docker.com/engine/install/ubuntu/)

```bash
sudo apt-get update -y
sudo apt-get install -y git curl

git clone https://github.com/amir2b/nexus-repository.git

## Config firewall
sudo ufw allow OpenSSH
sudo ufw --force enable
sudo ufw allow 80/tcp comment "nexus"
sudo ufw allow 81/tcp comment "nexus-monitoring"
sudo ufw allow 8080/tcp comment "nexus-docker"
# sudo ufw status

docker --version

docker compose up

## Get nexus ui passowrd
docker compose exec nexus cat /nexus-data/admin.password
```

After login and change password, write new passowrd in `.env` file and run this command:

```bash
nexus/initial.sh
nexus/docker.sh
nexus/apt.sh
```

## Client

### apt repository:

```bash
sudo cp -i /etc/apt/sources.list /etc/apt/sources.list.BAK

NEXUS_IP=127.0.0.1

sudo sed -i -E "s,^((.+) http://(.*)\.ubuntu\.com/ubuntu/? (.+))$,\2 http://${NEXUS_IP}/apt-$(lsb_release -cs) \4\n\1,g" /etc/apt/sources.list
```

Add the new repository to apt's list of repos:

```bash
echo "deb http://${NEXUS_IP}/${REPO_NAME}/ xenial main" >> /etc/apt/sources.list.d/your-custom.list

apt-get update
```

Authentication:

```bash
echo "machine repository.domain.com" >> /etc/apt/auth.conf
echo "login $NEXUS_USERNAME" >> /etc/apt/auth.conf
echo "password $NEXUS_PASSWORD" >> /etc/apt/auth.conf
apt-get update
```

### docker registry-mirrors:

```bash
sudo nano /etc/docker/daemon.json

{
  "registry-mirrors": [ "http://${NEXUS_IP}:8080" ]
}

sudo systemctl restart docker
```
