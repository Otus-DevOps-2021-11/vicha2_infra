# vicha2_infra
vicha2 Infra repository.
<details><summary>ДЗ№5 Знакомство с облачной инфраструктурой и облачными сервисами.</summary>

## ssh подключение к серверу через bastion одной командой:

```bash
ssh -i ~/.ssh/appuser -A -t appuser@<hop server> ssh -A <target server>
```
## ssh alias
- Редактируем файл ~/.bashrc
    - Добавляем запись - alias someinternalhost='ssh -i ~/.ssh/appuser -A -t appuser@`<hop server`> ssh -A `<target server`>'
- Применяем изменения введя команду source ~/.bashrc
### Подключаемся по алиасу:
```bash
someinternalhost
```
## Подключение к VPN:
```bash
bastion_IP = 62.84.117.86
someinternalhost_IP = 10.128.0.5
```
</details>
<details><summary>ДЗ№6 Основные сервисы Yandex Cloud.</summary>

## Проверка Monolith Reddit
```bash
testapp_IP = 51.250.10.176
testapp_port = 9292
```
## Команда CLI с зупущенным приложением
```bash
yc compute instance create \
  --name reddit-app \
  --hostname reddit-app \
  --memory=4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1604-lts,size=10GB \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --metadata serial-port-enable=1 \
  --metadata-from-file user-data=./startup.yaml \
```
</details>
<details><summary>ДЗ№7 Модели управления инфраструктурой. Подготовка образов с помощью Packer</summary>

## Установка packer
! Для CentOS необходимо добавить линк
```bash
ln -s ./usr/bin/packer packer.io
```
## Запуск сборки образа
! Ошибка - rpc error: code = ResourceExhausted desc = Quota limit vpc.networks.count exceeded
Решается явным указанием в какой подсети создавать ВМ
```bas
"subnet_id": "e9biaaj8adfgadvadj38"
```
! Ошибка - Failed to find instance ip address: instance has no one IPv4 external address
Решение:
```bash
"use_ipv4_nat": true
```
## Параметризирование шаблона
```bash
packer.io build -var-file=./variables.json ./ubuntu16.json
```
Пример variables.json
```
{
    "folder_id": "b1g23edrfglkqcbjbd2osl",
    "subnet_id": "e9bsamfdkwlkhnr1spnj38",
    "source_image_id": "fd8ckm,djedl8qjsmv6mqa5",
    "service_account_key_file": "/user/path/key.json"
}
```
## Построение bake-образа
Создал init файл переместил в /etc/systemd/system
```
packer.io build -var-file=./variables.json ./immutable.json 

[Unit]
Description=Reddit
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/reddit
ExecStart=/usr/local/bin/puma -C /home/ubuntu/reddit/config/deploy/production.rb
PermissionsStartOnly=true

[Install]
WantedBy=multi-user.target
 
```
## Автоматизация создания ВМ
```bash
#!/bin/bash
yc compute instance create \
  --name reddit-app \
  --hostname reddit-app \
  --memory=2 \
  --create-boot-disk image-family=reddit-full,size=10GB \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --metadata serial-port-enable=1 \
  --metadata-from-file user-data=./user.yaml 
```
</details>
 <details><summary>ДЗ№8 Практика IaC с использованием Terraform</summary>

## Установка Terraform на CentOS
```bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform
```
## Создаем сервисный аккаунт
```
https://cloud.yandex.ru/docs/iam/quickstart-sa
https://cloud.yandex.com/en-ru/docs/iam/operations/iam-token/create-for-sa#keys-create
```
## Запускаем создание ВМ через terraform
```bash
terraform apply -auto-approve
```
- Ошибка при выполнении: E: Unable to acquire the dpkg frontend lock (/var/lib/dpkg/lock-frontend), is another process using it?
  - Решение здесь - https://askubuntu.com/questions/1109982/e-could-not-get-lock-var-lib-dpkg-lock-frontend-open-11-resource-temporari
  ```
  sudo rm /var/lib/dpkg/lock*
  ```
## Задание с **
- создаем балансировщик и таргет группу
```
resource "yandex_lb_network_load_balancer" "foo" {
  name = "my-network-load-balancer"

  listener {
      name        = "my-listener"
      port        = 80
      target_port = 9292
      external_address_spec {
          ip_version = "ipv4"
      }
  }
  attached_target_group {
      target_group_id = "${yandex_lb_target_group.foo.id}"

      healthcheck {
          name = "http"
          http_options {
              port = 9292
          }
      }
  }
}

resource "yandex_lb_target_group" "foo" {
name      = "my-target-group"
region_id = "ru-central1"

target {
  subnet_id = var.subnet_id
  address   = "${yandex_compute_instance.app.network_interface.0.ip_address}"
}
}
```
- Добавляем вторую ноду с приложением и подключаем к балансировщику.
  - Неудобно, т.к. много правок в разных файлах!
- Добавлен параметр count (значение задаем через переменную)
- Для реализации блока connection использовалась информация из источника https://www.terraform.io/language/resources/provisioners/connection#the-self-object
- Для реализации блока target в yandex_lb_target_group использовался блок dynamic - https://www.terraform.io/language/expressions/dynamic-blocks#dynamic-blocks
</details>

<details><summary>ДЗ№9 Принципы организации инфраструктурного кода и работа над инфраструктурой в команде на примере Terraform</summary>

## Задание с *
- Создаем Yandex Object Storage для хранения state файла https://cloud.yandex.ru/docs/storage/operations/buckets/create
- Бекенд описан в файле backend.tf
- Инициализация бекенда через параметры командной строки
```bash
terraform init -backend-config="access_key=<your access key>" -backend-config="secret_key=<your secret key>"
```
</details>
<details><summary>ДЗ№10 Управление конфигурацией. Знакомство с Ansible</summary>

### Ansible, установка и настройка клиента на рабочую машину
- Установка PIP
```
yum install epel-release
yum -y update
yum -y install python-pip
pip -V
```
- Установка Ansible
```
sudo yum install ansible -y
ansible --version
```
- Проверка подключения SSH через ansible
- Создание ansible.cfg
- Группируем инвентори
- Установка git
```
ansible app -b -m apt -a 'name=git state=present'
```
- Команда - ansible app -m command -a 'rm -rf ~/reddit' удаляет директорию ~/reddit
Посторное выполнение playbook снова сделает git clone и статус будет changed=1

</details>
<details><summary>ДЗ№11 11_Продолжение знакомства с Ansible: templates, handlers, dynamic, inventory, vault, tags</summary>

## Что сделано
- Выполнены задания - "Один playbook, один сценарий"
- Выполнены задания - "Один плейбук, несколько сценариев"
- Выполнены задания - "Несколько плейбуков"
- Провижининг в Packer
</details>

<details><summary>ДЗ№13 Локальная разработка Ansible ролей с Vagrant. Тестирование конфигурации. </summary>

- Установка Vagrant на Ubuntu
```
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install vagrant
vagrant -v
```
- Создание ВМ через Vagrant
- Задания по методичке

</details>
