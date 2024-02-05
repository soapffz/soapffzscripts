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
apt-get install -y wget curl docker-compose vim git npm nodejs unzip screen tmux build-essential libssl-dev zlib1g-dev \
libbz2-dev libpcap-dev libreadline-dev libsqlite3-dev llvm libncurses5-dev libncursesw5-dev \
libgdbm-dev libnss3-dev libffi-dev xz-utils tk-dev liblzma-dev pipx

# 验证安装
docker-compose --version

# 确保pipx的路径被添加到环境变量中，即使pipx ensurepath失败也继续执行
pipx ensurepath || true

# 安装go
source <(curl -L https://go-install.netlify.app/install.sh)

# 安装Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# 验证安装
docker --version

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

# 清理apt包
apt autoremove -y
