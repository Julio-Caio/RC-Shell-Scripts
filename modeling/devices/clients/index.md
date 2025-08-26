## Sensores

### Perguntas a serem esclarecidas para guiar o projeto:

    - Quais os tipos de aplicações e sensores escolhidos?
    - Qual a frequência de publicação de eventos?
    - Os eventos serão enviados com base em valores aleatórios ou datasets baixado?
    - Se for baseado em um dataset, como irá ser preparado este e utilizado pelo container IoT?

### Tipos de Aplicações

- Sensores para detectação de congestionamentos
- Sensores industriais de energia
- Sensores de temperatura

### Integração com o Mininet:
    
    Parâmetros de redes que serão variados com tc netem:

    - Uso de rede (tx/rx)
    - delay 50ms
    - loss 5%
    - rate 1mbit

### O que será medido no dispositivo?
    - CPU, memória RAM, armazenamento
    - Tempo de resposta entre o dispositivo e controlador em nuvem
    - Latência
    - Jitter
    - Perda de pacotes

### Dispositivos escolhidos

**P1. Nó sensor MCU Wi‑Fi (perfil "Low‑Power")**
    Exemplo: ESP32‑WROOM‑32.
    
    CPU: dual‑core LX6 até 240 MHz.
    
    RAM: ~520 KB SRAM on‑chip.
    
    Armazenamento: 4–16 MB flash (módulo), microSD opcional.
    
    Rede: Wi‑Fi 802.11 b/g/n (150 Mbps PHY), BLE para comissionamento.
    
    Uso típico: A1 (temperatura) e A3 (PIR) com MQTT, Deep Sleep entre amostras.
    Observações de desempenho: firmware enxuto; filas MQTT com QoS 0/1; compressão opcional (CBOR).

**P2. SBC com câmera (perfil "Edge Vision")**
    Exemplo: *Raspberry Pi Zero 2 W (ou Pi 4 conforme disponibilidade).*
    CPU: *quad‑core ARM Cortex‑A53 1.0 GHz*
    RAM: *512 MB* LPDDR2 (Zero 2 W).
    Armazenamento: microSD ≥ *16 GB.*
    Rede: *Wi‑Fi 802.11 b/g/n*; CSI para câmera; USB 2.0 OTG.

    Uso típico: A2 (congestionamento) executando contagem/detecção local; publica apenas KPIs.
    Observações de desempenho: manter pipeline leve (ex.: GStreamer + detecção clássica/RT-lite), taxa 1 Hz de KPIs.

**P3. Gateway/Edge AI (perfil "Industrial/Agregado")**
    Exemplo: NVIDIA Jetson Nano (ou Orin Nano, conforme orçamento/complexidade).

    CPU/GPU: quad‑core ARM Cortex‑A57 + GPU Maxwell 128 CUDA (Nano) / Orin Nano com TOPS mais altos.

    RAM: 4 GB LPDDR4 (Nano) / 4–8 GB (Orin Nano).

    Armazenamento: eMMC 16 GB + SSD opcional.

    Rede: Ethernet GbE; múltiplas interfaces para backhaul.
    Uso típico: agregação multi‑câmera, correlação de eventos, buffer de picos, gateway MQTT/HTTP/CoAP para a nuvem.
