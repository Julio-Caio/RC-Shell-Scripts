#!/usr/bin/env python3
import os
import time
import json
import random
import threading
import paho.mqtt.client as mqtt
from prometheus_client import start_http_server, Gauge

# ------------------------------
# Configurações do dispositivo
# ------------------------------
DEVICE_ID = os.getenv("DEVICE_ID", "esp32-p1-01")
MQTT_BROKER_HOST = os.getenv("MQTT_BROKER_HOST", "mosquitto")
MQTT_BROKER_PORT = int(os.getenv("MQTT_BROKER_PORT", 1883))
MQTT_TOPIC = os.getenv("MQTT_TOPIC", f"smartcity/esp32/p1/metrics")
PROMETHEUS_PORT = int(os.getenv("PROMETHEUS_PORT", 8000))

# ------------------------------
# Métricas Prometheus
# ------------------------------
gauge_temp = Gauge('esp32_temperature_celsius', 'Temperatura em Celsius', ['device_id'])
gauge_hum = Gauge('esp32_humidity_percent', 'Umidade relativa do ar (%)', ['device_id'])
gauge_batt = Gauge('esp32_battery_percent', 'Nível da bateria (%)', ['device_id'])
gauge_mqtt = Gauge('esp32_mqtt_publish_ok', 'Publicação MQTT bem-sucedida', ['device_id'])

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
        # Dados simulados
        temp = round(random.uniform(20.0, 35.0), 2)
        hum = round(random.uniform(30.0, 90.0), 2)
        batt = round(random.uniform(40.0, 100.0), 2)

        payload = {
            "device_id": DEVICE_ID,
            "ts": int(time.time() * 1000),
            "metrics": {
                "temperature": temp,
                "humidity": hum,
                "battery": batt
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
        gauge_temp.labels(device_id=DEVICE_ID).set(temp)
        gauge_hum.labels(device_id=DEVICE_ID).set(hum)
        gauge_batt.labels(device_id=DEVICE_ID).set(batt)

        print(f"[ESP32] {json.dumps(payload)}")
        time.sleep(2)  # envia a cada 2s

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
