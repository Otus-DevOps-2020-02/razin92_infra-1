# razin92_infra
Репозиторий для работы над домашними заданиями в рамках курса **"DevOps практики и инструменты"**

**Содрежание:**
<a name="top"></a>
1. [ДЗ#3 - Знакомство с облачной инфраструктурой](#hw3)
2. [ДЗ#4 - Деплой тестового приложения](#hw4)
3. [ДЗ#5 - Сборка образов VM при помощи Packer](#hw5)
4. [ДЗ#6 - Практика IaC с использованием Terraform](#hw6)
---
<a name="hw3"></a> 
# Домашнее задание 3
## Знакомство с облачной инфраструктурой
**Необходимые данные для проверки ДЗ**
```
bastion_IP = 35.207.131.174
someinternalhost_IP = 10.156.0.3
```

**Команда для создания ключей SSH**

```
$ ssh-keygen -t rsa -f ~/.ssh/$USERNAME -C $COMMENT -P ""

# -t rsa - тип создаваемого ключа
# -f - путь сохранения ключа
# -С - комментарий
# -P - пароль создаваемого ключа
```
***Приватный ключ***
```
$ ~/.ssh/$USERNAME
```
***Публичный ключ***
```
$ ~/.ssh/$USERNAME.pub
```
Публичный ключ используется для доступа в виртуальные машины всего проекта через SSH. Устанавливается ключ через GCE --> Метаданные --> SSH-Ключи. При желании может быть переназначен.

***Создание виртуальной машины с внешней сетью - Экземпляры ВМ***

**Подключение к виртуальной машине с использованием приватного ключа**
```
$ ssh -i ~/.ssh/$USERNAME $USERNAME@<внешний IP VM>

# -i - путь до ключа
```

***Создание виртуальной машины без доступа к внешенй сети - Экземпляры ВМ***

**Настройка SSH Forwarding**

```
# Проверка текущих настроек
$ ssh-add -L

# -L - список параметров публичных ключей
```
При получении ошибки
> Could not open a connection to your authentication agent.

Следует выполнить следующую команду
```
$ eval "$(ssh-agent)"
# Запуск ssh-agent, который требует ssh-add
```
***Добавление ключа***
```
$ ssh-add ~/.ssh/$USERNAME
```
***Подключение по SSH с включенным SSH Forwarding***
```
ssh -i ~/.ssh/$USERNAME -A $USERNAME@<IP адрес сервера>

# -A - SSH Forwarding
```
### Самостоятельное задание
**Подключение к локальной машине в удаленной приватной сети через bastion-host**
1. Подключение через ***Pseudo-terminal*** ! НЕ рекомендуется
    ```
    $ ssh -i ~/.ssh/$USERNAME $USERNAME@<IP-адрес bastion-host'а> 'ssh <IP-адрес локальной машины>'

    # "консоль" является 'stdin' выполненной команды
    ```
2. Подключение с использованием bastion-host'а как Proxy
    ```
    $ ssh -i ~/.ssh/$USERNAME $USERNAME@<IP-адрес локальной машины> -o "proxycommand ssh -W %h:%p $USERNAME@<IP-адрес bastion-host'а>"

    # -o - использование дополнительных опций SSH
    # -W - проброс stdin/stdout через Proxy
    # %h:%p - Hostname:Port машины $USERNAME@<IP-адрес локальной машины>
    ```
**Подключение к локальной машине в удаленной приватной сети через bastion-host при помощи команды вида ***ssh someinternalhost*** и по алиасу ***someinternalhost*****

Для создания простого подключения по SSH необходимо добавить следующую конфигурацию в файл `~/.ssh/config`
```
Host someinternalhost    # Наименование хоста (используется для вызова)
  Hostname <IP-адрес локальной машины>
  User $USERNAME
  ProxyCommand ssh -W %h:%p <IP-адрес bastion-host'а>   # Использования bastion-host'а как Proxy
  IdentityFile ~/.ssh/$USERNAME    # путь до ключа
```
Для создания алиаса необходимо выполнить следующую команду
```
$ alias <имя алиаса>='команда'

# Пример:
$ alias someinternalhost='ssh someinternalhost'
```

## VPN-сервер для серверов GCP

1. Установка VPN-сервера pritunl и базы mongodb
```
sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list << EOF
deb https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.0 multiverse
EOF

sudo tee /etc/apt/sources.list.d/pritunl.list << EOF
deb http://repo.pritunl.com/stable/apt xenial main
EOF

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A
sudo apt-get update
sudo apt-get --assume-yes install pritunl mongodb-org
sudo systemctl start pritunl mongod
sudo systemctl enable pritunl mongod
```
2. Запуск настройки через web-интерфейс https://<адрес сервера>/setup

3. Добавление User'а, организации и сервера.

При прикреплении User'a к серверу сгенерируется конфигурация для подключения через OpenVPN, доступная для скачивания.

***Пример конфигурации***
```
#{
# "push_auth": false,
# "sync_secret": "CMNLPCrfMgEFScVtadB3V3ANN1nRz4aC",
# "token_ttl": 172800,
# "organization_id": "5d827c58bbd3b54fa33a629b",
# "user": "test",
# "disable_reconnect": false,
# "sync_token": "mGdwSnoS5XNw2JO3rUEOznwwIKWyW9H0",
# "sync_hash": "6fec97399e8a7d5e2b7925f30b4ed999",
# "server_public_key": [
#  "-----BEGIN RSA PUBLIC KEY-----",
#  "MIICCgKCAgEArUloHbGwM21W60vKFjBf9LoiJvTy5e4z+32rGORiOH2Gl2aIVpdL",
#  "TaK9f4ksSWTBjsP9mLgW+Xrti3aZZ6GT0CFhT00Gs7sA1uTNKx682DWjCM8fDGJU",
#  "6fJ1rDlLYhULaMrWh7shi5OBc7cXODsVrTQkdGM8Be6Q+mAgOJzDjfkokOnlPTMk",
#  "nvkczM1vDjGuTS7DJNvObHJqKpiGgUdK3oZqugbLWYGLCrE9g8terUb93rR5TNsR",
#  "OH6tpCQDSSym6KC7r+s4PBOJ0s+XszMR7TEGdm8v1Ou5ct8ktbzZrKrRbhxru5Vg",
#  "sHVZwfM7fZBla3YxDcZORTm9KKKuAVjVBGVgVDTiW2ruuRsz+HlSNdPmc5eH1kNa",
#  "7ZyriYQop/MlPyNEdV35mzL/k3FHd7U4Y3kX2/EFZc5dMBAN8HSAsbhQNJ0cOJh1",
#  "LQV48j0e/VzU6uYpPhrbZYDA4+GSAFHyU27qtq4P1LWywNeTGLWWjTw7BiT/wsFH",
#  "rcHtKxQRwlIx7IW9kF+vjgrLSgzR10qbTHt+DjxErn5tXtuI0sJgF7GW7k6CdJBq",
#  "V+VCJ83kYWkNOtCMmsK/BlXuktlzwXiWG6Nj3JtY3b9VQSB240/XqLdhSEL5r/ZE",
#  "UcGMf+SqidE6DQyStZTxqY+w6fgff9D7Y5bba16H2izBA7aXyohJxAECAwEAAQ==",
#  "-----END RSA PUBLIC KEY-----"
# ],
# "server_id": "5d827e01bbd3b54fa33a6406",
# "user_id": "5d827c59bbd3b54fa33a62a9",
# "server": "Bastion",
# "token": false,
# "version": 1,
# "push_auth_ttl": 172800,
# "sync_hosts": [
#  "https://35.207.131.174"
# ],
# "server_box_public_key": "eHFhIgPi+Z17CKHMlryqA8Am3dzEskvVWk52+mz37xQ=",
# "organization": "HW3",
# "password_mode": "pin"
#}
setenv UV_ID 5aa81c289d8d42a2822b898c561b7717
setenv UV_NAME restless-refuge-8788
client
dev tun
dev-type tun
remote 35.207.131.174 10855 udp
nobind
persist-tun
cipher AES-128-CBC
auth SHA1
verb 2
mute 3
push-peer-info
ping 10
ping-restart 60
hand-window 70
server-poll-timeout 4
reneg-sec 2592000
sndbuf 393216
rcvbuf 393216
max-routes 1000
remote-cert-tls server
comp-lzo no
auth-user-pass
key-direction 1
<ca>
</ca>
<tls-auth>
#
# 2048 bit OpenVPN static key
#
-----BEGIN OpenVPN Static key V1-----
-----END OpenVPN Static key V1-----
</tls-auth>
<cert>
</cert>
<key>
</key>
```
---
<a name="HW4"></a>
[Содержание](#top)
# Домашнее задание 4
## Деплой тестового приложения
**Необходимые данные для проверки ДЗ**
```
testapp_IP = 35.198.171.185
testapp_port = 9292
```
***Создание виртуальной машины в GCP с помощью gcloud***
```
gcloud compute instances create reddit-app \
--boot-disk-size=10GB \  
--image-family ubuntu-1604-lts \  
--image-project=ubuntu-os-cloud \  
--machine-type=g1-small \ 
--tags puma-server \  
--restart-on-failure  

# Имя виртуальной машины
# Размер загрузочного диска
# Образ ОС
# Семейство образа ОС
# Тип виртуальной машины
# Теги для сети
# Дополнительные опции
```
***Необходимые компоненты для тестового приложения***

**Ruby & Bundler**
```
$ sudo apt install -y ruby-full ruby-bundler build-essential 
```
**MongoDB**
```
# Репозиторий
$ sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
$ sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'
# Установка
$ sudo apt install -y mongodb-org
```
* ! При проблемах с GPG и ключем для получения установки с репозитория Mongo
  ```
  # 1. Можно проигнорировать проблему при установке, добавив --allow-unauthenticated
  $ sudo apt install -y mongodb-org --allow-unauthenticated

  # 2. Использовать официальную инструкцию по установке
  $ wget -qO - https://www.mongodb.org/static/pgp/server-3.2.asc | sudo apt-key add -
  $ echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
  $ sudo apt-get update
  $ sudo apt install -y mongodb-org
  ```
**Тестовое приложение**
 ([Ссылка на Github](https://github.com/express42/reddit/tree/monolith))

***Установка***

```
$ git clone -b monolith https://github.com/express42/reddit.git
$ cd reddit && bundle install
```
***Запуск***
```
$ puma -d
```
## Самостоятельная работа 1
**Скрипты для установки необходимых компонентов**

Вышеперечисленные команды завернуты в скрипты:
1. `install_ruby.sh`
2. `install_mongodb.sh`
3. `deploy.sh`

Чтобы данные скрипты добавились в репозиторий Git как исполняемые файлы необходимо после команды `git add` и до `git commit` выполнить следующую команду для всех файлов:
```
git update-index --chmod=+x some_script.sh
``` 
## Дополнительное задание 1
**startup-script для VM**

***Передача локального файла в качестве startup-script***
```
gcloud compute instances create reddit-app-test \
--boot-disk-size=10GB \
--image-family ubuntu-1604-lts \
--image-project=ubuntu-os-cloud \
--machine-type=g1-small \
--tags puma-server \
--restart-on-failure \
--metadata-from-file startup-script=./startup_script.sh
```
***Альтернативные варианты передачи startup_script.sh***
1. Код скрипта непосредственно в команде
```
gcloud compute instances create example-instance --tags http-server \
--metadata startup-script='#! /bin/bash
# Installs apache and a custom homepage
sudo su -
apt-get update
apt-get install -y apache2
cat <<EOF > /var/www/html/index.html
<html><body><h1>Hello World</h1>
<p>This page was created from a simple start up script!</p>
</body></html>
EOF'
```
2. Код скрипта загружается с заданного URL
```
gcloud compute instances add-metadata example-instance \
    --metadata startup-script-url=gs://bucket/file
```
***Полный состав startup-script***
```
#! /bin/sh
apt update
apt install -y ruby-full ruby-bundler build-essential
wget -qO - https://www.mongodb.org/static/pgp/server-3.2.asc | sudo apt-key add -
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
apt update
apt install -y mongodb-org
systemctl start mongod
systemctl enable mongod
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
puma -d
```
## Дополнительное задание 2
**Создание правила брандмауэра удаленно средствами gcloud**
```
gcloud compute --project=some-project-1234 \
firewall-rules create puma-server \
--direction=INGRESS \
--priority=1000 \
--network=default \
--action=ALLOW \
--rules=tcp:9292 \
--source-ranges=0.0.0.0/0 \
--target-tags=puma-server

 # Указание проекта для создания правила
 # Имя правила
 # Напрвление трфика
 # Приоритет правила
 # Сеть виртуальных машин
 # Действия брандмауэера
 # Порты
 # Сеть источника обращения
 # Теги
```
---
<a name="hw5"></a>
[Содержание](#top)
# Домашнее задание 5
## Сборка образов VM при помощи Packer
[Репозиторий Packer'a](https://www.packer.io/downloads.html)

Создание учетных данных для приложения в GCP
```
$ gcloud auth application-default login
```
Просмотр токена
```
$ gcloud auth application-default print-access-token
```
## Создание baked-образа
Шаблон представлен в `.json`-файлах

Пример параметров builders
```
{
    "builders": [
        {
            "type": "googlecompute",
            "project_id": "some-project-1234",
            "image_name": "some-image-{{timestamp}}",
            "image_family": "some-image",
            "source_image_family": "ubuntu-1604-lts",
            "zone": "europe-west1-b",
            "ssh_username": "sshuser",
            "machine_type": "f1-micro"
        }
    ]
}
```
Пример параметров provisioners
```
# Описывает дополнительные действия по настройке необходимого окружения

{
    "provisioners": [
        {
            "type": "shell",
            "script": "scripts/some_script.sh",
            "execute_command": "sudo {{.Path}}"
        }
    ]
}
```
Проверка шаблона Packer
```
$ packer validate ./some_template.json
```
Сборка образа
```
$ packer build some_template.json
```
После сборки образ доступен для установки из консоли управления GCP
## Самостоятельные задания
1. Пример шаблона, принимающий пользовательские переменные
```
{
    "variables": {
        "project_id": null,
        "source_image_family": null,
        "machine_type": "f1-micro",
        "disk_type": "pd-standard",
        "description": "OTUS edu image",
        "network": "default"
    },
    "builders": [
        {
          "type": "googlecompute",
          "project_id": "{{ user `project_id` }}",
          "image_name": "reddit-base-{{timestamp}}",
          "image_family": "reddit-base",
          "source_image_family": "{{ user `source_image_family` }}",
          "zone": "europe-west3-a",
          "ssh_username": "appuser",
          "machine_type": "{{ user `machine_type` }}",
          "disk_size": 10,
          "disk_type": "{{ user `disk_type` }}",
          "image_description": "{{ user `description` }}",
          "network": "{{ user `network` }}",
          "tags": ["puma-server"]
        }
    ],
    "provisioners": [
        {
          "type": "shell",
          "script": "scripts/install_ruby.sh",
          "execute_command": "sudo {{.Path}}"
        },
        {
          "type": "shell",
          "script": "scripts/install_mongodb.sh",
          "execute_command": "sudo {{.Path}}"
        }
    ]
}
```
Стоит отметить, что переменные без определенных значений по-умолчанию является отличным способом использовать секреты.

2. Пример указания переменных в файле
```
{
    "project_id": "some-project-1234",
    "source_image_family": "ubuntu-1604-lts"
}
```
Для использования переменных следует выполнять следующие команды
```
# Переменные без файла
packer build -var "some_var_name=some_value" template.json

# Переменные в отдельном файле
packer buld -var-file="/path/to/variables.json" template.json

```

3. Дополнительные параметры шаблона для GCP VM

Указаны в примере выше. Полный список доступен по [ссылке](https://www.packer.io/docs/builders/googlecompute.html#account_file)
## Задания со *
Подготовка скрипта установки приложения с запуском через systemctl

`packer/files/deploy_puma.sh`

```
#! /bin/sh

# Deploy Reddit App

git clone -b monolith https://github.com/express42/reddit.git /etc/reddit/
cd /etc/reddit && bundle install
adduser puma --disabled-password --gecos ""

# Startup Script

mkdir /usr/local/puma
wget https://gist.githubusercontent.com/razin92/06870f9eb9e448d3bde12b17113e2233/raw/244fbf48a49954c49967ca620d25eda99686bbad/start.sh -O /usr/local/puma/start.sh
chmod +x /usr/local/puma/start.sh

# Service Puma

wget https://gist.githubusercontent.com/razin92/06870f9eb9e448d3bde12b17113e2233/raw/244fbf48a49954c49967ca620d25eda99686bbad/puma.service -O /etc/systemd/system/puma.service
systemctl daemon-reload
systemctl start puma
systemctl enable puma
```
Скрипт запуска приложения для сервиса
```
#! /bin/sh

# Puma startup script

puma --dir /etc/reddit/
```
Cервис приложения Puma
```
[Unit]
Description=Puma

[Service]
Type=simple
User=puma
Group=puma

ExecStart=/usr/local/puma/start.sh
ExecStop=/bin/kill -15 $MAINPID

[Install]
WantedBy=multi-user.target
```
Скрипт создания инстанса из ранее созданного образа
```
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

# Создания инстанса VM с конкретным образом

gcloud compute instances create $instance_name \
--project=$project_id \
--boot-disk-size=10GB \
--image=$image_name \
--image-project=$project_id \
--machine-type=g1-small \
--zone=europe-west3-a \
--tags puma-server \
--restart-on-failure

# С последним созданным образом
# --image=$image_name заменить на --image-family=reddit-full 
```
<a name="HW6"></a>
[Содержание](#top)
# Домашнее задание 6
## Практика IaC с использованием Terraform
### Terraform-1
**Список основных комманд для работы с Terraform** 

[Команды в документации](https://www.terraform.io/docs/cli-index.html)
1. Инициализация проекта 
```
terraform init
```
2. Проверка синтаксиса конфигруционных файлов .tf 
```
terraform validate
```
3. Проверка изменений 
```
terraform plan
```
4. Применение изменений 
```
terraform apply
```
5. Просмотр текущего состояния проекта 
```
terraform show
```
6. Просмотр вывода при настроенной секции `outputs`
```
terraform output
terraform output <переменная>
# terraform output app_external_ip
```
7. Пересоздание ресурса
```
terraform taint <имя ресурса>
# terraform taint google_compute_instance.app
```
8. Удаление всех ресурсов
```
terraform destroy
```
9. Форматирование конфигурационных файлов для повышения "читаемости"
```
terraform fmt
``` 

**Основные секции в конфигурационных файлах**

[Конфигурация в документации](https://www.terraform.io/docs/configuration/index.html)
1. terraform
```
terraform {
    # Описывает конфигурацию самого terraform
    # Например: требуемая версия
    required_version = "0.12.8"
}
```
2. [provider](https://www.terraform.io/docs/providers/index.html)
```
provider "<имя_провайдера>" {
    # Конфигурация используемого провайдера
}

# Пример
provider "google" {
  # Версия провайдера
  version = "2.15.0"
  project = "project-id"
  region  = "europe-west1"
}
```
3. [resource](https://www.terraform.io/docs/configuration/resources.html)
    - [provisioner](https://www.terraform.io/docs/provisioners/index.html)
```
resource "<тип_ресурса>" "<имя_ресурса>" {
    # Описывает конфигурацию ресурса
}
```
```
provisioner "<тип>" {
    # Описывает действия после создания ресурса
    # Является частью конфигурации ресурса
}
# Примеры
# Поставщик типа "файл" копирует файл из локального хранилища в ресурс
provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
}
# Поставщик типа "remote-exec" производит выполенение команды в ресурсе
provisioner "remote-exec" {
    script = "files/deploy.sh"
}
```
***Полный пример ресурсов на примере [GCP](https://www.terraform.io/docs/providers/google/index.html) (Инстанса и Правила брандмауэра)***
```
resource "google_compute_instance" "app" {
  name         = "reddit-app"
  machine_type = "g1-small"
  zone         = var.zone
  tags         = ["reddit-app"]
  boot_disk {
    initialize_params {
      image = var.disk_image
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    # Путь до публичного ключа
    ssh-keys = "appuser:${file(var.public_key_path)})"
  }

  connection {
    type        = "ssh"
    host        = self.network_interface[0].access_config[0].nat_ip
    user        = "appuser"
    agent       = false
    private_key = file(var.private_key_path)
  }

  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }
}

resource "google_compute_firewall" "firewall_puma" {
  name = "allow-puma-default"
  # Сеть, в которй действует правило
  network = "default"
  # Список разрешений
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }
  # Каким адресам рарешается доступ
  source_ranges = ["0.0.0.0/0"]
  # Правило применимо для инстансов с перечисленными тэгами
  target_tags = ["reddit-app"]
}
```
4. [output](https://www.terraform.io/docs/configuration/outputs.html)
```
output "<имя_переменной>" {
  # Выводит выбранные параметры состояния проекта
}

# Пример, внешний IP-адрес инстанса GCP
output "app_external_ip" {
  value = google_compute_instance.app.network_interface[0].access_config[0].nat_ip
}
```
5. [variable](https://www.terraform.io/docs/configuration/variables.html)
```
variable <имя_переменной> {
    # Пользовательская переменная, используемая в проекте
}

# Пример
variable region {
  # Описание переменной
  description = "Region"
  # Значение по умолчанию
  default = "europe-west1"
}

# Пример использования в конфигурации
# var.<имя_переменной>
...
provider "google" {
  # Версия провайдера
  version = "2.15.0"
  project = "project-id"
  region  = var.region # <-- вызов переменной
}
# Переменные без значения по-умолчанию хранятся в файле *.tfvars
```
`*.tfvars.example`
```
project = "your_project_id"
disk_image = "reddit-base"
```
Рекомендуемые файлы для .gitignore
```
*.tfstate
*.tfstate.*.backup
*.tfstate.backup
*.tfvars
.terraform/
```
## Задание со *
Для добавление SSH-ключей в проект необходимо добавить следующую конфигурацию
```
# Метаданные ssh-keys
resource "google_compute_project_metadata" "ssh_keys" {
    metadata = {
    ssh-keys = "appuser1:${file(var.public_key_path)}"
  }
}

# Также для блокировки ssh-ключей внутри инстанса
# Указывается в разделе metadata {} конфигурации инстанса
...
metadata = {
    block-project-ssh-keys = false
  }
...
```
Для указания нескольких ключей стоит указать их в одну строку
```
resource "google_compute_project_metadata" "ssh_keys" {
    metadata = {
    ssh-keys = "appuser1:${file(var.public_key_path)}appuser2:${file(var.public_key_path)}"
  }
}
# или для читаемости
resource "google_compute_project_metadata" "ssh_keys" {
    metadata = {
    ssh-keys = <<EOF
    appuser1:${file(var.public_key_path)}
    appuser2:${file(var.public_key_path)}
    EOF
  }
}
```
**! Внимание**

При применении данных конфигураций из проекта GCP удалятся ключи, созданные вручную (через WEB или утилиту gloud). Поэтому все ключи стоит хранить в конфигурации terraform.
## Задание с **
### Создание балансировщика
Необходимые компоненты для работы балансировщика

Группа инстансов
```
resource "google_compute_instance_group" "app-cluster" {
  name = "app-cluster"
  description = "Reddit-app instance group"
  project = var.project
  # Список инстансов, входящих в группу
  instances = "${google_compute_instance.app.*.self_link}"

  # Именованный порт приложения
  named_port {
    name = "app-http"
    port = "9292"
  }

  zone = var.zone
}
```
Мониторинг доступности ресурсов
```
resource "google_compute_health_check" "app-healthcheck" {
  name = "app-healthcheck"
  check_interval_sec = 1
  timeout_sec = 1
  tcp_health_check {
    port = "9292"
  }
}
```
Бэкенд сервис
```
resource "google_compute_backend_service" "app-backend" {
  name = "app-backend"
  protocol = "HTTP"
  port_name = "app-http"
  timeout_sec = 10

  backend {
    # Группа инстансов
    group = "${google_compute_instance_group.app-cluster.self_link}"
  }
  # Ссылка на мониторинг доступности
  health_checks = ["${google_compute_health_check.app-healthcheck.self_link}"]
}
```
URL-map
```
resource "google_compute_url_map" "app-map" {
  name = "app-map"
  description = "Reddit-app LB"
  # Бекенд-сервис по-умолчанию для неопознанных запросов
  default_service = "${google_compute_backend_service.app-backend.self_link}"

  # Правило перенаправления на бекенд
  host_rule {
    hosts = ["*"]
    path_matcher = "allpaths"
  }

  # Условия срабатывания перенаправления на бекенд
  path_matcher {
    name = "allpaths"
    default_service = "${google_compute_backend_service.app-backend.self_link}"
  }
}
```
Правило перенаправления трафика
```
resource "google_compute_global_forwarding_rule" "app-rule"{
  name       = "app-rule"
  # Все запросы на указанный порт отправляем на Proxy
  target     = "${google_compute_target_http_proxy.app-proxy.self_link}"
  port_range = "80"
}
```
http-proxy для входящего трафика
```
resource "google_compute_target_http_proxy" "app-proxy" {
  name        = "app-proxy"
  # Все принятые запросы перенаправляются на URL-map
  url_map     = "${google_compute_url_map.app-map.self_link}"
}
```
Использование `count` и вынесение количества циклов в переменные позволяет управлять количеством необходимых ресурсов централизованно, также можно гарантировать их идентичность. 

Использование одинаковых приложений, предоставленных для домашней работы, в балансировке применимо только для статичных данных. При работе с динамическими данными, при падении одного из инстансов, вся его база данных будет потеряна для работы. Для корректной балансировки необходимо синхронизировать базы данных всех инстансов.