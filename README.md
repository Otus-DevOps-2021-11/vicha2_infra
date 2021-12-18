# vicha2_infra
vicha2 Infra repository.
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
