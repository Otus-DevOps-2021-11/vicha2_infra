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
testapp_IP = 62.84.114.234
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
