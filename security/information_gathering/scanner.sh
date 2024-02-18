#!/bin/bash

# Função para verificar se o pacote está instalado
isInstalled() {
    if ! dpkg -s "$1" > /dev/null 2>&1; then
        return 1
    else
        return 0
    fi
}

# Função para verificar se o usuário é root
areYouRoot() {
    if ["$EUID" -ne 0]; then
        return 1
    else
        return 0
    fi
}

# Verifica se o usuário é root
if ! areYouRoot; then
    echo "Por favor, execute o script como root."
    exit 1
fi

# Função de varredura de vulnerabilidades em um IP alvo
varredura() {
    target_ip=$1
    echo "Quais das seguintes opções de varredura você quer executar?"
    echo "
                Menu - Information Gathering
    ======================================================================
    (1) Varredura SYN:                     nmap -sS -sV [ip alvo]
    (2) Varredura Agressiva:               nmap -sS -A [ip alvo]
    (3) Varredura de Enumeração de Hosts:  nmap -sN -O [ip alvo]
    
    [ Quais das seguintes opções gostaria de realizar? ]"
    
    echo -e "\n"
    read -p "> Digite a opção desejada: " opcao

    if [ "$opcao" == "1" ]; then
        nmap -sS -sV "$target_ip" -oN scan.txt
    elif [ "$opcao" == "2" ]; then
        nmap -sS -A "$target_ip" -oN scan.txt
    elif [ "$opcao" == "3" ]; then
        target_ip_sem_ultimo_oct=$(echo "$target_ip" | awk -F'.' '{print $1"."$2"."$3}')
	subrede="$target_ip_sem_ultimo_oct.0/24"
        nmap -sN -O "$subrede" -oN scan.txt
    else
        echo -e "\nOpção inválida"
    fi
}

# Verifica se o pacote nmap está instalado
while true; do
    if ! isInstalled "nmap"; then
        echo "Nmap não está instalado no sistema."
        echo -e "\nDeseja instalar o nmap? (s/n)"
        read -p "Digite a opção desejada: " opcao
        if [ "$opcao" == "s" ]; then
            apt-get install nmap
            echo "Digite o seu IP alvo para realizar a varredura."
            read -p "Digite o IP alvo: " target_ip
            varredura "$target_ip"
        else
            echo "Instalação do nmap cancelada."
        fi
    else
        echo -e "\nDigite o seu IP alvo para realizar a varredura."
        read -p "> Digite o IP alvo: " target_ip
        varredura "$target_ip"
    fi
done

# Fim do script