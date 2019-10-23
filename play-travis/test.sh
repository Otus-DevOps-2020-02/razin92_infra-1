#! /usr/bin/sh
# Run only from project-root folder
set -e

root=$PWD
packer_root=$root/packer
terraform_root=$root/terraform
ansible_playbooks=$root/ansible/playbooks
end_line=---

# Packer Validate
echo ---------------
echo Packer Validate 
echo ---------------
var_file=$packer_root/variables.json.example
for each in app.json db.json immutable.json ubuntu16.json; do
    echo Validate $each
    packer validate -var-file=$var_file $packer_root/$each
    echo $end_line
done

# Terraform Validate
echo ------------------
echo Terraform Validate
echo ------------------
echo Stage Validate
cd $terraform_root/stage 
tflint && terraform get && terraform init -backend=false && terraform validate
echo $end_line
echo Prod Validate
cd $terraform_root/prod
tflint && terraform get && terraform init -backend=false && validate
echo $end_line

# Ansible Check
echo Ansible Check
ansible-lint -x 401 $ansible_playbooks/*
