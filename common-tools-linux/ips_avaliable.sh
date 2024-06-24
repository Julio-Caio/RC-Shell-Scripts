#!/bin/bash

available_ips() {
    local network_prefix="192.168.0"  # Substituir pelo prefixo da sua rede

    if ! command -v fping &> /dev/null; then
        echo "Comando fping não está instalado! Instalando..."
        sudo apt update && sudo apt install -y fping
        echo "Instalado!"
    fi

    # Gerar a lista de todos os IPs no intervalo
    local all_ips=$(seq 1 254 | awk -v prefix="$network_prefix" '{print prefix"."$1}')

    # Obter os IPs em uso
    local used_ips=$(fping -a -g "${network_prefix}.0/24" 2>/dev/null)

    # Verificar se há IPs usados
    if [ -z "$used_ips" ]; then
        echo "Nenhum IP está em uso na rede."
        return 0
    fi

    # Filtrar os IPs disponíveis
    local available_ips=()
    for ip in $all_ips; do
        if ! echo "$used_ips" | grep -q "$ip"; then
            available_ips+=("$ip")
        fi
    done

    if [ ${#available_ips[@]} -eq 0 ]; then
        echo -e "\e[91mNenhum IP disponível\e[0m"
    else
        # Imprimir os IPs disponíveis em verde
        for ip in "${available_ips[@]}"; do
            echo -e "\e[32m$ip\e[0m"
        done
    fi
}

available_ips

