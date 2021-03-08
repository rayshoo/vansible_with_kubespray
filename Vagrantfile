# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.provider :virtualbox do |vb|
    vb.name = "k8s-master"
  end
  config.vm.box = "ubuntu/focal64"
  config.vm.hostname = "master"
  config.vm.network :private_network, ip: "192.168.33.10"
end