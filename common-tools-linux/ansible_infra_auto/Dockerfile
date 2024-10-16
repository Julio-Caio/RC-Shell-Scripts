FROM debian:latest

RUN apt-get update && \
    apt-get install -y openssh-server sudo python3 && \
    mkdir /var/run/sshd

# Adicionar usuário sudo
RUN useradd -m -s /bin/bash user.adm && \
    echo "user.adm:password" | chpasswd && \
    usermod -aG sudo user.adm

# Criar usuários fictícios
RUN useradd -m -s /bin/bash user1 && \
    useradd -m -s /bin/bash user2 && \
    useradd -m -s /bin/bash user3 && \
    useradd -m -s /bin/bash user4 && \
    useradd -m -s /bin/bash user5 && \
    useradd -m -s /bin/bash user6

RUN mkdir -p /home/user.adm/.ssh && \
    chmod 700 /home/user.adm/.ssh && \
    touch /home/user.adm/.ssh/authorized_keys && \
    chmod 600 /home/user.adm/.ssh/authorized_keys

# Copiar a chave pública SSH para o container
COPY setup/id_rsa.pub /home/user.adm/.ssh/authorized_keys

RUN chown -R user.adm: /home/user.adm/.ssh

RUN echo 'PermitRootLogin no' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config

RUN echo 'user.adm ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

EXPOSE 22

# Iniciar o serviço SSH e deixar o container em execução
CMD ["/usr/sbin/sshd", "-D"]
