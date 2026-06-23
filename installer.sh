#!/bin/bash

# Arix Theme Installer for Pterodactyl Panel
# Requirements: Pterodactyl Panel already installed
# Usage: bash installer.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

REPO="CodeByCruel/arix-v1.3.1"
BRANCH="master"

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}       Arix Theme Installer v1.3.1${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}[ERROR] Run as root: sudo bash installer.sh${NC}"
    exit 1
fi

# Detect panel path
PANEL_PATH=""
for path in /var/www/pterodactyl /var/www/panel /home/pterodactyl/panel /opt/pterodactyl; do
    if [ -f "$path/artisan" ]; then
        PANEL_PATH="$path"
        break
    fi
done

if [ -z "$PANEL_PATH" ]; then
    echo -e "${YELLOW}Pterodactyl not found. Enter panel path:${NC}"
    read -rp "Path: " PANEL_PATH
    if [ ! -f "$PANEL_PATH/artisan" ]; then
        echo -e "${RED}[ERROR] artisan not found at $PANEL_PATH${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}[OK] Panel found: $PANEL_PATH${NC}"

# Check php
if ! command -v php &>/dev/null; then
    echo -e "${RED}[ERROR] PHP not found${NC}"
    exit 1
fi

# Download theme
echo -e "${YELLOW}[*] Downloading Arix v1.3.1...${NC}"
cd /tmp
rm -rf arix-v1.3.1-master arix.tar.gz
curl -sL "https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz" -o arix.tar.gz

if [ ! -s arix.tar.gz ]; then
    echo -e "${RED}[ERROR] Download failed${NC}"
    exit 1
fi

tar -xzf arix.tar.gz
THEME_DIR="/tmp/arix-v1.3.1-master"

if [ ! -d "$THEME_DIR/pterodactyl" ]; then
    echo -e "${RED}[ERROR] Invalid theme package${NC}"
    exit 1
fi

echo -e "${GREEN}[OK] Downloaded${NC}"

# Copy theme to panel (arix directory)
echo -e "${YELLOW}[*] Copying theme files...${NC}"
cp -rf "$THEME_DIR/pterodactyl/arix" "$PANEL_PATH/"

# Copy artisan command
cp -f "$THEME_DIR/pterodactyl/app/Console/Commands/"*.php "$PANEL_PATH/app/Console/Commands/"

echo -e "${GREEN}[OK] Files copied${NC}"

# Cleanup
rm -rf /tmp/arix-v1.3.1-master /tmp/arix.tar.gz

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}     Files Ready!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}Now run:${NC}"
echo -e "  cd $PANEL_PATH"
echo -e "  php artisan arix install"
