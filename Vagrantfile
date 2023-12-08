# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "debian/buster64"

  #######################
  ###   Balanceador   ###
  #######################

  config.vm.define "balanceadorAbelGC" do |bal|
    bal.vm.hostname = "balanceadorAbelGC"
    # Red aislada
    bal.vm.network "private_network", ip: "10.0.10.10",
      virtualbox_intnet: "red10"
    # Nuestro puerto de entrada
    bal.vm.network "forwarded_port", guest: 80, host:9090
    # Script de provisionamiento para que se ejecute siempre
    bal.vm.provision "shell", path: "balanceadorAbelGC.sh",
      run: "always"
    # Para solucionar problemas con los DNS:
    bal.vm.provider "virtualbox" do |vb|
      vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    end
  end

  #######################
  ###    ServerNFS    ###
  #######################

  config.vm.define "serverNFSAbelGC" do |nfs|
    nfs.vm.hostname = "serverNFSAbelGC"
    nfs.vm.network "private_network", ip: "172.16.0.100",
      virtualbox_intnet: "red172"
    nfs.vm.provision "shell", path: "serverNFSAbelGC.sh",
      run: "always"
    nfs.vm.provider "virtualbox" do |vb|
      vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    end
  end

  #######################
  ###   ServerWeb1    ###
  #######################

  config.vm.define "serverweb1AbelGC" do |sw1|
    sw1.vm.hostname = "serverweb1AbelGC"
    sw1.vm.network "private_network", ip: "10.0.10.101",
      virtualbox_intnet: "red10"
    sw1.vm.network "private_network", ip: "172.16.0.101",
      virtualbox_intnet: "red172"
    sw1.vm.provision "shell", path: "serverweb1AbelGC.sh",
      run: "always"
    sw1.vm.provider "virtualbox" do |vb|
      vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    end
  end

  #######################
  ###   ServerWeb2    ###
  #######################

  config.vm.define "serverweb2AbelGC" do |sw2|
    sw2.vm.hostname = "serverweb2AbelGC"
    sw2.vm.network "private_network", ip: "10.0.10.102",
      virtualbox_intnet: "red10"
    sw2.vm.network "private_network", ip: "172.16.0.102",
      virtualbox_intnet: "red172"
    sw2.vm.provision "shell", path: "serverweb2AbelGC.sh",
      run: "always"
    sw2.vm.provider "virtualbox" do |vb|
      vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    end
  end

  #######################
  ###   ProxyBBDD     ###
  #######################

  config.vm.define "proxyBBDDAbelGC" do |pbd|
    pbd.vm.hostname = "proxyBBDDAbelGC"
    pbd.vm.network "private_network", ip: "172.16.0.200",
      virtualbox_intnet: "red172"
    pbd.vm.network "private_network", ip: "192.168.20.200",
      virtualbox_intnet: "red192"
    pbd.vm.provision "shell", path: "proxyBBDDAbelGC.sh",
      run: "always"
    pbd.vm.provider "virtualbox" do |vb|
      vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    end
  end

  #######################
  ###  Serverdatos1   ###
  #######################

  config.vm.define "serverdatos1AbelGC" do |sd1|
    sd1.vm.hostname = "serverdatos1AbelGC"
    sd1.vm.network "private_network", ip: "192.168.20.201",
      virtualbox_intnet: "red192"
    sd1.vm.provision "shell", path: "serverdatos1AbelGC.sh",
      run: "always"
    sd1.vm.provider "virtualbox" do |vb|
      vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    end
  end

  #######################
  ###  Serverdatos2   ###
  #######################

  config.vm.define "serverdatos2AbelGC" do |sd2|
    sd2.vm.hostname = "serverdatos2AbelGC"
    sd2.vm.network "private_network", ip: "192.168.20.202",
      virtualbox_intnet: "red192"
    sd2.vm.provision "shell", path: "serverdatos2AbelGC.sh",
      run: "always"
    sd2.vm.provider "virtualbox" do |vb|
      vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    end
  end

end
