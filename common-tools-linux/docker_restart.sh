#!/bin/bash

#Script para monitorar o processamento de servidores, para que não atinjam um alto processamento. Caso atinja e permaneça durante o período de tempo especificado,
#ele restarta

get_containers() {
    docker ps --format "{{.ID}}"
}

get_container_max_cpu() {
    max_cpu=200
    container_max_cpu=()

    for container_id in $(get_containers); do
        stats=$(docker stats --no-stream $container_id --format "{{.CPUPerc}}")
        cpu_percent=$(echo $stats | awk '{print int($1)}')
        
        if [ "$cpu_percent" -gt 200 ]; then
            container_max_cpu+=("$container_id")
        fi
    done

    echo "${container_max_cpu[@]}"
}

restart() {
    if [ ${#1} -gt 0 ]; then
        container_name=$(docker ps --format "{{.Names}}" | grep -E "${1[0]}")
        docker restart "${container_name}"
        echo "✅ Container [${container_name}] reiniciado com sucesso!"
    else
        echo "Nenhum container com uso de CPU acima de 200%"
    fi
}

echo -e "
 \033[38;5;12m
 
 ____             _               ____           _             _
|  _ \  ___   ___| | _____ _ __  |  _ \ ___  ___| |_ __ _ _ __| |_
| | | |/ _ \ / __| |/ / _ \ '__| | |_) / _ \/ __| __/ _\ | '__| __|
| |_| | (_) | (__|   <  __/ |    |  _ <  __/\__ \ || (_| | |  | |_
|____/ \___/ \___|_|\_\___|_|    |_| \_\___||___/\__\__,_|_|   \__|
=====================================================================
             docker-restarter v1.0 - Julio Caio\033[38;5;15m
"

echo "[+]🐳 Iniciando script de monitoramento de containers"
echo "[+]🐳 Iniciando monitoramento de containers"
echo "[+]🔧 Limitando uso de CPU do servidor"

# variáveis pra cronometrarmos
interval=$((60)) # tempo limite: 1 minuto

start=$(date +%s) #inicio do cronometro de verificação

while true; do
    now=$(date +%s)
    time_wasted=$((now - start))

    if [ $time_wasted -ge $interval ] ; then
        container_max_cpu=$(get_container_max_cpu)
        if [ ${#container_max_cpu} -gt 0 ]; then
            container_name=$(docker ps --format "{{.Names}}" | grep -E "${container_max_cpu[0]}")
            echo -e "\033[38;5;11m[✅] Container com maior uso de CPU: [$container_name] \n\033[38;5;15m"
            echo "[+]🐳 Reiniciando container com maior uso de CPU"
            restart "$container_max_cpu"
        else
            echo "######################################################################"
            echo -e "\033[38;5;10m \nNenhum container com uso de CPU acima de 200%\033[38;5;15m"
        fi
        break
    fi

    containers=$(get_containers)

    echo -e "\033[38;5;10m[+]🐳 Pegando a lista de containers em execução\033[38;5;15m\n"
    echo -e "[✅] Total de containers: $(echo "$containers" | wc -l) \n"

    echo -e "\033[38;5;10m[+]🐳 Listando containers em execução com uso de CPU acima de 200%\033[38;5;15m\n"
    echo "ID                           NOME                         CPU"

    for container in $containers; do
        stats=$(docker stats --no-stream $container --format "{{.ID}} {{.Name}} {{.CPUPerc}}")
        cpu_percent=$(echo $stats | awk '{print int($3)}')
        if [ "$cpu_percent" -gt 200 ]; then
            echo $stats
        fi
    done

    sleep 5
done
