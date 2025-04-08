# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Базові налаштування для всіх VM
  config.vm.box = "bento/ubuntu-22.04"
  config.ssh.insert_key = false
  
  # SSH-ключ, який буде використовуватись для всіх серверів
  ssh_pub_key = File.readlines("#{Dir.home}/.ssh/id_rsa.pub").first.strip
  
  # Створення трьох SFTP серверів
  (1..3).each do |i|
    config.vm.define "sftp-server-#{i}" do |node|
      node.vm.hostname = "sftp-server-#{i}"
      node.vm.network "private_network", ip: "192.168.33.#{10+i}"
      
      # Налаштування ресурсів VM
      node.vm.provider "virtualbox" do |vb|
        vb.memory = 1024
        vb.cpus = 1
      end
      
      # Скрипт налаштування серверів
      node.vm.provision "shell", inline: <<-SHELL
        # Оновлення системи
        sudo apt-get update
        sudo apt-get upgrade -y
        
        # Встановлення необхідних пакетів
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq openssh-server rkhunter sshpass cron
        
        # Налаштування SSH та SFTP
        sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
        sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
        
        # Створення каталогу .ssh та додавання ключа
        mkdir -p /home/vagrant/.ssh
        echo '#{ssh_pub_key}' > /home/vagrant/.ssh/authorized_keys
        sudo chown -R vagrant:vagrant /home/vagrant/.ssh
        sudo chmod 700 /home/vagrant/.ssh
        sudo chmod 600 /home/vagrant/.ssh/authorized_keys
        
        # Створення каталогу для SFTP файлів
        sudo mkdir -p /srv/sftp
        sudo chown vagrant:vagrant /srv/sftp
        sudo chmod 775 /srv/sftp
        
        # Запуск security audit з rkhunter
        sudo rkhunter --update
        sudo rkhunter --propupd
        sudo rkhunter --check --skip-keypress
        
        # Створення ключів для міжсерверної комунікації
        if [ ! -f /home/vagrant/.ssh/id_rsa ]; then
          sudo -u vagrant ssh-keygen -t rsa -N "" -f /home/vagrant/.ssh/id_rsa
        fi
        
        # Перезапуск SSH
        sudo systemctl restart ssh
      SHELL
    end
  end
  
  # Додаткове налаштування після створення всіх VM для обміну ключами
  config.vm.provision "shell", inline: <<-SHELL
    echo "Всі машини створені. Тепер налаштуємо обмін ключами між ними."
  SHELL
  
  # Налаштування автоматичного обміну ключами між серверами
  config.vm.define "sftp-server-3" do |config|
    config.vm.provision "shell", inline: <<-SHELL
      # Створення скрипту для обміну ключами
      cat > /home/vagrant/exchange_keys.sh << 'EOF'
#!/bin/bash

# Масив усіх серверів для обміну ключами
SERVERS=("192.168.33.11" "192.168.33.12" "192.168.33.13")
MY_IP=$(hostname -I | awk '{print $2}')

# Копіюємо ключ для кожного сервера (крім себе)
for server in "${SERVERS[@]}"; do
  if [ "$server" != "$MY_IP" ]; then
    echo "Копіювання ключа на $server..."
    # Тимчасово дозволяємо автентифікацію по паролю для копіювання ключа
    sshpass -p "vagrant" ssh -o StrictHostKeyChecking=no vagrant@$server "sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config && sudo systemctl restart ssh"
    
    # Копіюємо ключ
    cat /home/vagrant/.ssh/id_rsa.pub | sshpass -p "vagrant" ssh -o StrictHostKeyChecking=no vagrant@$server "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
    
    # Повертаємо безпечні налаштування
    sshpass -p "vagrant" ssh -o StrictHostKeyChecking=no vagrant@$server "sudo sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && sudo systemctl restart ssh"
  fi
done
EOF
      
      # Створення скрипту для запису файлів на сусідні сервери
      cat > /home/vagrant/write_to_sftp.sh << 'EOF'
#!/bin/bash

# Отримуємо ім'я поточного сервера
SERVER_NAME=$(hostname)

# Поточна дата і час
DATETIME=$(date "+%Y-%m-%d %H:%M:%S")

# Масив усіх серверів
SERVERS=("192.168.33.11" "192.168.33.12" "192.168.33.13")
MY_IP=$(hostname -I | awk '{print $2}')

# Створюємо файл на кожному сервері (крім нашого)
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
  fi
done
EOF

      # Налаштування прав на скрипти
      chmod +x /home/vagrant/exchange_keys.sh
      chmod +x /home/vagrant/write_to_sftp.sh
      
      # Запуск скрипту обміну ключами
      sudo -u vagrant /home/vagrant/exchange_keys.sh
      
      # Налаштування cron для запуску скрипту кожні 5 хвилин
      echo "*/5 * * * * /home/vagrant/write_to_sftp.sh" | sudo -u vagrant crontab -
      
      # Копіювання скриптів на інші сервери
      for server in "192.168.33.11" "192.168.33.12"; do
        scp -o StrictHostKeyChecking=no /home/vagrant/write_to_sftp.sh vagrant@$server:/home/vagrant/
        scp -o StrictHostKeyChecking=no /home/vagrant/exchange_keys.sh vagrant@$server:/home/vagrant/
        ssh -o StrictHostKeyChecking=no vagrant@$server "chmod +x /home/vagrant/write_to_sftp.sh /home/vagrant/exchange_keys.sh"
        ssh -o StrictHostKeyChecking=no vagrant@$server "/home/vagrant/exchange_keys.sh"
        ssh -o StrictHostKeyChecking=no vagrant@$server 'echo "*/5 * * * * /home/vagrant/write_to_sftp.sh" | crontab -'
      done
      
      echo "Налаштування завершено. Скрипти будуть виконуватися кожні 5 хвилин."
    SHELL
  end
end