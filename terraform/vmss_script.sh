#!/bin/bash

sudo apt update
sudo apt install -y gnupg2 wget git

sudo -u azureuser mkdir -p /home/azureuser/miniconda3
sudo -u azureuser wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /home/azureuser/miniconda3/miniconda.sh
sudo -u azureuser bash /home/azureuser/miniconda3/miniconda.sh -b -u -p /home/azureuser/miniconda3
sudo -u azureuser rm /home/azureuser/miniconda3/miniconda.sh


echo 'export PATH="/home/azureuser/miniconda3/bin:$PATH"' | sudo -u azureuser tee -a /home/azureuser/.bashrc

sudo -u azureuser git clone https://github.com/taif300/capstone_project.git /home/azureuser/capstone_project

sudo -u azureuser tee /home/azureuser/capstone_project/.env <<EOF
KEY_VAULT_NAME=${key_vault_name}
EOF

sudo -u azureuser /home/azureuser/miniconda3/bin/conda create -n project python=3.11 -y

sudo -u azureuser /home/azureuser/miniconda3/envs/project/bin/pip install -r /home/azureuser/capstone_project/requirements.txt

sudo -u azureuser systemctl restart backend
sudo -u azureuser systemctl restart frontend   