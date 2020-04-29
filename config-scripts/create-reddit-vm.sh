#! /bin/sh

set -x

project_id=$1
instance_name=$2
image_name=$3

# Правило брандмауэра для работы приложения

gcloud compute --project=$project_id \
firewall-rules create puma-server \
--direction=INGRESS \
--priority=1000 \
--network=default \
--action=ALLOW \
--rules=tcp:9292 \
--source-ranges=0.0.0.0/0 \
--target-tags=puma-server

# Создания инстанса VM

gcloud compute instances create $instance_name \
--project=$project_id \
--boot-disk-size=10GB \
--image=$image_name \
--image-project=$project_id \
--machine-type=g1-small \
--zone=europe-west3-a \
--tags puma-server \
--restart-on-failure
