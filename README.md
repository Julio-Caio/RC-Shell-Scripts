<h1 align="center"> IoT-DockerCity Project</h1>

<p align="center">
Simulação e monitoramento de redes IoT heterogêneas em um ambiente de Smart City usando Mininet, Docker, Prometheus e Grafana.
</p>

---

<p align="center">
<a href="#"><img src="https://img.shields.io/badge/Status-Em%20Desenvolvimento-yellow" /></a>
<a href="#"><img src="https://img.shields.io/badge/Mininet-v2.3.0-blue" /></a>
<a href="#"><img src="https://img.shields.io/badge/Docker-v24.0.6-blue" /></a>
<a href="#"><img src="https://img.shields.io/badge/Grafana-v10.0-orange" /></a>
<a href="#"><img src="https://img.shields.io/badge/Prometheus-v2.46.0-green" /></a>
</p>

---

## 📖 Overview

**IoT-DockerCity** permite modelar, emular e monitorar redes IoT heterogêneas em uma Smart City.

* Coleta de métricas de dispositivos IoT em tempo real.
* Visualização em dashboards interativos via Grafana.
* Emulação de condições de rede realistas usando Mininet + NetEm.

---

## 🏗️ Arquitetura

![Arquitetura Geral](preview/topology.png)

* **Dispositivos IoT:** modelados como contêineres Docker com capacidades variadas.
* **Controlador Central:** coleta métricas e dados dos dispositivos.
* **Monitoramento:** Prometheus coleta métricas; Grafana exibe dashboards.

---

## 🛠️ Technologies Used

<div style="display: inline-block">
    <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/python/python-original.svg" width="38" height="38" />
    <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/docker/docker-original.svg" width="38" height="38" />
    <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/linux/linux-original.svg" width="38" height="38" />
    <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/prometheus/prometheus-original.svg" width="38" height="38" />
    <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/grafana/grafana-original.svg" width="38" height="38" />
</div>

## ⚡ Features

1. **IoT Device Modeling**

   * Configuração de CPU, RAM, armazenamento e interfaces de rede.
   * Aplicações com frequência de coleta, volume de dados e requisitos de latência.

2. **Network Emulation**

   * Topologias Mininet simulando latência, jitter e perda de pacotes.
   * Protocolo MQTT

3. **Centralized Monitoring**

   * Prometheus para coleta de métricas detalhadas.
   * Dashboards Grafana com alertas de sobrecarga ou falha.

4. **Containerized Environment**

   * Dispositivos e serviços isolados para escalabilidade e replicação.

---

## 📊 Datasets Recomendados

* [SmartSantander](https://smartsantander.eu/)
* [CityPulse](https://www.citypulse.eu/)
* [OpensenseMap](https://opensensemap.org)
* [NYC Open Data](https://opendata.cityofnewyork.us)

---

### 4. Acessar dashboards

* Prometheus: [http://localhost:9090](http://localhost:9090)
* Grafana: [http://localhost:3000](http://localhost:3000)


---

## 🧑‍💻 Authors

<a href="https://github.com/Julio-Caio"><b>Júlio Caio</b></a><br>
<a href="https://github.com/JuliaSantss"><b>Júlia Beatriz</b></a>