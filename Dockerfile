FROM debian:latest

# 设置环境变量，避免交互式选择提示
ENV DEBIAN_FRONTEND=noninteractive
ENV NVM_DIR=/root/.nvm

# 1. 更新软件源并安装基础工具 (zsh, git, vim 等)
RUN apt-get update && apt-get install -y \
    curl \
    git \
    zsh \
    vim \
    wget \
    procps \
    ca-certificates \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 2. 安装 uv (Astral 出品的高性能 Python 包管理工具)
# 直接从官方镜像中复制编译好的二进制文件，高效且干净
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

# 3. 安装 nvm 和 node/npm
# 安装完成后立即激活 nvm 并安装 LTS 版本的 Node.js（自带 npm）
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \
    && . "$NVM_DIR/nvm.sh" \
    && nvm install --lts \
    && nvm use default

# 4. 配置 Zsh 为默认 Shell 并安装 Oh My Zsh (让终端更好看、好用)
RUN chsh -s $(which zsh) \
    && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# 5. 将 nvm 环境变量和加载脚本写入 .zshrc，确保进入 zsh 时 nvm/npm 可用
RUN echo '\n# NVM Configuration\nexport NVM_DIR="$HOME/.nvm"\n[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"\n[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.zshrc

# 设置工作目录
WORKDIR /workspace
