## Objetivo Geral

- Modelar, simular/emular e avaliar o desempenho de uma rede IoT heterogênea em um ambiente de Smart City. 

### Requisitos

- Os dispositivos IoT devem possuir diferentes capacidades e
executar aplicações diversas.

- Todos os dados coletados devem ser enviados a um controlador centralizado na nuvem, que disponibilizará um dashboard de
monitoramento via Grafana.


### Arquitetura

![Arquitetura Geral](../topology    .png)

<hr>

### Primeira Etapa: Coleta e Análise de Dados Reais

#### Artigos de referência



#### Datasets Recomendado

**[Smartsantander](https://smartsantander.eu/)**<br>
**[CityPulse](https://www.citypulse.eu/)**<br>
**[OpensenseMap](https://opensensemap.org)**<br>
**[NYC Open Data](https://opendata.cityofnewyork.us)**<br>

#### Tarefa 1: Extração de Parâmetros e Identificação de Devices

    - Extrair parâmetros de uso de CPU, memória, armazenamento e rede das aplicações escolhidas.

    - Identificar dispositivos IoT comuns nesses cenários com suas especificações técnicas.

#### Tarefa 2: Modelagem das Aplicações e Dispositivos

    Cada aplicação deve conter:

        - Frequência de coleta/envio de dados.
        - Volume médio de dados.
        - Requisitos de latência e armazenamento.

    - Cada dispositivo deve conter:
        - CPU (frequência ou tipo).
        - RAM.
        - Armazenamento.
        - Interface de rede



### Segunda Etapa: Emulação de Rede

Ferramentas Sugeridas:

● Mininet + NetEm
● Docker para contêinerização dos dispositivos
● MQTT / HTTP / CoAP como protocolos de comunicação
● Prometheus + Grafana para monitoramento