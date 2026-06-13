#!/bin/bash
set -e
GITHUB_REPO="https://github.com/NandiniBansal16/VPC_Architecture.git"
WEB_ROOT="/var/www/html"
sudo systemctl start apache2
sudo systemctl enable apache2
cd /tmp
git clone $GITHUB_REPO webapp
sudo cp -r webapp/html-web-app/* $WEB_ROOT/
sudo chown -R www-data:www-data $WEB_ROOT
sudo chmod -R 755 $WEB_ROOT
echo "App deployed!"
