#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

date
echo "Starting application update on VM..."

REPO_URL="github.com/taif300/capstone_project.git"
BRANCH="main"
GITHUB_TOKEN=$TOKEN  # Securely passed via protectedSettings
HOME_DIR=$(eval echo ~$USER)
APP_DIR="$HOME_DIR/capstone_project"
CONDA_ENV_DIR="$HOME_DIR/miniconda3/envs/project"
PIP_CMD="$CONDA_ENV_DIR/bin/pip"

# Ensure Miniconda and environment exist
if [ ! -d "$CONDA_ENV_DIR" ]; then
    echo "Error: Miniconda environment not found at $CONDA_ENV_DIR"
    exit 1
fi

# Update or clone repository
if [ -d "$APP_DIR" ]; then
    echo "Updating existing repository..."
    sudo -u azureuser bash -c "cd $APP_DIR && git fetch origin && git reset --hard origin/$BRANCH"
else
    echo "Cloning repository..."
    sudo -u azureuser git clone -b "$BRANCH" "https://${GITHUB_TOKEN}@${REPO_URL}" "$APP_DIR"
fi

# Install dependencies
echo "Installing dependencies..."
if [ -f "${APP_DIR}/requirements.txt" ]; then
    sudo -u azureuser $PIP_CMD install --upgrade pip
    sudo -u azureuser $PIP_CMD install -r "${APP_DIR}/requirements.txt"
else
    echo "Error: requirements.txt not found!"
    exit 1
fi

# Restart services
restart_service() {
    local SERVICE=$1
    echo "Restarting $SERVICE service..."
    
    if systemctl list-units --full -all | grep -q "$SERVICE.service"; then
        sudo systemctl restart "$SERVICE"
        sleep 3
        if sudo systemctl is-active --quiet "$SERVICE"; then
            echo "$SERVICE is running"
        else
            echo "Error: $SERVICE failed to start"
            sudo systemctl status "$SERVICE" --no-pager
        fi
    else
        echo "Warning: $SERVICE service not found. Skipping..."
    fi
}

restart_service "backend"
restart_service "frontend"

echo "Application update completed successfully!"
