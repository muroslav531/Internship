Vagrant.configure("2") do |config|
  config.vm.define "sftp-server" do |s|
    s.vm.box = "bento/ubuntu-22.04"
    s.vm.hostname = "sftp-server"
    s.vm.network "private_network", ip: "192.168.33.10"

    s.ssh.insert_key = false
    s.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "/home/vagrant/.ssh/authorized_keys"

    s.vm.provision "shell", inline: <<-SHELL
      sudo apt update && sudo apt install -y openssh-server
      sudo systemctl enable ssh
      sudo systemctl restart ssh

      sudo sed -i 's/Subsystem sftp .*/Subsystem sftp internal-sftp/' /etc/ssh/sshd_config
      echo 'Match Group sftpusers' | sudo tee -a /etc/ssh/sshd_config
      echo '  ChrootDirectory /home/%u' | sudo tee -a /etc/ssh/sshd_config
      echo '  ForceCommand internal-sftp' | sudo tee -a /etc/ssh/sshd_config
      sudo systemctl restart ssh

      sudo groupadd sftpusers
      sudo usermod -aG sftpusers vagrant

      sudo chown root:root /home/vagrant
      sudo chmod 755 /home/vagrant
    SHELL
  end
end
