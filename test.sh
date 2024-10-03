#!/bin/bash

GREEN=$(tput setaf 2)
RESET=$(tput sgr0)

unset MONIKER_NAME
echo "Input your Moniker Name then Press Enter"
read -p "Enter your moniker name: " MONIKER_NAME

echo "Your moniker name is: $MONIKER_NAME"
sleep 3

#System Upgrade and Install
echo "Upgrading and installing dependencies, if needed"
sleep 3
sudo apt update && sudo apt upgrade -y || { echo "Failed to upgrade system"; exit 1; }
sudo apt install curl git wget htop tmux build-essential jq make lz4 gcc unzip -y || { echo "Failed to install dependencies"; exit 1; }
echo "${GREEN}✅ Upgrading and installing dependencies Completed${RESET}"
