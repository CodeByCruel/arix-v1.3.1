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

# Install theme files
echo -e "${YELLOW}[*] Installing theme files...${NC}"

# Commands
cp -f "$THEME_DIR/pterodactyl/app/Console/Commands/"*.php "$PANEL_PATH/app/Console/Commands/"

# Theme core - app files
cp -rf "$THEME_DIR/pterodactyl/arix/v1.3.1/app/Http/" "$PANEL_PATH/app/Http/"
cp -f "$THEME_DIR/pterodactyl/arix/v1.3.1/app/Models/"*.php "$PANEL_PATH/app/Models/" 2>/dev/null || true
cp -f "$THEME_DIR/pterodactyl/arix/v1.3.1/app/Transformers/"*.php "$PANEL_PATH/app/Transformers/" 2>/dev/null || true
cp -rf "$THEME_DIR/pterodactyl/arix/v1.3.1/app/ViewComposers/" "$PANEL_PATH/app/ViewComposers/" 2>/dev/null || true

# Config
cp -f "$THEME_DIR/pterodactyl/arix/v1.3.1/config/arix.php" "$PANEL_PATH/config/"

# Database migrations
cp -f "$THEME_DIR/pterodactyl/arix/v1.3.1/database/migrations/"*.php "$PANEL_PATH/database/migrations/" 2>/dev/null || true

# Resources (views, lang, scripts)
cp -rf "$THEME_DIR/pterodactyl/arix/v1.3.1/resources/views/" "$PANEL_PATH/resources/views/"
cp -rf "$THEME_DIR/pterodactyl/arix/v1.3.1/resources/lang/" "$PANEL_PATH/resources/lang/"
cp -rf "$THEME_DIR/pterodactyl/arix/v1.3.1/resources/scripts/" "$PANEL_PATH/resources/scripts/"

# Routes
cp -f "$THEME_DIR/pterodactyl/arix/v1.3.1/routes/admin.php" "$PANEL_PATH/routes/"
cp -f "$THEME_DIR/pterodactyl/arix/v1.3.1/routes/auth.php" "$PANEL_PATH/routes/"

# Public assets
mkdir -p "$PANEL_PATH/public/arix"
cp -rf "$THEME_DIR/pterodactyl/arix/v1.3.1/public/arix/"* "$PANEL_PATH/public/arix/"
cp -rf "$THEME_DIR/pterodactyl/arix/v1.3.1/public/themes/"* "$PANEL_PATH/public/themes/"

echo -e "${GREEN}[OK] Files installed${NC}"

# Run migrations
echo -e "${YELLOW}[*] Running migrations...${NC}"
cd "$PANEL_PATH"
php artisan migrate --force 2>/dev/null || true

# Clear and rebuild cache
echo -e "${YELLOW}[*] Optimizing panel...${NC}"
php artisan optimize:clear
php artisan optimize

# Set permissions
echo -e "${YELLOW}[*] Setting permissions...${NC}"
chown -R www-data:www-data "$PANEL_PATH/storage" "$PANEL_PATH/bootstrap/cache" 2>/dev/null || true
chmod -R 755 "$PANEL_PATH/storage" "$PANEL_PATH/bootstrap/cache" 2>/dev/null || true

# Cleanup
rm -rf /tmp/arix-v1.3.1-master /tmp/arix.tar.gz

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}     Arix Theme Installed!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}Configure theme:${NC}"
echo -e "  1. Go to Admin Panel → Arix Theme"
echo -e "  2. Or edit: ${PANEL_PATH}/config/arix.php"
echo -e "  3. Then run: ${CYAN}php artisan config:clear${NC}"
