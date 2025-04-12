# 🔐 SFTP Cluster Automation & Logging System

## 🧩 Опис

Цей проєкт реалізує кластер із трьох віртуальних машин з встановленими SFTP-серверами. Кожна машина налаштована для взаємодії з іншими за допомогою SSH-ключів. Автоматичні Bash-скрипти створюють файли на сусідніх вузлах, а Python-аналітика формує звіти на основі логів. Додатково виконано базовий секюріті аудит за допомогою `rkhunter`.

---

## 📦 Структура проєкту

├── Vagrantfile # Опис створення 3 VM ├── provisioning/ │ ├── install_sftp.sh # Інсталяція SFTP і налаштування SSH │ └── setup_cron.sh # Bash-логер і cron task ├── scripts/ │ └── write_to_peers.sh # Скрипт створення файлів на сусідах ├── analyzer/ │ ├── analyzer.py # Python-аналітика логів │ └── Dockerfile # Мінімальний Docker-образ ├── output/ │ └── report.csv # Автоматично сформований звіт └── README.md # Цей файл

markdown
Копіювати
Редагувати

---

## 🚀 Як розгорнути інфраструктуру

### 🔧 Передумови

- [Vagrant](https://www.vagrantup.com/downloads)
- [VirtualBox](https://www.virtualbox.org/)
- Docker (опційно, для запуску аналітики в контейнері)

### 📥 Кроки запуску

1. **Клонувати репозиторій**
   ```bash
   git clone https://github.com/your-repo/sftp-cluster.git
   cd sftp-cluster
Запустити кластер з 3 VM

bash
Копіювати
Редагувати
vagrant up
Підключитися до будь-якої VM

bash
Копіювати
Редагувати
vagrant ssh node1
Перевірити роботу скриптів

bash
Копіювати
Редагувати
cat /var/log/sftp-write.log
🛠 Bash-логер
Скрипт write_to_peers.sh:

запускається кожні 5 хвилин через cron

створює файл на інших 2-х машинах

формат файлу: log_<timestamp>_<hostname>.txt

містить дату, час та ім’я машини

Файл логу: /var/log/sftp-write.log

📊 Python-аналітика логів
📄 Функціонал:
читає всі логи з /var/log/sftp-write.log на кожній машині

агрегує дані: яка машина, з якої IP-адреси, скільки записів зробила

формує звіт у report.csv

⚙️ Запуск у Docker:
bash
Копіювати
Редагувати
cd analyzer
docker build -t log-analyzer .
docker run --rm -v $(pwd)/../output:/output log-analyzer
Результат: output/report.csv

🧪 Безпековий аудит
На кожній машині автоматично встановлено rkhunter. Перевірити лог:

bash
Копіювати
Редагувати
sudo cat /var/log/rkhunter.log
📅 Планувальник (cron)
Для користувача vagrant:

bash
Копіювати
Редагувати
crontab -l
Очікуваний запис:

swift
Копіювати
Редагувати
*/5 * * * * /home/vagrant/write_to_peers.sh >> /var/log/sftp-write.log 2>&1
📈 Формат звіту
report.csv:

Hostname	IP Address	Total Writes
node1	192.168.56.10	42
node2	192.168.56.11	39
node3	192.168.56.12	40
🔧 Troubleshooting
VM не запускається — перевір порти або перезапусти vagrant destroy && vagrant up

Файли не створюються — перевір доступ по SSH між машинами

Cron не працює — перевір журнал sudo grep CRON /var/log/syslog

📚 Корисні посилання
Vagrant Docs

rkhunter Docs

Cron Basics

👨‍💻 Автор:
[Всякий Мирослав Миколайович]
NOC Engineer | Automation Enthusiast
