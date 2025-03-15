#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Update the package list
sudo apt-get update -y

# Install required dependencies
sudo apt-get install -y software-properties-common wget gpg

# Add Grafana GPG key
wget -q -O - https://packages.grafana.com/gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/grafana-keyring.gpg

# Add the Grafana repository
echo "deb [signed-by=/usr/share/keyrings/grafana-keyring.gpg] https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list > /dev/null

# Update the package list after adding the Grafana repository
sudo apt-get update -y

# Install Grafana
sudo apt-get install -y grafana

# Start Grafana service
sudo systemctl start grafana-server

# Enable Grafana to start on boot
sudo systemctl enable grafana-server

# Print success message
echo "Grafana has been installed and started successfully."
