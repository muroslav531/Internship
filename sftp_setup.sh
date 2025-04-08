#!/bin/bash

# Отримуємо ім'я поточного сервера
SERVER_NAME=$(hostname)

# Поточна дата і час
DATETIME=$(date "+%Y-%m-%d %H:%M:%S")

# Масив усіх серверів
SERVERS=("192.168.33.11" "192.168.33.12" "192.168.33.13")
MY_IP=$(hostname -I | awk '{print $2}')

# Створюємо файл на кожному сусідньому сервері
for server in "${SERVERS[@]}"; do
  if [ "$server" != "$MY_IP" ]; then
    echo "Запис файлу на $server..."
    
    # Створюємо тимчасовий файл
    TEMP_FILE=$(mktemp)
    echo "Файл створено: $DATETIME" > $TEMP_FILE
    echo "Створено сервером: $SERVER_NAME ($MY_IP)" >> $TEMP_FILE
    
    # Копіюємо файл на віддалений сервер
    REMOTE_FILE="/srv/sftp/message_from_${SERVER_NAME}_$(date +%Y%m%d_%H%M%S).txt"
    scp -o StrictHostKeyChecking=no $TEMP_FILE vagrant@$server:$REMOTE_FILE
    
    # Видаляємо тимчасовий файл
    rm $TEMP_FILE
    
    echo "Файл успішно записано на $server"
  fi
done