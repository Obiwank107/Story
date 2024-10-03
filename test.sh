#!/bin/bash

while true; do
    read -e -p "Enter your moniker name: " MONIKER_NAME
    if [[ -z "$MONIKER_NAME" ]]; then
        echo "Moniker name cannot be empty. Please enter a valid name."
    else
        break
    fi
done

echo "Your moniker name is: $MONIKER_NAME"
