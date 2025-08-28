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
DEVICE_ID = os.getenv("DEVICE_ID", "cam-p2-01")
MQTT_BROKER_HOST = os.getenv("MQTT_BROKER_HOST", "mosquitto")
MQTT_BROKER_PORT = int(os.getenv("MQTT_BROKER_PORT", 1883))
MQTT_TOPIC = os.getenv("MQTT_TOPIC", f"smartcity/cam/p2/kpi")
PROMETHEUS_PORT = int(os.getenv("PROMETHEUS_PORT", 8000))

USE_FAKE_SOURCE = True  # True = gerar dados sintéticos; False = usar câmera real

# ------------------------------
# Métricas Prometheus
# ------------------------------
gauge_fps = Gauge('edgevision_fps', 'Frames por segundo', ['device_id'])
gauge_motion = Gauge('edgevision_motion_percent', 'Percentual de movimento detectado', ['device_id'])
gauge_brightness = Gauge('edgevision_brightness', 'Nível de brilho', ['device_id'])
gauge_mqtt = Gauge('edgevision_mqtt_publish_ok', 'Publicação MQTT bem-sucedida', ['device_id'])

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
# Função para gerar KPIs
# ------------------------------
def generate_kpis():
    while True:
        if USE_FAKE_SOURCE:
            fps = random.randint(25, 30)
            motion_percent = round(random.uniform(0, 20), 2)
            brightness = random.randint(50, 150)
        else:
            # Aqui entraria código real com OpenCV
            fps = 30
            motion_percent = 0
            brightness = 100

        kpi = {
            "device_id": DEVICE_ID,
            "ts": int(time.time() * 1000),
            "kpis": {
                "fps": fps,
                "motion_percent": motion_percent,
                "brightness": brightness
            }
        }

        # Publicar no MQTT
        try:
            client.publish(MQTT_TOPIC, json.dumps(kpi))
            gauge_mqtt.labels(device_id=DEVICE_ID).set(1)
        except Exception as e:
            print(f"[WARN] Falha ao publicar MQTT: {e}")
            gauge_mqtt.labels(device_id=DEVICE_ID).set(0)

        # Atualizar métricas Prometheus
        gauge_fps.labels(device_id=DEVICE_ID).set(fps)
        gauge_motion.labels(device_id=DEVICE_ID).set(motion_percent)
        gauge_brightness.labels(device_id=DEVICE_ID).set(brightness)

        print(f"[KPI] {json.dumps(kpi)}")
        time.sleep(1)  # 1 Hz de atualização

# ------------------------------
# Início do programa
# ------------------------------
if __name__ == "__main__":
    # Inicializar Prometheus
    start_http_server(PROMETHEUS_PORT)
    print(f"[INFO] Prometheus metrics expostas em http://0.0.0.0:{PROMETHEUS_PORT}/metrics")

    # Conectar ao MQTT
    connect_mqtt()

    # Iniciar thread de geração de KPIs
    kpi_thread = threading.Thread(target=generate_kpis)
    kpi_thread.start()
    kpi_thread.join()

