# Arquitetura MQTT

**Objetivos**:
    - Escutar as mensagens PUBLISHER dos sensores (MQTT)
    - Escutar mensagens HTTP
    - Escutar mensagens CoAP
    - Rotear mensagens para à Rede MiniNet

## 1. Estrutura:

- **Broker** (Mosquitto + Node.js Express + CoAP listener)

- **Sensores** (simulação de dispositivos IoT → publicam em MQTT, HTTP ou CoAP)

- **Controller** (coleta dados do broker e armazena métricas, pode ser um banco de dados + dashboard)

- **MiniNet** (simulação da rede e métricas de tráfego)

## 2. Configuração do Broker:

- Usar Eclipse Mosquitto rodando no container do Broker.

- Configurar portas: 1883 (MQTT), 9001 (WebSocket opcional).

- O Broker vai receber os publish dos sensores.

## 3. HTTP Listener

- No mesmo container, rodar um servidor Node.js (Express) que escute requisições POST /topic/:name.

- Quando um sensor enviar via HTTP, o servidor Express pode repassar para o Mosquitto Broker internamente (publicar no tópico MQTT correspondente).

- Exemplo: **POST /topic/lab04/temperatura** → publica no tópico **/lab04/temperatura**.

## 4. Containers Docker

- Criar imagens Docker leves (pode ser Alpine + Node.js).
- Configurar os enlaces nos dispositivos IoT com NetEm com parâmetros de falha, perda de pacotes, etc.

Exemplo:

- Um container que a cada 5 segundos publica no tópico /lab04/temperatura um JSON com a temperatura.
- Pode variar valores randomizados simulando leituras reais.

## 5. Integração com MiniNet

- No MiniNet, você vai simular a rede e métricas (RTT, jitter, perda de pacotes etc).

- A ideia é conectar os containers Docker ao MiniNet (bridge network) para que o tráfego MQTT/HTTP/CoAP passe dentro da rede simulada.

## 6. Ferramentas dentro do MiniNet:

- iperf, ping → métricas de RTT, jitter.

## 7. Mensagens PUBLISHER endereçadas ao Broker:

#### Exemplo 1.1:

Tópico: **/lab04/temperatura**

    ```json
    {
        "sensor_id": "temp_sensor_01",
        "timestamp": "2025-08-20T20:45:00Z",
        "temperature": 24.7,
        "unit": "C"
    }
    ```

- Após o container do sensor enviar tal mensagem e o BROKER escutar, ele irá enviar tal mensagem ao controlador em nuvem, passando pela rede Mininet, que ficará responsável por fazer a coleta das métricas e armazenar informações do dispositivo (container), como memória, CPU e métricas de Rede: jitter, taxa de transferência, RTT, perda de pacotes

## 8. Controlador em Nuvem:
    - Servidor Debian 12 para coleta de métricas.

### 8.1 Serviços:
    - Prometheus para monitoramento e coleta das métricas originadas pelos sensores
    - Grafana para geração de Dashboards