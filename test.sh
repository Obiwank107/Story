#!/bin/bash

# Prompt for user input
while true; do
    read -e -p "Enter your moniker name: " MONIKER_NAME
    sleep 5
    if [[ -z "$MONIKER_NAME" ]]; then
        echo "Moniker name cannot be empty. Please enter a valid name."
    else
        echo "Your moniker name is: $MONIKER_NAME"
        break
    fi
done
