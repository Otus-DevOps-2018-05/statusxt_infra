[![Build Status](https://travis-ci.com/Otus-DevOps-2018-05/statusxt_infra.svg?branch=master)](https://travis-ci.com/Otus-DevOps-2018-05/statusxt_infra)

# statusxt_infra
statusxt Infra repository

# Table of content
- [Homework-03 GCP-1](#homework-03-gcp-1)
- [Homework-04 GCP-2](#homework-04-gcp-2)
- [Homework-05 Packer](#homework-05-packer)
- [Homework-06 Terraform-1](#homework-06-terraform-1)
- [Homework-07 Terraform-2](#homework-07-terraform-2)
- [Homework-08 Ansible-1](#homework-08-ansible-1)

# Homework 03 GCP-1

## 3.1 Задание с 35 слайда

- Способ подключения к someinternalhost в одну команду:
ssh -i ~/.ssh/appuser2 -A appuser@35.206.144.111 ssh 10.132.0.3
- Вариант решения для подключения из консоли при помощи команды вида ssh
someinternalhost из локальной консоли рабочего устройства:
```
touch ~/.ssh/config
nano ~/.ssh/config
	Host someinternalhost
		HostName 10.132.0.3
		User appuser
		ProxyCommand ssh -W %h:%p -i ~/.ssh/appuser appuser@35.206.144.111
ssh someinternalhost
```

## 3.2 Файлы

- setupvpn.sh - установка VPN сервера

- cloudbastion.ovpn - конфиг для подключения клиента

## 3.3 Конфигурация

bastion_IP = 35.206.144.111

someinternalhost_IP = 10.132.0.3

# Homework 04 GCP-2

```
gcloud compute instances create reddit-app-2\
 --boot-disk-size=10GB \
 --image-family ubuntu-1604-lts \
 --image-project=ubuntu-os-cloud \
 --machine-type=g1-small \
 --tags puma-server \
 --metadata-from-file startup-script=/root/statusxt_infra/startup.sh \
 --restart-on-failure
```
```
gcloud compute firewall-rules create "default-puma-server"\
 --allow tcp:9292 \
 --source-ranges=0.0.0.0/0 \
 --target-tags=puma-server
```
testapp_IP = 35.187.70.142

testapp_port = 9292

# Homework 05 Packer

## 5.1 Что было сделано

- установлен packer
- создан ADC
- создан и проверен packer template ubuntu16.json
- параметризован созданный шаблон
- исследованы другие опции builder для GCP: Описание образа, Размер и тип диска, Название сети, Теги

В рамках задания со *:
- создан шаблон immutable.json для создания образа с "запеченным" приложением
- создан shell-скрипт для запуска VM из этого образа

## 5.2 Как запустить проект
### 5.2.1 Base
Предполагается, что все действия происходят в каталоге `packer`:
- проверить шаблон и запустить build:
```
packer validate ./ubuntu16.json
packer build -var-file=variables.json ubuntu16.json
```

### 5.2.2 *

Предполагается, что все действия происходят в каталоге `packer`:
- проверить шаблон и запустить build:
```
packer validate ./immutable.json
packer build -var-file=variables.json immutable.json
```
- запустить скрипт по созданию VM в GCP из шаблона:
```
../config-scripts/create-reddit-vm.sh
```

## 5.3 Как проверить

- перейти в GCP (https://console.cloud.google.com), Compute engine -> instances, в списке будет присуствовать созданный экземпляр и его внешний адрес
- открыть в браузере http://<внешний_адрес_экземпляра>:9292

# Homework 06 Terraform-1

## 6.1 Что было сделано

- установлен terraform
- создана конфигурация инфраструктуры (1 gcp instance)
- в конфигурацию добвлено firewall rule
- добавлены provisioners для установки тестового приложения
- добавлены входные переменные, пример файла с переменными - terraform.tfvars.example
- добавлены выходные переменные
- в рамках самостоятельного задания определены переменные private_key_path и compute_zone

В рамках задания со *:
- добавлен ресурс google_compute_project_metadata_item для опередения ssh ключей всего проекта
- в метаданные проекта добавлены ключи для пользователей appuser1, appuser2
- через webui добавлен ключ в метаданные проекта для пользователя appuser-web, терраформ его удалит. Для обеспечения идемпотентности необходимо добавлять ключи через терраформ.

В рамках задания с **:
- в файле lb.tf описано создание http балансировщика, в output переменные добавлен адрес балансировщика
- добавлен еще один инстанс, его адрес добавлен в балансировщик. Проблемы - у каждого инстанса приложения своя БД, необходимость следить за конфиграцией обоих инстансов по отдельности и добавлять их адреса в lb.
- в описание инфраструктуры добавлен параметр count ресурса compute_instance для изменения количества инстансов, в балансировщик добавлены все инстансы. Проблема с тем, чтобы следить за конфигурациями инстансов по-отдельности, решена.

## 6.2 Как запустить проект
### 6.2.1 Base
Предполагается, что все действия происходят в каталоге `terraform`:
```
terraform apply
```

### 6.2.2 *

```
terraform apply
```
### 6.2.3 **

```
terraform apply
```

## 6.3 Как проверить

- открыть в браузере http://<внешний_адрес_экземпляра>:9292
- перейти в GCP (https://console.cloud.google.com), Compute engine -> metadata, в списке ssh ключей будут присуствовать appuser1 appuser2
- открыть в браузере http://<внешний_адрес_балансировщика>:9292

# Homework 07 Terraform-2

## 7.1 Что было сделано

- определены ресурсы фаервола
- импортирована конфигурация из gcp
- конфиг main.tf разбит на несколько конфигов - app.tf, db.tf, vpc.tf
- созданы модули app, db, vpc
- созданы инфраструктуры stage и prod, используюшие модули app, db, vpc
- описано создание storage-bucket с использованием соответствующего модуля из registry

В рамках задания со *:
- настроено хранение стейт файла в удаленном бекенде (remote backends) для окружений stage и prod с использованием Google Cloud Storage в качестве бекенда, бекенд описан в backend.tf
- в модуль app добавлено описание provisioner для деплоя приложения - запуск скрипта деплоя, определение переменной окружения DATABASE_URL для сервиса puma
- в модуль db добавлено описание provisioner для изменения конфига mongod - изменение прослушиваемого адреса
- реализовано отключение provisioner в модуле app - через переменную app_provisioner_toggle ресурса null_resource


## 7.2 Как запустить проект
### 7.2.1 Base
в каталоге `terraform\prod`:
```
terraform apply
```

### 7.2.2 *

```
terraform apply
```

## 7.3 Как проверить

- открыть в браузере http://app_external_ip:9292 , ошибки об отсутствии подключения к db быть не должно

# Homework 08 Ansible-1

## 8.1 Что было сделано

- установлен Ansible через pip
- заданы параметры в ansible.cfg
- создан inventory с группами хостов, проверена работа ansible
- создан inventory.yml, проверен
- создан простой плейбук clone.yml для клонирования репозитория
- репозиторий будет клонирован, только если целевой каталог не существует, в результате выполнения команды это будет отражено в строке "changed=1", в противном случае "changed=0"

## 8.2 Как запустить проект
### 8.2.1 Base
- в каталоге `ansible`:
```
ansible-playbook clone.yml
```

## 8.3 Как проверить

- в каталоге `ansible`:
```
ansible app -m systemd -a name=puma
```
