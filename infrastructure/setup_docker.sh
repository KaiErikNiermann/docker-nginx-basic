#!/bin/bash

# Function to wait for apt-get to finish
wait_for_apt() {
    while pgrep -x apt-get > /dev/null; do
        echo "Waiting for apt-get to finish..."
        sleep 5
    done
}

wait_for_apt

sudo apt-get update

wait_for_apt

sudo apt-get install -y ca-certificates curl

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y

# Install Docker and related tools
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose

# Test Docker installation with hello-world container
sudo docker run hello-world

echo "Docker setup completed."
