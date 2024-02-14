#!/bin/bash

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
read opcao;

if [ "$opcao" == 1 ]; then
    echo "Limpando o histórico..."
    history -c
    history -w
    history
    
elif [ "$opcao" == 2 ]; then
    echo "Informe abaixo o diretório (caminho absoluto) que você gostaria de realizar uma cópia:"
    read diretorio_origem;
    diretorio_destino="/home/$USER/backups"
    mkdir -p "$diretorio_destino"
    chmod 740 "$diretorio_destino"
    echo "Executando backup...\n"
    file_name_backup="backup_$(date +%Y-%m-%d_%H-%M-%S).tar.gz"
    tar -czvf "$diretorio_destino/$file_name_backup" "$diretorio_origem"
    ls -l "$diretorio_destino"

elif [ "$opcao" == 3 ]; then
    echo "Atualizando o sistema..."
    sudo apt update && sudo apt upgrade -y

elif [ "$opcao" == 4 ]; then
    echo "Qual o IP de destino?"
    read target_ip;
    echo "Nome do arquivo para importar/exportar:"
    read files;
    echo "Diretorio de destino:"
    read diretorio_destino;
    scp "$target_ip":"$files" "$diretorio_destino"
   		
elif [ "$opcao" == 5 ]; then
    myIP="$(hostname -I)"
    echo "Seu IP é: $myIP"

elif [ "$opcao" == 6 ]; then
    echo "Espaço em Disco:"
    echo "====================="
    df -h
    
elif [ "$opcao" == 7 ]; then
    echo "Desligando..."
    sleep 3
    sudo systemctl poweroff

else
    echo "Opção inválida!"
fi