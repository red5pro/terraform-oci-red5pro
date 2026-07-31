# Зміни: надійність інсталяційних скриптів (Kafka / Stream Manager / Red5Pro)

Цей файл описує всі зміни, зроблені в одному коміті, щоб ту саму логіку можна
було відтворити в інших terraform-модулях з подібними інсталяційними скриптами.

## Контекст

Клієнт повідомив про дві проблеми з Kafka/Stream Manager:
1. `log.retention.ms=300000` (5 хв) перебивав `log.retention.hours=24` на
   рівні брокера, через що GlobalKTable-топіки втрачали дані.
2. Stream Manager нестабільно піднімався після зупинки/запуску інстансів
   (клієнт періодично вимикає Kafka/SM між подіями та вмикає перед наступною).

Під час подальших реальних прогонів `terraform apply` виявилися ще кілька
класів проблем в самих install-скриптах: приховані apt-помилки, витік
секретів у консоль Terraform, IPv6-роутинг без IPv6 у VCN, DNS ще не готовий
одразу після boot, і логічний баг у retry-циклі pull Docker-образів.

## Змінені файли

- `main.tf`
- `red5pro-installer/kafka.service`
- `red5pro-installer/r5p_kafka_install.sh`
- `red5pro-installer/r5p_install_server_basic.sh`
- `red5pro-installer/r5p_install_sm2_oci.sh`

## Перелік змін (за категоріями)

### 1. Виправлення бага з retention Kafka
- Прибрано `set_config log.retention.ms 300000` з `r5p_kafka_install.sh` —
  це значення (5 хв) перебивало `log.retention.hours=24` на рівні брокера і
  ламало GlobalKTable bootstrap для топіків, що не мають `cleanup.policy=compact`.

### 2. Надійність systemd-юніта Kafka (`kafka.service`)
- `Restart=on-abnormal` → `Restart=on-failure` (перезапуск і при звичайних
  ненульових кодах виходу, не лише при "abnormal" завершеннях).
- Додано `StartLimitIntervalSec=60` (у `[Unit]`) та `StartLimitBurst=3` (у
  `[Service]`) — захист від нескінченного циклу рестартів при поламаному
  конфігу.
- `User=root` → `User=kafka` (окремий системний користувач, без прав root).

### 3. Приховування секретів з виводу `terraform apply` (`main.tf`)
- До всіх `sudo tee -a ...` команд, які пишуть у консоль приватні ключі,
  сертифікати та SASL-паролі (HTTPS keystore/privkey, Kafka SSL
  keystore/truststore/certificate chain, `sasl.jaas.config` з паролями,
  Stream Manager `KAFKA_SSL_*`), додано `>/dev/null`, щоб вміст не
  потрапляв у stdout, який стрімиться в консоль Terraform.
- Несекретні рядки (`advertised.listeners`, `KAFKA_REPLICAS`, `KAFKA_IP`,
  `TRAEFIK_*`, `AS_ADMIN_UI_*`) залишені видимими навмисно — для контролю
  процесу інсталяції.
- `user_data` cloud-init блок не чіпали: він виконується на інстансі і не
  стрімиться в консоль Terraform, тому там секрети не витікають.

### 4. Форсування IPv4 для apt (усі три install-скрипти)
- Причина: OCI VCN без IPv6 CIDR, а DNS-резолвінг іноді повертає IPv6-адреси
  для `archive.ubuntu.com`/`security.ubuntu.com`, що дає
  `Network is unreachable` і зависання apt.
- Додано `echo 'Acquire::ForceIPv4 "true";' >/etc/apt/apt.conf.d/99force-ipv4`
  перед першим викликом apt у кожному скрипті
  (`force_apt_ipv4()` в kafka-скрипті, інлайн в двох інших).

### 5. Очікування готовності DNS перед apt (усі три install-скрипти)
- Причина: SSH піднімається раніше, ніж `systemd-resolved` встигає
  отримати адресу внутрішнього DNS-резолвера OCI VCN по DHCP — перші
  спроби apt можуть впасти з `Temporary failure resolving`.
- Додано функцію `wait_for_dns()`: цикл до 90 сек, перевірка
  `getent hosts archive.ubuntu.com` кожні 2 сек; якщо DNS не піднявся —
  попередження в лог і продовження (не блокує назавжди).
- Викликається одразу перед `force_apt_ipv4`/першим apt-викликом.

### 6. Придушення шуму `needrestart` (усі три install-скрипти)
- Додано `export NEEDRESTART_SUSPEND=1` поруч з `DEBIAN_FRONTEND=noninteractive`.
- Прибирає лише прогрес-бар "Scanning processes..." та пропозиції
  перезапуску сервісів; решта виводу apt лишається видимою.
- У `r5p_install_sm2_oci.sh` заразом додано відсутній раніше
  `export DEBIAN_FRONTEND=noninteractive`.

### 7. Видима діагностика помилок + retry-логіка (`r5p_kafka_install.sh`)
- `install_pkg()`: прибрано `&>/dev/null` придушення apt-помилок (раніше
  ховало справжню причину, чому `ripgrep`/`kafkacat` не встановлюються);
  додано `|| true` там, де це очікувана частина retry-циклу під
  `set -euo pipefail`.
- `install_jdk()`: обгорнуто в цикл до 5 спроб з паузою 20 сек замість
  одноразового виконання без обробки помилок.
- `download_kafka_archive()`: прибрано `wget -q` (ховав причину збою
  завантаження); додано 5 спроб з паузою 15 сек; перед кожним retry
  видаляється частково завантажений файл (`rm -f kafka_*.tgz`), щоб wget
  не створював дублікати з суфіксом `.1`.

### 8. Виправлення логічного бага в pull Docker-образів (`r5p_install_sm2_oci.sh`)
- `pull_docker_images()`: раніше після невдалої тихої спроби скрипт
  повторював `docker compose pull` **без придушення виводу**, але потім
  безумовно робив `exit 1` — навіть якщо повторна спроба фактично
  завантажила всі образи успішно. Тепер результат retry перевіряється
  реально, і `exit 1` спрацьовує лише при справжній невдачі.

### 9. Харденінг встановлення Kafka (`install_kafka()` в `r5p_kafka_install.sh`)
- Створення окремого системного користувача `kafka`
  (`useradd --system --no-create-home --shell /usr/sbin/nologin`).
- `chown -R kafka:kafka` на `/usr/local/kafka` і лог-директорію,
  `chmod -R 750` на лог-директорію, `chmod 600` на конфіг-файл (замість
  попереднього `chmod 777`).
- Явна перевірка помилок на кожному кроці (`tar -xzvf`, `mv`,
  `kafka-storage.sh format`) замість мовчазного продовження при збої.
- `set_config()`: значення екранується (`sed -e 's/[\&|]/\\&/g'`) перед
  підстановкою в `sed`, щоб спецсимволи (`&`, `|`) у значенні не ламали
  заміну.
- `check_memory_requirements()` та `check_not_already_installed()`
  винесені в окремі функції та викликаються на самому початку скрипту —
  раніше перевірка пам'яті була в кінці `install_kafka()`, вже після
  завантаження й розпакування архіву.

### 10. Загальна безпека виконання скрипту
- `r5p_kafka_install.sh`: додано `set -euo pipefail` на початку файлу
  (усі retry-цикли адаптовано під це — `|| true`, перевірка через
  `if CMD; then ... fi` замість `CMD; if [ $? -ne 0 ]`).

## Чекліст для застосування цих же змін в інших terraform-модулях

Якщо в іншому terraform-модулі є подібні install-скрипти (apt + systemd +
remote-exec провіжинери), перевірити й за потреби застосувати:

- [ ] Секрети з `tee`/`echo` у `remote-exec inline` — чи не стрімляться у
      консоль Terraform без `>/dev/null`.
- [ ] `Acquire::ForceIPv4` перед першим apt-викликом (OCI VCN без IPv6).
- [ ] `wait_for_dns()` перед першим apt-викликом (DNS може бути не готовий
      одразу після boot).
- [ ] `NEEDRESTART_SUSPEND=1` поруч з `DEBIAN_FRONTEND=noninteractive`.
- [ ] Чи не приховують `&>/dev/null`/`-q` реальну причину помилки apt/wget —
      прибрати або залишити retry з видимим виводом на останній спробі.
- [ ] `systemd`-юніти: `Restart=on-failure` + `StartLimitIntervalSec`/
      `StartLimitBurst`, окремий непривілейований `User=` замість root.
- [ ] Виділений системний користувач для сервісу + `chown`/`chmod` замість
      `777`.
- [ ] Retry-блоки з безумовним `exit 1` після повторної спроби — перевірити,
      чи результат retry дійсно перевіряється, а не ігнорується.
- [ ] `set -euo pipefail` — і чи всі retry/best-effort команди мають
      відповідні `|| true` guard'и.
