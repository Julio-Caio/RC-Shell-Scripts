#!/bin/bash

# Função para gerar um endereço MAC aleatório
random_mac() {
    local mac=""
    local hex_chars="0123456789ABCDEF"

    for i in {1..6}; do
        rand1=$(($RANDOM % 16))
        rand2=$(($RANDOM % 16))
        mac="$mac${hex_chars:$rand1:1}${hex_chars:$rand2:1}"

        if [ $i -lt 6 ]; then
            mac="$mac:"
        fi
    done

    echo $mac
}

#------------------------------------------------------

echo "Olá, caro administrador $USER"
echo "Veja a melhor opção no seu contexto atual:
_____________________________________________________________   
    (1) Limpar histórico
    (2) Realizar Backup de arquivos
    (3) Realizar update do Sistema
    (4) Fazer transferência de arquivos
    (5) Verificar meu IP
    (6) Mudar o Endereço MAC da minha placa de rede
    (7) Shutdown
"
echo "Digite sua opção abaixo:"
read opcao;

if [ "$opcao" == 1 ]; then
    echo "Limpando o histórico..."
    history -c
    history -w
    history
    
elif [ "$opcao" == 2 ]; then
    echo "\nInforme abaixo o diretório (caminho absoluto) que você gostaria de realizar uma cópia:"
    read diretorio_origem;
    diretorio_destino="/home/$USER/backups"
    mkdir "$diretorio_destino"
    chmod 740 "$diretorio_destino"
    echo "Executando backup...\n"
    file_name_backup="backup_$(date +%Y-%m-%d_%H-%M-%S).tar.gz"
    tar -czvf "$diretorio_destino/$file_name_backup" "$diretorio_origem"
    ls -l "$diretorio_destino"

elif [ "$opcao" == 3 ]; then
    sudo apt update
    sudo apt upgrade -y
    sudo apt autoremove -y

elif [ "$opcao" == 4 ]; then
    echo "Qual o IP de destino?"
    read target_ip;
    echo "Nome do arquivo para importar/exportar:"
    read files;
    echo "Diretorio de destino:"
    read diretorio_destino;
    scp $target_ip:$files $diretorio_destino
   		
elif [ "$opcao" == 5 ]; then
    myIP="$(hostname -I)"
    echo "Seu IP é: $myIP"

elif [ "$opcao" == 6 ]; then
    echo "Escolha a interface de rede para alteração:"
    read interface
    echo "Atualmente seu endereço MAC é:"
    ip addr show $interface
    echo " "
    echo "Você deseja mesmo realizar essa mudança?"
    read answer
    if [ "$answer" == "sim" ] || [ "$answer" == "Y" ] || [ "$answer" == "S" ]; then
        new_mac=$(random_mac)
        echo "Seu novo endereço MAC é: $new_mac"
    fi

elif [ "$opcao" == 7 ]; then
    echo "Desligando..."
    sleep 3
    sudo systemctl shutdown

else
    echo "Esta opção não existe!"
fi
