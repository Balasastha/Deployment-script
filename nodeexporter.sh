#!/bin/bash

# Exit the script if any command fails
set -e

echo "Starting Node Exporter installation..."

# Step 1: Download Node Exporter
echo "Downloading Node Exporter..."
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz -O /tmp/node_exporter.tar.gz

# Step 2: Extract the archive
echo "Extracting Node Exporter..."
tar -xvzf /tmp/node_exporter.tar.gz -C /tmp/

# Step 3: Move the binary
echo "Moving Node Exporter binary to /usr/local/bin..."
sudo mv /tmp/node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/

# Step 4: Create a user for Node Exporter
echo "Creating a dedicated user for Node Exporter..."
sudo useradd --no-create-home --shell /bin/false prometheus

# Step 5: Set ownership and permissions
echo "Setting permissions for Node Exporter..."
sudo chown prometheus:prometheus /usr/local/bin/node_exporter

# Step 6: Create a systemd service file
echo "Creating systemd service file for Node Exporter..."
cat <<EOL | sudo tee /etc/systemd/system/node_exporter.service > /dev/null
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=prometheus
ExecStart=/usr/local/bin/node_exporter
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# Step 7: Reload systemd, start, and enable Node Exporter
echo "Starting and enabling Node Exporter service..."
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

echo "Node Exporter installation and configuration completed successfully!"
