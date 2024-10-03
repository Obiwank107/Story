#!/bin/bash
#System Upgrade and Install
echo "Upgrading and installing dependencies, if needed"
sudo apt update && sudo apt upgrade -y
sudo apt install curl git wget htop tmux build-essential jq make lz4 gcc unzip -y
#Install Go
echo "Installing Go..."
cd $HOME
VER="1.23.1"
wget "https://golang.org/dl/go$VER.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$VER.linux-amd64.tar.gz"
rm "go$VER.linux-amd64.tar.gz"
[ ! -f ~/.bash_profile ] && touch ~/.bash_profile
echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin" >> ~/.bash_profile
source $HOME/.bash_profile
[ ! -d ~/go/bin ] && mkdir -p ~/go/bin
go version
#Downloading and installing Story-Geth binary
echo "Downloading and installing Story-Geth binary..."
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
#Build Story Binary
echo "Building Story binary(Latest Version)"
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
#Initialize the Iliad Network Node
echo "Initializing Iliad network node..."
echo "Input your Moniker Name then Press Enter"
read -p "Enter your moniker name: " MONIKER_NAME
story init --network iliad --moniker "$MONIKER_NAME"
#Create and Configure systemd Service for Story-Geth
echo "Creating systemd service for Story-Geth..."
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
#Create and Configure systemd Service for Story
echo "Creating systemd service for Story..."
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
#Reload systemd, Enable, and Start Services
echo "Reloading systemd, enabling, and starting Story-Geth and Story services..."
sudo systemctl daemon-reload
sudo systemctl enable story-geth story
sudo systemctl start story-geth story
#Check Service Status
echo "Checking Story-Geth service status..."
sudo systemctl status story-geth --no-pager -l
echo "Checking Story service status..."
sudo systemctl status story --no-pager -l
#Check Sync Status
echo "Checking sync status..."
curl -s localhost:26657/status | jq
echo "Congrats! Installation and setup complete!"
echo "Command to check Story logs >> sudo journalctl -u story -f -o cat <<"
echo "Command to check Story-geth logs >> sudo journalctl -u story-geth -f -o cat <<"
