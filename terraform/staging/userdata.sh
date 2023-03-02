#!/bin/bash
sudo groupadd sonarqube
sudo adduser sonarqube --system --no-create-home -g sonarqube --shell=/bin/false -c 'Sonar System User' -d /var/opt/sworks
echo "Adding datadog agent to sonarqube group to read logs ..."
sudo usermod -a -G sonarqube dd-agent