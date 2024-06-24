#!/bin/bash

while true; do
    echo "Olá, caro administrador $USER"
    echo "Veja a melhor opção no seu contexto atual:
    _____________________________________________________________   
        (1) Limpar histórico
        (2) Realizar Backup de arquivos
        (3) Realizar update do Sistema
        (4) Fazer transferência de arquivos
        (5) Verificar meu IP
        (6) Verificar armazenamento
        (7) Shutdown
    "
    echo "Digite sua opção abaixo:"
    read -r opcao

    if [ "$opcao" == "1" ]; then
        echo "Limpando o histórico..."
        echo "" > ~/.bash_history
        history -c
        exec bash

    elif [ "$opcao" == "2" ]; then
        echo "Informe abaixo o diretório (caminho absoluto) que você gostaria de realizar uma cópia:"
        read -r diretorio_origem
        diretorio_destino="/home/$USER/backups"
        mkdir -p "$diretorio_destino"
        chmod 740 "$diretorio_destino"
        echo "Executando backup..."
        file_name_backup="backup_$(date +%Y-%m-%d_%H-%M-%S).tar.gz"
        tar -czvf "$diretorio_destino/$file_name_backup" "$diretorio_origem"
        ls -l "$diretorio_destino"

    elif [ "$opcao" == "3" ]; then
        echo "Atualizando o sistema..."
        sudo apt update && sudo apt upgrade -y

    elif [ "$opcao" == "4" ]; then
        echo "Informe o arquivo ou diretório (caminho absoluto) que você gostaria de transferir:"
        read -r arquivo_origem
        echo "Informe o destino (usuário@host:caminho):"
        read -r destino
        scp "$arquivo_origem" "$destino"

    elif [ "$opcao" == "5" ]; then
        echo "Seu IP atual é:"
        hostname -I | awk '{print $1}'

    elif [ "$opcao" == "6" ]; then
        echo "Verificando armazenamento..."
        df -h

    elif [ "$opcao" == "7" ]; then
        echo "Desligando o sistema..."
        sudo shutdown now

    else
        echo "Opção inválida. Por favor, tente novamente."
    fi

    echo "Pressione Enter para continuar..."
    read -r
done

