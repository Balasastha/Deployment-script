#!/bin/bash

# Exit script on any error
set -e

echo "Starting setup for Prometheus..."

# --- Install Prometheus ---
echo "Downloading Prometheus..."
wget https://github.com/prometheus/prometheus/releases/download/v2.47.0/prometheus-2.47.0.linux-amd64.tar.gz -O /tmp/prometheus.tar.gz

echo "Extracting Prometheus..."
tar xvfz /tmp/prometheus.tar.gz -C /tmp/

echo "Moving Prometheus binaries to /usr/local/bin..."
sudo mv /tmp/prometheus-2.47.0.linux-amd64/prometheus /usr/local/bin/
sudo mv /tmp/prometheus-2.47.0.linux-amd64/promtool /usr/local/bin/

echo "Moving Prometheus configuration and data directories..."
sudo mkdir -p /etc/prometheus /var/lib/prometheus
sudo mv /tmp/prometheus-2.47.0.linux-amd64/consoles /etc/prometheus/
sudo mv /tmp/prometheus-2.47.0.linux-amd64/console_libraries /etc/prometheus/

# --- Setup Prometheus configuration ---
echo "Creating Prometheus configuration file..."
cat <<EOL | sudo tee /etc/prometheus/prometheus.yml > /dev/null
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['13.235.248.20:9100', '65.0.123.45:9100']
EOL

# --- Create Prometheus systemd service ---
echo "Creating Prometheus systemd service..."
cat <<EOL | sudo tee /etc/systemd/system/prometheus.service > /dev/null
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
ExecStart=/usr/local/bin/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/var/lib/prometheus/ --web.console.templates=/etc/prometheus/consoles --web.console.libraries=/etc/prometheus/console_libraries
Restart=always

[Install]
WantedBy=multi-user.target
EOL

echo "Creating Prometheus user and setting permissions..."
sudo useradd --no-create-home --shell /bin/false prometheus
sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus

# Start Prometheus
echo "Starting Prometheus service..."
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus

# --- Install Node Exporter on Local Machine ---
echo "Installing Node Exporter on this machine..."
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz -O /tmp/node_exporter.tar.gz
tar -xvzf /tmp/node_exporter.tar.gz -C /tmp/
sudo mv /tmp/node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/

echo "Creating Node Exporter systemd service..."
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

echo "Starting Node Exporter service..."
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

# --- Completion ---
echo "Setup completed! Prometheus is running and Node Exporter is installed."
