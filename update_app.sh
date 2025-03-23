#!/bin/bash

set -e  # Exit on any error

date
echo "Updating Python application on VM..."

REPO_URL="git@github.com:taif300/capstone_project.git"
BRANCH="main"
HOME_DIR="$HOME"
APP_DIR="$HOME_DIR/capstone_project"

# Ensure SSH key exists
if [ ! -f "$HOME/.ssh/id_rsa" ]; then
    echo "ERROR: SSH key not found! Ensure you have an SSH key added to GitHub."
    exit 1
fi

# Update code
if [ -d "$APP_DIR" ]; then
    cd "$APP_DIR"
    git fetch origin
    git reset --hard origin/$BRANCH
else
    git clone -b "$BRANCH" "$REPO_URL" "$APP_DIR"
fi

# Install dependencies
"$HOME_DIR/miniconda3/envs/project/bin/pip" install --upgrade pip
"$HOME_DIR/miniconda3/envs/project/bin/pip" install -r "${APP_DIR}/requirements.txt"

# Restart services and check status
sudo systemctl restart backend
sudo systemctl is-active --quiet backend || echo "Backend failed to start"
sudo systemctl restart frontend
sudo systemctl is-active --quiet frontend || echo "Frontend failed to start"

echo "Python application update completed!"
