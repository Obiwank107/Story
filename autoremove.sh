#!/bin/bash

echo -e "\e[31m⚠️  WARNING: This script will PERMANENTLY REMOVE your Story Node! ⚠️\e[0m"
echo -e "\e[33m🚨 This action CANNOT be undone! If you wish to cancel, PRESS CTRL+C NOW! 🚨\e[0m"

# Add a short sleep to give time for the user to cancel
sleep 5

sudo systemctl stop story && \
sudo systemctl stop story-geth && \
sudo systemctl disable story-geth && \
sudo systemctl disable story && \
sudo rm $HOME/go/bin/story-geth && \
sudo rm $HOME/go/bin/story && \
sudo rm $HOME/story && \
sudo rm -rf $HOME/.story && \
sudo rm /etc/systemd/system/story-geth.service && \
sudo rm /etc/systemd/system/story.service && \
sudo systemctl daemon-reload

echo -e "\e[32m🎉 CONGRATULATIONS! 🎉\e[0m"
echo -e "\e[32m✅ Story Node has been successfully removed from your device! ✅\e[0m"
