## Mosquitto

### Introdução: O que é MQTT

O **MQTT (Message Queuing Telemetry Transport)** é um protocolo de mensageria leve, padrão em aplicações de **IoT** e **IIoT (Industrial IoT)**.

Ele segue o modelo **publish/subscribe**, no qual três elementos principais interagem:

* **Publisher**: dispositivo ou aplicação que publica mensagens em um tópico.
* **Broker**: servidor responsável por receber as mensagens e repassá-las.
* **Subscriber**: cliente que se inscreve em um tópico para receber as mensagens correspondentes.

Um ponto importante é que os **subscribers não se conectam diretamente aos publishers**. O **broker atua como intermediário** entre os dois, garantindo o repasse das informações.

Esse mecanismo é chamado de **decoupling**, pois separa os papéis de quem envia e de quem recebe.

**Exemplo 1**

* `sensor_temperatura` (**publisher**) publica mensagens no tópico `/escritorio/1`.
* `controlador` (**subscriber**) se inscreve no tópico `/escritorio/1`.
* O **broker MQTT** recebe as mensagens do sensor e as entrega ao controlador.

> Obs.: Um cliente pode ser publisher e subscriber ao mesmo tempo, dependendo do tópico.

---

### Requisitos e cenários para implementação

No cenário deste projeto será utilizado o tópico **`/ifpb/analise_rede`**.

* Um **cliente publisher** (por exemplo, sensor de temperatura) enviará mensagens ao **broker MQTT**.
* O **broker** ficará responsável por repassar essas mensagens ao **controlador**, que possui o Prometheus instalado para monitoramento.