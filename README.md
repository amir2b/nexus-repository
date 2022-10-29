# Nexus-Repository

Nexus Repository is an open source repository that supports many artifact formats, including Docker, Java™, and npm. With the Nexus tool integration, pipelines in your toolchain can publish and retrieve versioned apps and their dependencies by using central repositories that are accessible from other environments.

# Setup

Install [Docker](https://docs.docker.com/engine/install/ubuntu/)

```shell
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

After login and change password, write new passowrd in `.env` file and restart docker and run this command:

```shell
docker compose down && docker compose up -d

nexus/initial.sh
nexus/docker.sh
nexus/apt.sh
```

# Client

## apt repository:

```shell
sudo cp -i /etc/apt/sources.list /etc/apt/sources.list.BAK

NEXUS_IP=127.0.0.1

sudo sed -i -E "s,^((.+) http://(.*)\.ubuntu\.com/ubuntu/? (.+))$,\2 http://${NEXUS_IP}/apt-$(lsb_release -cs) \4\n\1,g" /etc/apt/sources.list
```

Add the new repository to apt's list of repos:

```shell
echo "deb http://${NEXUS_IP}/${REPO_NAME}/ xenial main" >> /etc/apt/sources.list.d/your-custom.list

apt-get update
```

Add docker repository:

```shell
sudo mkdir -p /etc/apt/keyrings
curl -fsSL http://${NEXUS_IP}/raw-docker/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] http://${NEXUS_IP}/apt-docker $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee -a /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

Authentication:

```shell
echo "machine repository.domain.com" >> /etc/apt/auth.conf
echo "login $NEXUS_USERNAME" >> /etc/apt/auth.conf
echo "password $NEXUS_PASSWORD" >> /etc/apt/auth.conf
apt-get update
```

## docker registry-mirrors:

```shell
echo "{
    \"registry-mirrors\": [\"http://${NEXUS_IP}:8080\"]
}" | sudo tee /etc/docker/daemon.json

sudo systemctl restart docker
```
