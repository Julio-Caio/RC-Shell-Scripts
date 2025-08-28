# modeling/devices/p1/Dockerfile
FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive

# Dependências nativas mínimas para health-checks, network tools e certs
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget curl iperf3 procps iproute2 net-tools curl iputils-ping ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Instala Node Exporter
ENV NODE_EXPORTER_VERSION=1.8.2
RUN wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz \
    && tar xvf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz \
    && mv node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter /usr/local/bin/ \
    && rm -rf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64*

# App
WORKDIR /app
COPY requirements/requirements-P1.txt /app/requirements.txt
COPY scripts_sim/sensor_mqtt.py /app/sensor_mqtt.py

RUN pip install --no-cache-dir -r requirements.txt

# Variáveis padrão (podem ser sobrescritas no compose)
ENV BROKER_HOST=mosquitto \
    BROKER_PORT=1883 \
    MQTT_TOPIC=smartcity/esp32/p1/metrics \
    DEVICE_ID=esp32-p1-01 \
    PROM_PORT=8000

# Expor portas: métricas customizadas (8000) e node_exporter (9100)
EXPOSE 8000 9100

# CMD: inicia node_exporter em background e o script Python como processo principal
CMD [ "sh", "-c", "/usr/local/bin/node_exporter --web.listen-address=:9100 & python -u sensor_mqtt.py" ]
