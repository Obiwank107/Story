#!/bin/bash

GREEN=$(tput setaf 2)
RESET=$(tput sgr0)

# Function to read user input for moniker name
get_moniker_name() {
    read -p "Enter your moniker name: " MONIKER_NAME
    echo "Your moniker name is: $MONIKER_NAME"
    sleep 3
}
