#! /usr/bin/sh

# Upgrade pip
sudo pip install --upgrade pip
# Install Ansible
sudo pip install ansible
# Install Ansible-lint
sudo pip install ansible-lint
# Install tflint
curl https://raw.githubusercontent.com/wata727/tflint/master/install_linux.sh | bash
# Install Terraform
curl https://releases.hashicorp.com/terraform/0.12.8/terraform_0.12.8_linux_amd64.zip -o /tmp/terraform.zip
sudo unzip /tmp/terraform.zip terraform -d /usr/bin/
