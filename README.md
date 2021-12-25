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
 