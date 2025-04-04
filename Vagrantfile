Vagrant.configure("2") do |config|
  ["sftp-server-1", "sftp-server-2", "sftp-server-3"].each_with_index do |name, i|
    config.vm.define name do |vm|
      vm.vm.box = "bento/ubuntu-22.04"
      vm.vm.hostname = name
      vm.vm.network "private_network", ip: "192.168.33.1#{i+1}"

      vm.ssh.insert_key = false
      vm.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "/home/vagrant/.ssh/authorized_keys"

      vm.vm.provision "shell", inline: <<-SHELL
        sudo apt update
        sudo apt install -y openssh-server

        sudo systemctl enable ssh
        sudo systemctl restart ssh

        # Правильні права для SSH-ключа
        sudo chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
        sudo chmod 600 /home/vagrant/.ssh/authorized_keys
      SHELL
    end
  end
end

