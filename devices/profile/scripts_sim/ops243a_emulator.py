#!/usr/bin/env python3
import os
import time
import json
import random
import threading
import paho.mqtt.client as mqtt
from prometheus_client import start_http_server, Gauge
from datetime import datetime

# ------------------------------
# Configurações do dispositivo
# ------------------------------
DEVICE_ID = os.getenv("DEVICE_ID", "ops243a_01")
MQTT_BROKER_HOST = os.getenv("MQTT_BROKER_HOST", "mosquitto")
MQTT_BROKER_PORT = int(os.getenv("MQTT_BROKER_PORT", 1883))
MQTT_TOPIC = os.getenv("MQTT_TOPIC", f"iot/traffic/ops243a")
PROMETHEUS_PORT = int(os.getenv("PROMETHEUS_PORT", 8000))

# ------------------------------
# Métricas Prometheus
# ------------------------------
gauge_speed = Gauge('ops243_speed_mps', 'Velocidade do veículo em m/s', ['device_id'])
gauge_signal = Gauge('ops243_signal_strength_dbm', 'Força do sinal do sensor em dBm', ['device_id'])
gauge_mqtt = Gauge('ops243_mqtt_publish_ok', 'Publicação MQTT bem-sucedida', ['device_id'])

# ------------------------------
# Cliente MQTT
# ------------------------------
client = mqtt.Client(client_id=f"{DEVICE_ID}")

def connect_mqtt():
    try:
        client.connect(MQTT_BROKER_HOST, MQTT_BROKER_PORT)
        client.loop_start()
        print(f"[INFO] Conectado ao broker MQTT em {MQTT_BROKER_HOST}:{MQTT_BROKER_PORT}")
    except Exception as e:
        print(f"[ERROR] Não foi possível conectar ao broker MQTT: {e}")
        exit(1)

# ------------------------------
# Função para gerar métricas simuladas
# ------------------------------
def generate_metrics():
    while True:
        speed = round(random.uniform(0, 30), 2)
        direction = random.choice(["approaching", "departing"])
        signal_strength = random.randint(-80, -40)

        payload = {
            "device_id": DEVICE_ID,
            "timestamp": datetime.utcnow().isoformat(),
            "metrics": {
                "speed_mps": speed,
                "direction": direction,
                "signal_strength_dbm": signal_strength
            }
        }

        # Publicar no MQTT
        try:
            client.publish(MQTT_TOPIC, json.dumps(payload))
            gauge_mqtt.labels(device_id=DEVICE_ID).set(1)
        except Exception as e:
            print(f"[WARN] Falha ao publicar MQTT: {e}")
            gauge_mqtt.labels(device_id=DEVICE_ID).set(0)

        # Atualizar métricas Prometheus
        gauge_speed.labels(device_id=DEVICE_ID).set(speed)
        gauge_signal.labels(device_id=DEVICE_ID).set(signal_strength)

        print(f"[OPS243] {json.dumps(payload)}")
        time.sleep(1)  # envia a cada 1s

# ------------------------------
# Início do programa
# ------------------------------
if __name__ == "__main__":
    # Inicializar Prometheus
    start_http_server(PROMETHEUS_PORT)
    print(f"[INFO] Prometheus metrics expostas em http://0.0.0.0:{PROMETHEUS_PORT}/metrics")

    # Conectar ao MQTT
    connect_mqtt()

    # Iniciar thread de geração de métricas
    t = threading.Thread(target=generate_metrics)
    t.start()
    t.join()
