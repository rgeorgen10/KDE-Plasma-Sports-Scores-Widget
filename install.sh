#!/bin/bash

# Install script for Sports Scores Plasma 6 Widget

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Sports Scores Widget - Plasma 6 Installation${NC}"
echo "=============================================="
echo ""

# Check if running Plasma 6
if ! plasmashell --version 2>/dev/null | grep -q "plasmashell 6"; then
    echo -e "${YELLOW}Warning: Plasma 6 not detected.${NC}"
    echo "This widget is designed for Plasma 6."
    echo "For Plasma 5, please use the Plasma 5 version of this widget."
    echo ""
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Get the widget directory
WIDGET_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WIDGET_NAME="com.example.sportsscores"

# Uninstall old version if it exists
echo "Checking for existing installation..."
if kpackagetool6 --type=Plasma/Applet --show "$WIDGET_NAME" &>/dev/null; then
    echo -e "${YELLOW}Removing existing installation...${NC}"
    kpackagetool6 --type=Plasma/Applet --remove "$WIDGET_NAME"
fi

# Install the widget
echo "Installing widget..."
if kpackagetool6 --type=Plasma/Applet --install "$WIDGET_DIR"; then
    echo -e "${GREEN}✓ Widget installed successfully!${NC}"
    echo ""
    echo "To add the widget to your panel or desktop:"
    echo "1. Right-click on your desktop or panel"
    echo "2. Select 'Add Widgets...'"
    echo "3. Search for 'Sports Scores'"
    echo "4. Drag it to your desired location"
    echo ""
    echo "You can configure the widget by right-clicking on it and selecting 'Configure Sports Scores...'"
else
    echo -e "${RED}✗ Installation failed!${NC}"
    echo "Please check the error messages above."
    exit 1
fi
