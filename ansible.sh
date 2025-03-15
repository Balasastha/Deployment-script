#!/bin/bash
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
sudo mkdir -p /etc/ansible
sudo touch /etc/ansible/hosts
sudo chmod 644 /etc/ansible/hosts
echo installation done
