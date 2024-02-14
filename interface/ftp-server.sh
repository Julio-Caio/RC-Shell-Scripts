#!/bin/bash

# Verifica se o usuário é root
areYouRoot() {
    if [ "$EUID" -ne 0 ]; then
        return 1
    else
        return 0
    fi
}

# Verifica se o vsftpd está instalado
isFTPInstalled() {
    if ! dpkg -s "vsftpd" > /dev/null 2>&1; then
        return 1
    else
        return 0
    fi
}

# Verifica se o Zenity está instalado
isZenityInstalled() {
    if ! dpkg -s "zenity" > /dev/null 2>&1; then
        return 1
    else
        return 0
    fi
}

# Cria o servidor FTP
createFTP() {
    forms=$(zenity --forms --title='FTP Server' --text='Digite o diretório que você gostaria de compartilhar' --entry='Diretório' --separator=' ')
    directory=$(echo $forms | awk -F'|' '{print $1}')
    echo "Criando o servidor ftp..."
}

# Reinicia o servidor FTP
restartFTP() {
    systemctl start vsftpd
    systemctl enable vsftpd
}

# Instala o vsftpd se não estiver instalado e inicia o servidor FTP
if areYouRoot && ! isFTPInstalled; then
    echo "O vsftpd não está instalado no sistema."
    echo "Instalando o vsftpd..."
    apt-get install -y vsftpd
    restartFTP
fi

# Cria o servidor FTP
if ! areYouRoot; then
        echo "Por favor, execute o script como root."
        exit 1
else
        if isZenityInstalled; then
            createFTP
            
            echo "Diretório compartilhado: $directory"
            message=$(zenity --info --title='Status' --text='Servidor ftp criado com sucesso!')
            echo $message
        else
            echo "Primeiramente, devemos instalar o pacote Zenity."
            echo "Instalando o Zenity..."
            apt-get install -y zenity
        fi
fi