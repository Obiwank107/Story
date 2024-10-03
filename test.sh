#!/bin/bash

GREEN=$(tput setaf 2)
RESET=$(tput sgr0)

store_operator_fid_env() {
    local input
    local response
    
    read -p "> Your Moniker Name: " input
    if [[ -z $input ]]; then
        response=""
    else [[ $input =~ ^-?[0-9]+$ ]]; then
        response=$input
    fi

    if [ "$response" != "null" ] && [ "$response" != "" ]; then
        MONIKER_NAME=$response
    else
        echo "Your Moniker Name is Empty or not set"
    fi
}

echo "Your moniker name is: $MONIKER_NAME"
sleep 3

#System Upgrade and Install
echo "Upgrading and installing dependencies, if needed"
sleep 3
sudo apt update && sudo apt upgrade -y || { echo "Failed to upgrade system"; exit 1; }
sudo apt install curl git wget htop tmux build-essential jq make lz4 gcc unzip -y || { echo "Failed to install dependencies"; exit 1; }
echo "${GREEN}✅ Upgrading and installing dependencies Completed${RESET}"
