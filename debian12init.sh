#!/bin/bash

# 当脚本遇到错误时立即退出
set -e

# 备份原始的sources.list文件
cp /etc/apt/sources.list /etc/apt/sources.list.backup

# 使用新的源地址直接写入sources.list
cat > /etc/apt/sources.list << EOF
deb http://mirrors.ustc.edu.cn/debian bookworm main contrib
deb http://mirrors.ustc.edu.cn/debian bookworm-updates main contrib
deb http://mirrors.ustc.edu.cn/debian-security bookworm-security main contrib
EOF

# 更新系统包列表并安装基础及开发工具
apt-get update -y
apt-get install -y wget curl vim git unzip screen tmux build-essential libssl-dev zlib1g-dev \
libbz2-dev libpcap-dev libreadline-dev libsqlite3-dev llvm libncurses5-dev libncursesw5-dev \
libgdbm-dev libnss3-dev libffi-dev xz-utils tk-dev liblzma-dev pipx

# 将pipx添加到PATH环境变量中
export PATH=$PATH:/root/.local/bin

# 安装Go语言环境
source <(curl -L https://go-install.netlify.app/install.sh)

# 安装Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# 获取最新稳定版本的Docker Compose
COMPOSE_VERSION=$(curl -s "https://cdn.jsdelivr.net/gh/docker/compose@gh-pages/compose/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

# 下载并安装Docker Compose
curl -L "https://cdn.jsdelivr.net/gh/docker/compose/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# 验证安装
docker --version
docker-compose --version

# 安装Node.js
curl -fsSL https://deb.nodesource.com/setup_14.x | bash -
apt-get install -y nodejs

# 设置npm和yarn使用国内镜像
npm cache clean --force
npm config set registry https://registry.npmmirror.com
npm install -g yarn
yarn config set registry https://registry.npmmirror.com/

# go安装bugbounty工具
go install github.com/lc/gau/v2/cmd/gau@latest
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest

# 安装ksubdomain最新版本
KSUBDOMAIN_LATEST=$(curl -s "https://cdn.jsdelivr.net/gh/knownsec/ksubdomain@latest" | grep '/ksubdomain_linux.zip' | sed -E 's/.*href="([^"]+)".*/\1/' | head -n 1)
wget "https://github.com${KSUBDOMAIN_LATEST}" -O ksubdomain_linux.zip
unzip ksubdomain_linux.zip && chmod +x ./ksubdomain

# 安装katana最新版本
KATANA_LATEST=$(curl -s "https://cdn.jsdelivr.net/gh/projectdiscovery/katana@latest" | grep '/katana_.*_linux_amd64.zip' | sed -E 's/.*href="([^"]+)".*/\1/' | head -n 1)
wget "https://github.com${KATANA_LATEST}" -O katana_linux_amd64.zip
unzip katana_linux_amd64.zip && chmod +x ./katana && ./katana
