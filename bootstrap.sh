#!/bin/bash

GREEN=$(tput setaf 2)
RESET=$(tput sgr0)

#User input Monikor Name
echo "Input your Moniker Name then Press Enter"
read -p "Enter your moniker name: " MONIKER_NAME

# Check if MONIKER_NAME is set
if [ -z "$MONIKER_NAME" ]; then
    echo "Moniker name is not set. Exiting..."
    exit 1
else
    echo "Your moniker name is: $MONIKER_NAME"
fi
sleep 3

#System Upgrade and Install
echo "Upgrading and installing dependencies, if needed"
sleep 3
sudo apt update && sudo apt upgrade -y || { echo "Failed to upgrade system"; exit 1; }
sudo apt install curl git wget htop tmux build-essential jq make lz4 gcc unzip -y || { echo "Failed to install dependencies"; exit 1; }
echo "${GREEN}✅ Upgrading and installing dependencies Completed${RESET}"
sleep 3

#Install Go
echo "Installing Go..."
sleep 3
cd $HOME
VER="1.23.1"
GO_URL="https://golang.org/dl/go$VER.linux-amd64.tar.gz"
if curl --output /dev/null --silent --head --fail "$GO_URL"; then
    echo "Go download URL reachable."
else
    echo "Go download URL not reachable, please check the URL or network connection."
    exit 1
fi
wget "https://golang.org/dl/go$VER.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$VER.linux-amd64.tar.gz"
rm "go$VER.linux-amd64.tar.gz"
[ ! -f ~/.bash_profile ] && touch ~/.bash_profile
echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin" >> ~/.bash_profile
source $HOME/.bash_profile
[ ! -d ~/go/bin ] && mkdir -p ~/go/bin
go version
echo "${GREEN}✅ Install GO Completed${RESET}"
sleep 3

#Downloading and installing Story-Geth binary
echo "Downloading and installing Story-Geth binary..."
sleep 3
cd $HOME
rm -rf bin
wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/geth-public/geth-linux-amd64-0.9.3-b224fdf.tar.gz
tar -xzvf geth-linux-amd64-0.9.3-b224fdf.tar.gz
[ ! -d "$HOME/go/bin" ] && mkdir -p $HOME/go/bin
if ! grep -q "$HOME/go/bin" $HOME/.bash_profile; then
  echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin" >> ~/.bash_profile
fi
sudo cp geth-linux-amd64-0.9.3-b224fdf/geth $HOME/go/bin/story-geth
source $HOME/.bash_profile
story-geth version
echo "${GREEN}✅ Install story-geth binary Completed${RESET}"
sleep 3

#Build Story Binary
echo "Building Story binary(Latest Version)"
sleep 3
cd $HOME
rm -rf story
git clone https://github.com/piplabs/story
cd story
git fetch --tags
latestTag=$(git describe --tags `git rev-list --tags --max-count=1`)
git checkout $latestTag
git status
go build -o story ./client
[ ! -d "$HOME/go/bin" ] && mkdir -p $HOME/go/bin
if ! grep -q "$HOME/go/bin" $HOME/.bash_profile; then
  echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin" >> ~/.bash_profile
fi
sudo mv ~/story/story ~/go/bin/
source $HOME/.bash_profile
story version
echo "${GREEN}✅ Install story binary Completed${RESET}"
sleep 3

#Initialize the Iliad Network Node
echo "Initializing Iliad Network Node Moniker Name : $MONIKER_NAME"
sleep 3
story init --network iliad --moniker "$MONIKER_NAME"
echo "${GREEN}✅ Network iliad $MONIKER_NAME initialize Completed${RESET}"
sleep 3

#Create and Configure systemd Service for Story-Geth
echo "Creating systemd service for Story-Geth..."
sleep 3
sudo tee /etc/systemd/system/story-geth.service > /dev/null <<EOF
[Unit]
Description=Story Geth Client
After=network.target

[Service]
User=root
ExecStart=/root/go/bin/story-geth --iliad --syncmode full
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF
echo "${GREEN}✅ Create systemd story-geth.service Completed${RESET}"
sleep 3

#Create and Configure systemd Service for Story
echo "Creating systemd service for Story..."
sleep 3
sudo tee /etc/systemd/system/story.service > /dev/null <<EOF
[Unit]
Description=Story Consensus Client
After=network.target

[Service]
User=root
ExecStart=/root/go/bin/story run
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF
echo "${GREEN}✅ Create systemd story.service Completed${RESET}"
sleep 3

#Reload systemd, Enable, and Start Services
echo "Reloading systemd, enabling, and starting Story-Geth and Story services..."
sleep 3
sudo systemctl daemon-reload
sudo systemctl enable story-geth story
sudo systemctl enable story
sudo systemctl start story-geth story
sudo systemctl start story
echo "${GREEN}✅ Start story and story-geth service Completed${RESET}"
sleep 3

#Check Service Status
echo "Checking Story-Geth service status..."
sleep 3
sudo systemctl status story-geth --no-pager -l
sleep 3
echo "Checking Story service status..."
sleep 3
sudo systemctl status story --no-pager -l
sleep 3

#Check Sync Status
echo "Checking sync status..."
sleep 3
curl -s localhost:26657/status | jq
sleep 3
echo "${GREEN}✅✅✅✅✅ Congrats! Installation and setup completed! ✅✅✅✅✅${RESET}"
sleep 1
echo "Command to check Story logs >> sudo journalctl -u story -f -o cat <<"
sleep 1
echo "Command to check Story-geth logs >> sudo journalctl -u story-geth -f -o cat <<"
sleep 1
echo "Now waiting for your Node 100% sync Before you can create Validator"
