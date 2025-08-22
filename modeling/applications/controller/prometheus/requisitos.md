## Prometheus

O Prometheus coleta métricas de sistemas alvo e as armazena no formato de séries temporais (time-series). Cada métrica é identificada por um nome e um conjunto de rótulos (labels), que permitem diferenciar dimensões do mesmo dado.

### Armazenamento dos dados:

O Prometheus armazena todos os dados fundamentalmente como séries temporais : fluxos de valores com registro de data e hora pertencentes à mesma métrica e ao mesmo conjunto de dimensões rotuladas. Além das séries temporais armazenadas, o Prometheus pode gerar séries temporais derivadas temporárias como resultado de consultas.

### Função:

- Coleta de métricas de hardware (CPU, RAM, disco).
- Monitoramento de rede (latência, perda de pacotes).
- Tempo de resposta de aplicações.
- Geração de alertas com base em regras.

<hr>

### Requisitos:

- **Rede**: uso de rede, latência, jitter, perda de pacotes, tráfego por aplicação.
- **Sistema**: CPU, memória, disco.
- **Aplicação**: tempo de resposta do controlador, uso de recursos por dispositivo.
- **Alertas**: sobrecarga e falha.

<hr>

### Instalando o Prometheus
1 - Primeiramente, baixe a versão mais recente:

```bash
wget https://github.com/prometheus/prometheus/releases/download/v*/prometheus-*.*-amd64.tar.gz
tar xvf prometheus-*.*-amd64.tar.gz
cd prometheus-*.*
```

2 - Por padrão, a instalação vem com um arquivo básico para configuração **prometheus.yml**:<br>

- **Exemplo**:

```yml
    scrape_configs:
    - job_name: 'node'
        scrape_interval: 5s
        static_configs:
        - targets: ['container_1:8080', 'container_2:8081']
            labels:
            group: 'production'
        - targets: ['localhost:8082']
            labels:
            group: 'canary'

```


3 - Inicie o Prometheus
```bash
    ./prometheus --config.file=prometheus.yml
    curl -vv -I http://localhost:9090
```


### Regras de Configuração

- Agregar dados provenientes de um intervalo de 5 minutos
- targets:
    ['container_1:8081', 'container_1:8082', 'container_1:8083']
- group: 'sensores'

#### Agregando dados

- Ao armazenar inúmeros dados temporais, as consultas que agregam estes podem ficar lentas, ao serem computadas via ad-hoc, podemos habilitar para que o Prometheus possa pré-gravar e nos mostrar uma média do consumo de CPU ao longo de 5 minutos (exemplo):


```yml
### prometheus.rules.yml

groups:
- name: cpu-node
  rules:
  - record: job_instance_mode:node_cpu_seconds:avg_rate5m
    expr: avg by (job, instance, mode) (rate(node_cpu_seconds_total[5m]))
```


- Após isso, precisamos que o Prometheus agregue essa regra ao seu job, então precisamos definir isto no arquivo ***prometheus.yml***.

```yml
    global:
    scrape_interval:     15s # By default, scrape targets every 15 seconds.
    evaluation_interval: 15s # Evaluate rules every 15 seconds.

    # Attach these extra labels to all timeseries collected by this Prometheus instance.
    external_labels:
        monitor: 'codelab-monitor'

    rule_files:
    - 'prometheus.rules.yml'

    scrape_configs:
    - job_name: 'prometheus'

        # Override the global default and scrape targets from this job every 5 seconds.
        scrape_interval: 5s

        static_configs:
        - targets: ['localhost:9090']

    - job_name:       'node'

        # Override the global default and scrape targets from this job every 5 seconds.
        scrape_interval: 5s

        static_configs:
        - targets: ['localhost:8080', 'localhost:8081']
            labels:
            group: 'production'

        - targets: ['localhost:8082']
            labels:
            group: 'canary'
```
<hr>

### Node Exporter
#### Instalação:
```bash
    # NOTE: Replace the URL with one from the above mentioned "downloads" page.
    # <VERSION>, <OS>, and <ARCH> are placeholders.
    wget https://github.com/prometheus/node_exporter/releases/download/v<VERSION>/node_exporter-<VERSION>.<OS>-<ARCH>.tar.gz
    tar xvfz node_exporter-*.*-amd64.tar.gz
    cd node_exporter-*.*-amd64
    ./node_exporter
```

#### Métricas do Nodes Exporter

```bash
    curl http://localhost:9100/metrics | grep "node_"
```
