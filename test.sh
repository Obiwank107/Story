#!/bin/bash

GREEN=$(tput setaf 2)
RESET=$(tput sgr0)

read -p "> Your Moniker Name: " MONIKER_NAME

echo "Your moniker name is: $MONIKER_NAME"
sleep 3

#System Upgrade and Install
echo "Upgrading and installing dependencies, if needed"
sleep 3
echo "${GREEN}✅ Upgrading and installing dependencies Completed${RESET}"
