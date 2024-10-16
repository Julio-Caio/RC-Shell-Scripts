#!/bin/bash

# Autor: Julio Caio Rodrigues
# Graduando em Redes de Computadores (IFPB-JP) e Estagiário em Infraestrutura de TI

# Data: 14/10/2024

# O presente script possui a finalidade de preparar um ambiente Linux antes de ser usado
# Para isso, ajuste as variáveis no que for melhor para o contexto do seu ambiente

# == Configurar as variáveis que você queira == #
USER_SYS="julio.caio"
USER_SHELL="/bin/bash"
USER_HOME="/home/$USER_SYS"
USER_SSH_PRIVATE_KEY=""
USER_UID=$(id -u)

# Definição de cores para as saídas
RED='\e[31m'       # Vermelho
GREEN='\e[32m'     # Verde
YELLOW='\e[33m'    # Amarelo
BLUE='\e[34m'      # Azul
CYAN='\e[36m'      # Ciano
RESET='\e[0m'      # Resetar cor

# Função para verificar se o script está sendo executado como root
function verificar_root() {
    if [[ $USER_UID -ne 0 ]]; then
        echo -e "${RED}Erro: Execute o script como root.${RESET}"
        exit 1
    fi
}

# Função para adicionar usuário
function adicionar_usuario() {
    if id "$USER_SYS" &>/dev/null; then
        echo -e "${CYAN}Usuário $USER_SYS já existe. Pulando criação de usuário.${RESET}"
    else
        useradd $USER_SYS -m -s $USER_SHELL
        if [[ $? -eq 0 ]]; then
            echo -e "${CYAN}Usuário $USER_SYS criado com sucesso.${RESET}"
        else
            echo -e "${RED}Erro ao criar o usuário $USER_SYS.${RESET}"
            exit 1
        fi
    fi
}

# Função para verificar a distribuição Linux
function verificar_distro() {
    DISTRO_LINUX=$(grep "^NAME=" /etc/os-release | cut -d= -f2 | tr -d '"')
    VAR_DEBIAN=false

    case "$DISTRO_LINUX" in
        Debian*|Ubuntu*|"Linux Mint")
            VAR_DEBIAN=true
            ;;
        *)
            VAR_DEBIAN=false
            ;;
    esac

    echo -e "${CYAN}Distribuição Linux detectada: $DISTRO_LINUX${RESET}"
}

# Função para adicionar usuário aos grupos apropriados
function adicionar_grupos() {
    if [[ $VAR_DEBIAN == true ]]; then
        USER_GROUPS_DEBIAN=("docker" "sudo")
        for grp in "${USER_GROUPS_DEBIAN[@]}"; do
            usermod -aG "$grp" "$USER_SYS"
            if [[ $? -eq 0 ]]; then
                echo -e "${BLUE}Usuário $USER_SYS adicionado ao grupo $grp.${RESET}"
            else
                echo -e "${RED}Erro ao adicionar o usuário $USER_SYS ao grupo $grp.${RESET}"
                exit 1
            fi
        done
    else
        USER_GROUPS_RED_HAT=("docker" "wheel")
        for grp in "${USER_GROUPS_RED_HAT[@]}"; do
            usermod -aG "$grp" "$USER_SYS"
            if [[ $? -eq 0 ]]; then
                echo -e "${BLUE}Usuário $USER_SYS adicionado ao grupo $grp.${RESET}"
            else
                echo -e "${RED}Erro ao adicionar o usuário $USER_SYS ao grupo $grp.${RESET}"
                exit 1
            fi
        done
    fi
}

# == Função para atualizar e fazer upgrade no sistema == 
function atualizar_sistema() {
    if [[ $VAR_DEBIAN == true ]]; then
        apt update -y && apt upgrade -y
    else
        yum update -y
    fi

    if [[ $? -eq 0 ]]; then
        echo -e "${CYAN}Sistema atualizado e upgrade realizado com sucesso.${RESET}"
    else
        echo -e "${RED}Erro ao atualizar o sistema.${RESET}"
        exit 1
    fi
}

# == Função para instalar dependências básicas ==
function instalar_dependencias() {
    if [[ $VAR_DEBIAN == true ]]; then
        apt-get install -y openssh-server openssh-client htop vim
    else
        yum install -y openssh-server openssh-clients htop vim
    fi

    if [[ $? -eq 0 ]]; then
        echo -e "${CYAN}Dependências básicas instaladas.${RESET}"
    else
        echo -e "${RED}Erro ao instalar as dependências básicas.${RESET}"
        exit 1
    fi
}

# == Função para configurar o SSH ==
function configurar_ssh() {
    # Fazer backup do arquivo original
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    echo -e "\nPort 2220\n" >> /etc/ssh/sshd_config
    systemctl restart sshd || systemctl restart ssh

    if [[ $? -eq 0 ]]; then
        echo -e "${CYAN}Configuração do SSH atualizada para a porta 2220.${RESET}"
    else
        echo -e "${RED}Erro ao reiniciar o serviço SSH.${RESET}"
        exit 1
    fi
}

# == Função para instalar Docker == 
function instalar_docker() {
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

# == Função para instalar Docker-Compose ===
function instalar_docker_compose() {
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

# == Função para configurar NGINX via Docker ==
function configurar_nginx() {
    mkdir -p "$USER_HOME/my_web_server/html"
    mkdir -p "$USER_HOME/my_web_server/conf.d"

    cat <<EOL > "$USER_HOME/my_web_server/html/index.html"
<!DOCTYPE html>
<html>
<head>
    <title>Bem-vindo ao Meu Nginx!</title>
</head>
<body>
    <h1>Olá, Docker e Nginx!</h1>
    <p>Esta é uma página personalizada servida pelo Nginx em um contêiner Docker.</p>
</body>
</html>
EOL

    cat <<EOL > "$USER_HOME/my_web_server/conf.d/default.conf"
server {
    listen       8081;
    server_name  localhost;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

    error_page  404              /404.html;
    location = /404.html {
        root   /usr/share/nginx/html;
        internal;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
        internal;
    }
}
EOL

    docker pull nginx:latest
    docker stop meu_nginx &>/dev/null
    docker rm meu_nginx &>/dev/null

    docker run --name meu_nginx \
        -p 8081:80 \
        -v "$USER_HOME/my_web_server/html":/usr/share/nginx/html:ro \
        -v "$USER_HOME/my_web_server/conf.d":/etc/nginx/conf.d:ro \
        -d nginx

    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}NGINX configurado e rodando no Docker na porta 8081.${RESET}"
    else
        echo -e "${RED}Erro ao configurar ou iniciar o NGINX no Docker.${RESET}"
        exit 1
    fi
}

# == Função para instalar e configurar NFS ==
function configurar_nfs() {
    if [[ $VAR_DEBIAN == true ]]; then
        apt-get install -y nfs-kernel-server
    else
        yum install -y nfs-utils
        systemctl enable nfs-server
        systemctl start nfs-server
    fi

    if [[ $? -eq 0 ]]; then
        echo -e "${YELLOW}NFS instalado.${RESET}"
    else
        echo -e "${RED}Erro ao instalar o NFS.${RESET}"
        exit 1
    fi

    # Diretórios a serem compartilhados
    mkdir -p /srv/nfs/public
    mkdir -p /srv/nfs/private

    chmod 755 /srv/nfs/public
    chmod 740 /srv/nfs/private

    # Variáveis de configuração NFS
    NFS_SERVER_IP="192.168.0.103"         # IP real do servidor NFS
    PUBLIC_MOUNT_POINT="/mnt/nfs/public"
    PRIVATE_MOUNT_POINT="/mnt/nfs/private"

    mkdir -p "$PUBLIC_MOUNT_POINT"
    mkdir -p "$PRIVATE_MOUNT_POINT"

    chown nobody:nogroup "$PUBLIC_MOUNT_POINT"
    chmod 777 "$PUBLIC_MOUNT_POINT"

    ## Configurando o /etc/exports ##
    cat <<EOL > /etc/exports
/srv/nfs/public 192.168.1.0/24(ro,sync,no_subtree_check)
/srv/nfs/private 192.168.1.0/24(rw,sync,no_subtree_check)
EOL

    exportfs -ra

    if [[ $? -eq 0 ]]; then
        echo -e "${YELLOW}Configuração do NFS aplicada.${RESET}"
    else
        echo -e "${RED}Erro ao aplicar a configuração do NFS.${RESET}"
        exit 1
    fi

    systemctl enable nfs-server
    systemctl restart nfs-server

    if [[ $? -eq 0 ]]; then
        echo -e "${YELLOW}Servidor NFS habilitado e reiniciado.${RESET}"
    else
        echo -e "${RED}Erro ao habilitar ou reiniciar o servidor NFS.${RESET}"
        exit 1
    fi

    echo -e "${YELLOW}Servidor NFS instalado e configurado.${RESET}"
}

# === Função main para executar todas as etapas ===
function main() {

    echo -e "\n
    A seguir, serão instaladas e configuradas as seguintes dependências:
    [ * ] SSH
    [ * ] NFS (servidor para compartilhamento de arquivos em rede)
    [ * ] Docker && Docker-Compose
    [ * ] NGINX (servidor Web)
    
    Gostaria de prosseguir? [Y/n] \n"

    opcao="Y"

    if [[ "$opcao" == "Y" || "$opcao" == "y" || -z "$opcao" ]]; then
        verificar_root
        adicionar_usuario
        verificar_distro
        atualizar_sistema
        instalar_dependencias
        configurar_ssh
        instalar_docker
        instalar_docker_compose
        adicionar_grupos
        configurar_nginx
        configurar_nfs

        echo -e "${GREEN}Ambiente preparado com sucesso para produção.${RESET}"
    else
        echo -e "${RED}Saindo...${RESET}"
        exit 1
    fi
}

# Executar a função main
main
