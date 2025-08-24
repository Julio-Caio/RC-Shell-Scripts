#!/bin/bash
set -e  # parar se algum comando falhar

#### VARIABLES #####
PATH_MONIT_CONTROLLER="./modeling/applications/controller/prometheus"
PATH_BROKER_FILES="./modeling/applications/broker/mqtt"
PATH_MININET_FILES="./modeling/applications/mininet"

stop_containers()
{
    echo "[INFO] Stoping Prometheus and Grafana container..."
    docker-compose -f ${PATH_MONIT_CONTROLLER}/monit.yml down

    echo "[INFO] Stoping MQTT broker container..."
    docker-compose -f ${PATH_BROKER_FILES}/docker-compose.yml down

}

prepare_observability() {
    echo "[INFO] Starting Prometheus and Grafana..."
    docker-compose -f ${PATH_MONIT_CONTROLLER}/monit.yml up -d

    echo "[INFO] Starting MQTT broker..."
    docker-compose -f ${PATH_BROKER_FILES}/docker-compose.yml up -d
}

start_mininet() {
    echo "[INFO] Starting Mininet router..."
    cd ${PATH_MININET_FILES}
    # tenta iniciar
    if ! sudo python3 ./linuxrouter.py; then
        echo "[WARN] Mininet failed. Checking for process using port 6653..."

        # identifica o processo ocupando a porta 6653
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

criar_rotas() {
    echo "[INFO] Creating routes in Mosquitto..."
    if ! docker exec broker_mosquitto ip route show | grep -q "172.19.0.0/24"; then
        docker exec broker_mosquitto ip route add 172.19.0.0/24 via 172.18.0.10
    else
        echo "[INFO] Route 172.19.0.0/24 already exists in Mosquitto"
    fi

    echo "[INFO] Creating routes in Prometheus..."
    if ! docker exec prometheus_controller ip route show | grep -q "172.18.0.0/24"; then
        docker exec prometheus_controller ip route add 172.18.0.0/24 via 172.19.0.10
    else
        echo "[INFO] Route 172.18.0.0/24 already exists in Prometheus"
    fi
}



main() {
    echo "[INFO] Downloading dependencies...\n"
    ./install_dependencies
    echo "[INFO] Starting to creating scenario...\n"
    stop_containers
    prepare_observability
    criar_rotas
    start_mininet
}

main