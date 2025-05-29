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

### O que será medido?
    - Uso de CPU e Memória para cada aplicação
    - Tempo de resposta entre o dispositivo e controlador em nuvem
    - Latência
    - Jitter
    - Perda de pacotes