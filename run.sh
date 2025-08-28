#!/bin/bash

# --------------- infra-up  -----------------------
# Version 1.3

# Owner: Júlio Caio
# Date: 24/08/2025
# Last Modified: 27/08/2025
# Name: infra-up
# Location: <REPOSITORY>/run.sh
# -------------------------------------------------

#   Ex.: ./run.sh

################### VARIABLES ################################

BASE=${PWD}
PATH_MONIT_CONTROLLER="${BASE}/stack-infra/monitoramento"
PATH_BROKER_FILES="${BASE}/devices"
PATH_MININET_FILES="${BASE}/stack-infra/mininet"

BRTESTE01_RANGE="172.18.0.0/24"
BRTESTE02_RANGE="172.19.0.0/24"

BRTESTE01_DEVICES=(esp32-p1 edge-vision-p2 ops243-p3 broker_mosquitto)
BRTESTE02_DEVICES=(grafana prometheus)

# Ajuste aqui os gateways reais configurados pelo linuxrouter.py
GW_BRTESTE01="172.18.0.10"
GW_BRTESTE02="172.19.0.10"

#############################################################
                #   Functions
#############################################################

set -e  # parar se algum comando falhar

stop_containers() {
    echo "[INFO] Stopping Prometheus and Grafana containers..."
    docker-compose -f ${PATH_MONIT_CONTROLLER}/docker-compose.yml down

    echo "[INFO] Stopping MQTT broker and IoT devices containers..."
    docker-compose -f ${PATH_BROKER_FILES}/docker-compose.yml down
}

prepare_observability() {
    echo "[INFO] Starting Prometheus and Grafana..."
    docker-compose -f ${PATH_MONIT_CONTROLLER}/docker-compose.yml up -d

    echo "[INFO] Starting MQTT broker and IoT devices..."
    docker-compose -f ${PATH_BROKER_FILES}/docker-compose.yml up -d
}

start_mininet() {
    echo "[INFO] Starting Mininet router..."
    cd ${PATH_MININET_FILES}
    if ! sudo python3 ./linuxrouter.py; then
        echo "[WARN] Mininet failed. Checking for process using port 6653..."

        PID=$(sudo lsof -t -i:6653)
        if [ -n "$PID" ]; then
            echo "[INFO] Killing process $PID on port 6653..."
            sudo kill -9 $PID
            sleep 2
            echo "[INFO] Retrying Mininet..."
            sudo python3 ${PATH_MININET_FILES}/linuxrouter.py
        else
            echo "[ERROR] No process found on port 6653, but Mininet still failed."
            exit 1
        fi
    fi
}

create_routes() {
    local container=$1
    local gw=$2
    local dest=$3

    echo "[INFO] Adding route in $container: $dest via $gw"
    docker exec "$container" ip route add "$dest" via "$gw" || \
        echo "[WARN] Failed to add route in $container"
}

implement_routes() {
    # Containers em brteste01 -> rota para brteste02
    for c in "${BRTESTE01_DEVICES[@]}"; do
        create_routes "$c" "$GW_BRTESTE01" "$BRTESTE02_RANGE"
    done

    # Containers em brteste02 -> rota para brteste01
    for c in "${BRTESTE02_DEVICES[@]}"; do
        create_routes "$c" "$GW_BRTESTE02" "$BRTESTE01_RANGE"
    done
}

main() {
    echo -e "[INFO] Starting to create scenario...\n"
    sleep 1
    stop_containers
    sleep 1
    prepare_observability
    sleep 2
    implement_routes
    start_mininet &
    echo -e "[SUCCESS] Scenario initialized!\n"
}

main