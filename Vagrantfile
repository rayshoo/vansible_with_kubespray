# -*- mode: ruby -*-
# vi: set ft=ruby :
def set_vbox(vb, config, os_image)
  vb.gui = false
  vb.memory = 2048

  case os_image
  when :centos7
    config.vm.box = "bento/centos-7.8"
    #config.vm.box_version = "1809.01"
  when :ubuntu16
    config.vm.box = "bento/ubuntu-16.04"
  when :ubuntu20
    config.vm.box = "ubuntu/focal64"
  end
end

Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox"
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.env.enable # enable the plugin
  os_image = (ENV['os_image'] || "ubuntu16").to_sym
  master = (ENV['master'] || 3).to_i
  worker = (ENV['worker'] || 1).to_i
  
  network_address = ENV['network_address'] || "192.168.35."
  min_address = (ENV['initial_address'] || 10).to_i
  private_count = 0

  root_passwd = ENV['root_passwd']

  (1..(master + worker)).each do |machine|
    name = (machine <= master) ? "m" : "w"
    id   = (machine <= master) ? machine : (machine - master)
    id   = (id <= 10) ? "0#{id}" : "#{id}"

    config.vm.define "#{name}#{id}" do |n|
      # print "#{name}#{id}"
      n.vm.host_name = "#{name}#{id}"
      machine_address = min_address + private_count
      ip_addr = "#{network_address}#{machine_address}"
      n.vm.network :private_network, ip: "#{ip_addr}", auto_config: true, virtualbox__intnet: "NatNetwork"
      
      n.vm.provider :virtualbox do |vb, override|
        vb.name = "#{n.vm.hostname}"
        set_vbox(vb, override, os_image)
        vb.cpus = (machine <= master) ? 2 : 1
      end
      private_count += 1
      n.vm.provision :shell, path: "./provision/bootstrap.sh", env: {"root_passwd" => root_passwd}
      n.vm.provision "file", source: "./provision/Ansible_env_ready.yaml", destination: "Ansible_env_ready.yaml"
      n.vm.provision "shell", inline: "ansible-playbook Ansible_env_ready.yaml"
    end
  end
end