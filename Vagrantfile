# -*- mode: ruby -*-
# vi: set ft=ruby :

$update_script = <<SCRIPT
  apt update
  apt upgrade -y
SCRIPT

$install_chef_server = <<SCRIPT
SCRIPT

$install_chef_client = <<SCRIPT
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  config.hostmanager.enabled = false
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false
  config.ssh.forward_agent = true

  # config.vm.network "forwarded_port", guest: 80, host: 8080, 
  #   auto_correct: true

  config.vm.define :workstation do |workstation|
    workstation.vm.provider "virtualbox" do |vb|
      vb.cpus = "1"
      vb.memory = "4096"
    end
    workstation.vm.hostname = "chef-workstation"
    workstation.vm.network :private_network, ip: "10.211.55.200"
    workstation.vm.provision :hostmanager
    workstation.vm.provision :shell, :inline => $update_script
    workstation.vm.provision :shell, inline: <<-SHELL
      sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
      sudo service ssh restart
    SHELL
    workstation.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "~/.ssh/me.pub"
    workstation.vm.provision "shell", inline: <<-SHELL
      cat /home/vagrant/.ssh/me.pub >> /home/vagrant/.ssh/authorized_keys
    SHELL
  end
  

  config.vm.define :server do |server|
    server.vm.provider "virtualbox" do |vb|
      vb.cpus = "1"
      vb.memory = "4096"
    end
    server.vm.hostname = "chef-server"
    server.vm.network :private_network, ip: "10.211.55.201"
    server.vm.provision :hostmanager
    server.vm.provision :shell, :inline => $update_script
    server.vm.provision :shell, inline: <<-SHELL
      sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
      sudo service ssh restart
    SHELL
    server.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "~/.ssh/me.pub"
    server.vm.provision "shell", inline: <<-SHELL
      cat /home/vagrant/.ssh/me.pub >> /home/vagrant/.ssh/authorized_keys
    SHELL
  end

  config.vm.define :node do |node|
    node.vm.provider "virtualbox" do |vb|
      vb.cpus = "1"
      vb.memory = "1024"
    end
    node.vm.hostname = "chef-client"
    node.vm.network :private_network, ip: "10.211.55.202"
    node.vm.provision :hostmanager
    node.vm.provision :shell, :inline => $update_script
    node.vm.provision :shell, inline: <<-SHELL
      sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
      sudo service ssh restart
    SHELL
    node.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "~/.ssh/me.pub"
    node.vm.provision "shell", inline: <<-SHELL
      cat /home/vagrant/.ssh/me.pub >> /home/vagrant/.ssh/authorized_keys
    SHELL
  end
end
