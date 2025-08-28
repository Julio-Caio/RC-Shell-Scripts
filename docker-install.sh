#!/bin/bash

# Instalação do Docker e Docker-Compose
 
instalar_docker() {
    if [[ $VAR_DEBIAN == true ]]; then
        apt-get remove -y docker docker-engine docker.io containerd runc
        apt-get install -y ca-certificates curl gnupg lsb-release
        curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
        apt-get update -y
        apt-get install -y docker-ce docker-ce-cli containerd.io
    else
        yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
        yum install -y yum-utils
        yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        yum install -y docker-ce docker-ce-cli containerd.io
    fi

    systemctl start docker
    systemctl enable docker

    if [[ $? -eq 0 ]]; then
        echo -e "${BLUE}Docker instalado e iniciado.${RESET}"
    else
        echo -e "${RED}Erro ao instalar ou iniciar o Docker.${RESET}"
        exit 1
    fi
}

instalar_docker_compose() {
    COMPOSE_VERSION="2.0.1"
    curl -L "https://github.com/docker/compose/releases/download/v$COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

    if [[ $? -eq 0 ]]; then
        echo -e "${BLUE}Docker-Compose versão $COMPOSE_VERSION instalado.${RESET}"
    else
        echo -e "${RED}Erro ao instalar o Docker-Compose.${RESET}"
        exit 1
    fi
}

instalar_docker_compose
