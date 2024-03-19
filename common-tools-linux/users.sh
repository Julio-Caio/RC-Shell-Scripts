#!/bin/bash

whoami=$(whoami)

if [ "$whoami" != "root" ]; then
    echo "You must be root to run this script"
    exit 1
fi

menu() {
    declare -A choices
    choices=(
        [1]="addUser"
        [2]="removeUser"
        [3]="addToGroup"
        [4]="removeFromGroup"
        [5]="changePassword"
        [6]="showDate"
    )

    echo "Hello, $whoami! What would you like to do?"
    echo "1. Add a new user"
    echo "2. Remove a user"
    echo "3. Add a user to a group"
    echo "4. Remove a user from a group"
    echo "5. Change a user's password"
    echo "6. Show date (dd/mm/yyyy)"
    read -p "Enter your choice: " choice
    echo " "

    if [ "${choices[$choice]}" ]; then
        ${choices[$choice]}
    else
        echo "Invalid choice."
    fi
}

addUser() {
    read -p "Enter the username: " username
    adduser "$username"
}

removeUser() {
    read -p "Enter the username: " username
    deluser "$username"
}

addToGroup() {
    read -p "Enter the username: " username
    read -p "Enter the group name: " groupname
    usermod -a -G "$groupname" "$username"
}

removeFromGroup() {
    read -p "Enter the username: " username
    read -p "Enter the group name: " groupname
    gpasswd -d "$username" "$groupname"
}

changePassword() {
    read -p "Enter the username: " username
    passwd "$username"
}

showDate() {
    date +"%d/%m/%Y"
}

menu
