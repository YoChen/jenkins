# 使用官方Jenkins LTS作为基础镜像
FROM jenkins/jenkins:2.452.2-lts-jdk21

USER root

# 更新apt源并安装必要的工具
RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor | tee /usr/share/keyrings/docker-archive-keyring.gpg > /dev/null && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 设置Docker socks以允许Jenkins容器与宿主机Docker daemon通信（仅当使用Docker-in-Docker时需要）
ARG DOCKER_HOST=unix:///var/run/docker.sock
ENV DOCKER_HOST ${DOCKER_HOST}

# 安装dotnet 8.0
RUN curl -L "https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb" -o packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && rm packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y dotnet-sdk-8.0

# 清理apt缓存，减少镜像大小
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# 设置Jenkins用户环境变量，以便在构建中使用Docker
RUN usermod -aG docker jenkins

USER jenkins