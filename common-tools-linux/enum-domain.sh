#!/bin/bash

# Copyright (C) 2025 Julio Caio

# File:   enum-domain

# Author: Julio Caio            <https://github.com/Julio-Caio>

# Description: Check which domains are receiving requests or still need to be migrated on the Web server (${TYPE_WEBSERVER})

# -----------------------------------------------------------------------------
#                                  MAIN VARIABLES
# -----------------------------------------------------------------------------

DATE_EXEC=$(date "+%d/%m/%Y")
LAST_MODIFICATION_DATE="01/01/2025"
SCRIPT_VERSION="1.2"

DOMAINS_FILE="/tmp/lista_dominios.txt"              # List of domains
LOG_PATHS_FILE="/tmp/lista_dir_logs_dominios.txt"   # Paths of logs associated with domains
ACTIVE_DOMAINS_FILE="/tmp/dominios_nao_migrados_ativos.txt" # Active domains not yet migrated

# -----------------------------------------------------------------------------
#                                  FUNCTIONS
# -----------------------------------------------------------------------------

# Function: Check if the user is root
isRoot() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "This script requires root privileges!"
        exit 1
    fi
}

# Function: List configured domains and logs
listDomainsAndLogs() {
    echo "=== Generating list of domains and logs ==="
    : > "$DOMAINS_FILE"
    : > "$LOG_PATHS_FILE"

    for config_file in /etc/nginx/sites-enabled/*; do
        domain_name=$(basename "$config_file")
        echo "$domain_name" >> "$DOMAINS_FILE"

        # Search for the associated access.log path
        access_log_path=$(grep -oP 'access_log \K\S+' "$config_file" | sed 's/;$//')
        if [[ -n "$access_log_path" ]]; then
            echo "$domain_name|$access_log_path" >> "$LOG_PATHS_FILE"
        fi
    done

    echo "Listed domains:"
    cat "$DOMAINS_FILE"
    echo -e "\nAssociated log paths:"
    cat "$LOG_PATHS_FILE"
}

# Function: Identify active domains
identifyActiveDomains() {
    echo -e "=== Identifying active domains ==="
    : > "$ACTIVE_DOMAINS_FILE"

    find /var/log/nginx -maxdepth 1 -type f \( -name "*_access.log" -o -name "*_error.log" \) -newermt "10 days ago" \
        -exec basename {} \; | sed -r 's/_access\.log$//' | sed -r 's/_error\.log$//' | sort -u | while read -r log_prefix; do

        ## Check if the log prefix is in the configured files
        domain_found=$(grep "|.*/${log_prefix}_access.log" "$LOG_PATHS_FILE" | cut -d '|' -f1)
        
        if [[ -n "$domain_found" ]]; then
            echo "$domain_found" >> "$ACTIVE_DOMAINS_FILE"
        else
            ## Search in /etc/nginx/sites-enabled to identify the domain
            related_domain=$(grep -Rl "/${log_prefix}_error.log" /etc/nginx/sites-enabled | xargs -I {} basename {})
            if [[ -n "$related_domain" ]]; then
                echo "$related_domain" >> "$ACTIVE_DOMAINS_FILE"
            fi
        fi
    done

    animateDots "Enumerating domains"
    
    # Format domains by removing underscores and replacing them with "."
    sed -i 's/_/./g' "$ACTIVE_DOMAINS_FILE"

    echo -e "Active domains:\n"
    sleep 1
    cat "$ACTIVE_DOMAINS_FILE"
    echo "===================================="
    sleep 1
    echo -e "\nTotal domains found: \e[1;31m$(wc -l < "$ACTIVE_DOMAINS_FILE")\e[0m"
}

# Function: Validate active domains
validateActiveDomains() {
    echo "=== Validating active domains with logs ==="
    while read -r domain; do
        if ! grep -q "^$domain$" "$DOMAINS_FILE"; then
            echo -e "\e[31m[ ! ] Domain not configured: $domain\e[0m"
        else
            echo -e "\e[32m[ + ] Active and configured domain: $domain\e[0m"
        fi
    done < "$ACTIVE_DOMAINS_FILE"
}

## Function: Dots animation
animateDots() {
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
    echo -ne "\r$message... \e[1;32mCompleted!\e[0m \n"
}

# Main menu
mainMenu() {
    while true; do
        echo -e "\n==== Main Menu ===="
        echo "1) List configured domains and logs"
        echo "2) Identify active domains"
        echo "3) Validate active domains"
        echo "4) Exit"
        read -rp "Choose an option: " option
        echo -e "==============================\n"
        case $option in
            1) listDomainsAndLogs ;;
            2) identifyActiveDomains ;;
            3) validateActiveDomains ;;
            4) exit 0 ;;
            *) echo "Invalid option! Try again." ;;
        esac
    done
}

# -----------------------------------------------------------------------------
#                                  MAIN
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

mainMenu