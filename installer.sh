#!/bin/bash

# Arix Theme Installer for Pterodactyl
# Usage: bash installer.sh

set -e

PANEL_PATH="${PTERODACTYL_PATH:-/var/www/pterodactyl}"
THEME_URL="https://github.com/YourUsername/arix-v1.3.1/archive/refs/heads/main.tar.gz"
THEME_NAME="arix"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}     Arix Theme Installer v1.3.1${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}[ERROR] Run as root!${NC}"
    exit 1
fi

if [ ! -d "$PANEL_PATH" ]; then
    echo -e "${RED}[ERROR] Pterodactyl not found at $PANEL_PATH${NC}"
    echo -e "${YELLOW}Set PTERODACTYL_PATH=/path/to/panel${NC}"
    exit 1
fi

echo -e "${YELLOW}[*] Downloading Arix...${NC}"
cd /tmp
curl -sL "$THEME_URL" -o arix.tar.gz
tar -xzf arix.tar.gz
cd arix-v1.3.1-main

echo -e "${YELLOW}[*] Installing theme...${NC}"
cp -r pterodactyl/app/Console/Commands/* "$PANEL_PATH/app/Console/Commands/"
cp -r pterodactyl/arix/* "$PANEL_PATH/public/arix/" 2>/dev/null || true
cp -r pterodactyl/arix/v1.3.1/app/* "$PANEL_PATH/app/"
cp -r pterodactyl/arix/v1.3.1/config/* "$PANEL_PATH/config/"
cp -r pterodactyl/arix/v1.3.1/database/* "$PANEL_PATH/database/"
cp -r pterodactyl/arix/v1.3.1/resources/* "$PANEL_PATH/resources/"
cp -r pterodactyl/arix/v1.3.1/routes/* "$PANEL_PATH/routes/"

echo -e "${YELLOW}[*] Running migrations...${NC}"
cd "$PANEL_PATH"
php artisan migrate --force

echo -e "${YELLOW}[*] Clearing cache...${NC}"
php artisan optimize:clear
php artisan optimize

echo -e "${YELLOW}[*] Setting permissions...${NC}"
chmod -R 755 storage/* bootstrap/cache

rm -rf /tmp/arix-v1.3.1-main /tmp/arix.tar.gz

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}     Arix installed!${NC}"
echo -e "${GREEN}     Run: php artisan arix${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
