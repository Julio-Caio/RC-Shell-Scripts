#!/bin/bash

# Copyright (C) 2025 Julio Caio

# File:            enum-domain

# Author: Julio Caio

# Description: Check which domains are receiving requests or still need to be migrated on the Web server (${TYPE_WEBSERVER})

# -----------------------------------------------------------------------------
#                                 MAIN VARIABLES
# -----------------------------------------------------------------------------

DATE_EXEC=$(date "+%d/%m/%Y")
LAST_MODIFICATION_DATE="01/01/2025"
TYPE_WEBSERVER="nginx"  # define your web server (nginx || apache2)
SCRIPT_VERSION="1.0"    # Version of this script
DOMAINS_FILE=""         # list containing all domains in /etc/<webserver>/sites-enabled
LOGS_LIST=""            # path to the logs of each domain configured in /etc/<webserver>/sites-enabled
PENDING_DOMAINS_FILE="" # output.txt

# -----------------------------------------------------------------------------
#                                 FUNCTIONS
# -----------------------------------------------------------------------------

# Function: Check if the user is root
isRoot() {
        if [ "$(id -u)" -ne 0 ]; then
            echo "This script requires privileges!"
            exit 1
        fi
}

# Function: List domains
listar_dominios() {
            echo "=== Domains in /etc/${TYPE_WEBSERVER}/sites-enabled ==="
            ls /etc/${TYPE_WEBSERVER}/sites-enabled > "$DOMAINS_FILE"
            cat "$DOMAINS_FILE"
}

# Function: List log files
listar_arquivos_log() {
            echo "=== Log Directories ==="
            while IFS= read -r domain; do
                if [[ -f "/etc/${TYPE_WEBSERVER}/sites-enabled/$domain" ]]; then
                    access_log=$(grep -oP 'access_log \K\S+' "/etc/${TYPE_WEBSERVER}/sites-enabled/$domain" | sed 's/;$//')
                    echo "$access_log" >> "$LOGS_LIST"
                fi
            done < "$DOMAINS_FILE"
            sed -i 's/;$//' "$LOGS_LIST"
            cat "$LOGS_LIST" | sort -u
}

## Function to correctly format the domains found in the log files
formatDomain() {
    local notFormatted=("") # Here you can define possible log files that don't follow the patterns of other domains
    local suffixDefault=".company.com"
    for domain in "${notFormatted[@]}"; do
        sed -i "s/\b${domain}\b/${domain}.${suffixDefault}/g" "$PENDING_DOMAINS_FILE"
    done
}

## Function to animate dots
animate_dots() {
    local message="$1"
    local count=0
    while [ $count -lt 3 ]; do
        echo -ne "\r$message."
        sleep 0.3
        echo -ne "\r$message.."
        sleep 0.3
        echo -ne "\r$message..."
        sleep 0.3
        count=$((count + 1))
    done
    echo -ne "\r$message... \e[1;32mcompleted!\e[0m \n"
}

# Function: Check active domains
verificar_dominios_ativos() {
        echo -e "\e[33m[ + ] Searching for domains...\e[0m"
        animate_dots "Searching for domains"
        find /var/log/${TYPE_WEBSERVER} -maxdepth 1 -type f \( -name "*_access.log" \) -newermt "10 days ago" -exec basename {} \; | sed -r 's/_access\.log$//' | sort -u > $PENDING_DOMAINS_FILE
        formatDomain
        # Replace underline with dot for specific domains only
        sed -i 's/_/./g' $PENDING_DOMAINS_FILE

        # Display the sorted list with numbering
        cat $PENDING_DOMAINS_FILE | nl -w 2 -s '. ' | while read -r num domain; do
        echo -e "$num\e[32m$domain\e[0m"
    done
}

### Main menu ###
main() {
    while true; do
        echo -e "\n==== Main Menu ===="
        echo "1) List domains"
        echo "2) List log files"
        echo "3) Check active domains"
        echo "4) Exit"
        read -rp "Choose an option: " option
        echo -e "==============================\n"
        case $option in
            1) listar_dominios ;;
            2) listar_arquivos_log ;;
            3) verificar_dominios_ativos ;;
            4) exit 0 ;;
            *) echo "Invalid option! Try again." ;;
        esac
    done
}


# -----------------------------------------------------------------------------
#                                    MAIN
# -----------------------------------------------------------------------------
isRoot

echo -e "\n\e[33m
 _____ _   _ _   _ __  __       ____   ___  __  __    _    ___ _   _ 
| ____| \ | | | | |  \/  |     |  _ \ / _ \|  \/  |  / \  |_ _| \ | |
|  _| |  \| | | | | |\/| |_____| | | | | | | |\/| | / _ \  | ||  \| |
| |___| |\  | |_| | |  | |_____| |_| | |_| | |  | |/ ___ \ | || |\  |
|_____|_| \_|\___/|_|  |_|     |____/ \___/|_|  |_/_/   \_\___|_| \_|
                           \e[0m  
_________________________ v$SCRIPT_VERSION ____________________________
Last modification on $LAST_MODIFICATION_DATE\n"

echo "Script executed on: $DATE_EXEC"

main