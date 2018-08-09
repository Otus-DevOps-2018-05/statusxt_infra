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
- [Homework-09 Ansible-2](#homework-09-ansible-2)
- [Homework-10 Ansible-3](#homework-10-ansible-3)
- [Homework-10 Ansible-4](#homework-11-ansible-4)

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

# Homework 09 Ansible-2

## 9.1 Что было сделано

- создан плейбук с одним сценарием для настройки всех инстансов
- создан плейбук с отдельными сценариями для каждого инстанса
- один плейбук разбит на несколько - app.yml, db.yml, deploy.yml
- создан главный плейбук site.yml, вызывающий плейбуки app.yml, db.yml, deploy.yml

В рамках задания со *:
- настроено использование dynamic inventory с использованием gce.py 
- в плейбуках указаны теги инстансов GCP для работы через dynamic inventory

Изменен провижининг в Packer:
- cозданы плейбуки ansible/packer_app.yml и ansible/packer_db.yml, в них описаны действия, аналогичные bash скриптам
- заменены секции Provision в образах packer/app.json, packer/db.json
- конфигурирование и деплой приложения проверны c помощью плейбука site.yml 


## 9.2 Как запустить проект
### 9.2.1 Base
в корне репозитория:
```
cd terraform/stage && terraform apply
cd ../../ansible && ansible-playbook site.yml
cd ../terraform/stage && terraform destroy
```

### 9.2.2 *
в корне репозитория:
```
cd terraform/stage && terraform apply
cd ../../ansible && ansible-playbook site.yml
cd ../terraform/stage && terraform destroy
```
### 9.2.3 Packer
в корне репозитория:
```
packer build -var-file=packer/variables.json packer/app.json
packer build -var-file=packer/variables.json packer/db.json
cd terraform/stage && terraform apply
cd ../../ansible && ansible-playbook site.yml
```

## 9.3 Как проверить

- открыть в браузере http://app_external_ip:9292 , ошибки об отсутствии подключения к db быть не должно

# Homework 10 Ansible-3

## 10.1 Что было сделано

- созданы структуры ролей app и db с помощью ansible-galaxy init
- в роли перенесены tasks, handlers, templates, files из плейбуков ansible/app.yml и ansible/db.yml
- переменные по умолчанию из шаблонов определены в /roles/xxx/defaults/main.yml
- в плейбуки ansible/app.yml и ansible/db.yml добавлены вызовы соответсвующих ролей, работа ролей проверена
- в ansible/environments созданы две директории для окружений stage и prod
- inventory файл перенесен в директории окружений, в ansible/ansible.cfg определен inventory по умолчанию из stage
- переменные, определенные в плейбуках, перенесены в stage/group_vars/, в файлы с названиями, совпадающими с названиями групп хостов, для которых эти переменные определяются
- настроен вывод информации об окружении с помощью модуля debug и переменной env
- все плейбуки перенесены в отдельную директорию согласно best practices, файлы из предидущих дз перенесены в директорию old, в папке ansible из файлов остается
только ansible.cfg и requirements.txt
- настрока обоих окружений проверена
- созданы файлы environments/stage/requirements.yml и environments/prod/requirements.yml, в них добавлена комьюнити роль jdauphant.nginx и установлена через ansible-galaxy install
- переменные для работы роли добавлены в переменные в stage/group_vars/app и prod/group_vars/app
- в конфигурацию терраформа добавлено открытие 80 порта для инстанса приложения
- в плейбук app.yml добавлен вызов роли jdauphant.nginx
- плейбук site.yml применен для окружения stage, приложение теперь доступно на 80 порту
- создан плейбук для создания пользователей users.yml, файлы с данными пользователей для каждого окружения credentials.yml, зашифрованные с помощью vault.key
- вызов плейбука users.yml добавлен в файл site.yml, работа проверена, пользователи созданы

В рамках задания со *:
- настроено использование dynamic inventory с использованием gce.py, gce.ini свой для каждого окружения, файл с групповыми переменными переименованы в tag_reddit-..
- в плейбуках указаны теги инстансов GCP для работы через dynamic inventory

В рамках задания с **:
- travisci настроен для я контроля состояния инфраструктурного репозитория - packer validate для всех шаблонов, terraform validate и tflint для окружений stage и prod, ansible-lint для плейбуков ansible
- в README.md добавлен бейдж с статусом билда


## 10.2 Как запустить проект
### 10.2.1 Base
в корне репозитория:
```
cd terraform/stage && terraform apply
cd ../../ansible && ansible-playbook playbooks/site.yml
cd ../terraform/stage && terraform destroy
```

### 10.2.2 *
в корне репозитория:
```
cd terraform/stage && terraform apply
cd ../../ansible && ansible-playbook playbooks/site.yml
cd ../terraform/stage && terraform destroy
```

## 10.3 Как проверить

- открыть в браузере http://app_external_ip , ошибки об отсутствии подключения к db быть не должно

# Homework 11 Ansible-4

## 11.1 Что было сделано

Текущее окружение - WSL
- установлен virtualbox (windows), каталог добавлен в PATH
- установлен vagrant, добавлены переменные среды:
```
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"
export PATH="$PATH:/mnt/c/Program Files/Oracle/VirtualBox"
export PATH="$PATH:/mnt/c/Windows/System32"
export PATH="$PATH:/mnt/c/Windows/System32/WindowsPowerShell/v1.0"
```
- создан vagrantfile, в нем описаны ВМ
- для работы в WSL в vagrantfile добавлено отключение serial port:
```
  config.vm.provider "virtualbox" do |vb|
    vb.customize [ "modifyvm", :id, "--uartmode1", "disconnected" ]
  end
```
- в vagrantfile добавлен provision "ansible", в site.yml добавлена установка питона с использование raw модуля (base.yml)
- в роли app и db добавлены таски из packer_app и packer_db, к таскам добавлены теги, таски в нужном порядке вызываются из main.yml
- конфигурация параметризована, чтобы мы могли использовать ее для пользователя другого, чем appuser - {{ deploy_user }}. Переменная определяется в ansible.extra_vars vagrantfile

В рамках задания со *:
- конфигурация Vagrant дополнена для корректной работы проксирования приложения с помощью nginx 

В рамках задания "Тестирование роли":
- через pip install -r requirements.txt установлены molecule, testinfra, python-vagrant
- molecule init - созданы заготовки тестов для роли db
- добавлены тесты в db/molecule/default/tests/test_default.py 
- в molecule.yml добавлен параметр для работы через wsl:
```
raw_config_args:
  - "customize ['modifyvm', :id, '--uartmode1', 'disconnected']"
```
- в плейбук молекулы db/molecule/default/playbook.yml добавлены "become: true" и переменная mongo_bind_ip
- в плейбуках packer_db.yml и packer_app.yml использованы роли db и app, в шаблонах пакера использованы теги для запуска нужных таксов, в секцию провиженера в шаблонах добавлено определение переменной:
```
"ansible_env_vars": [
    "ANSIBLE_ROLES_PATH=./roles:~/projects/andywow_infra/ansible/roles"
]
```

## 11.2 Как запустить проект
### 11.2.1 Base
в корне репозитория:
```
cd ansible && vagrant up
vagrant destroy -f
```

### 11.2.2 *
в корне репозитория:
```
cd ansible && vagrant up
vagrant destroy -f
```

### 11.2.3 Тестирование роли
в корне репозитория:
```
cd ansible/roles/db && molecule create
molecule converge
molecule verify
```

## 11.3 Как проверить
- открыть в браузере http://http://10.10.10.20
- molecule verify - тесты должны пройти успешно
