# -*- mode: ruby -*-
# vi: set ft=ruby :
def set_vbox(vb, config, os_image)
  vb.gui = false
  vb.memory = 2048

  case os_image
  when :centos7
    config.vm.box = "bento/centos-7.8"
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
  os_image = (ENV['os_image'] || "ubuntu20").to_sym
  master = (ENV['master'] || 3).to_i
  worker = (ENV['worker'] || 2).to_i
  total_node = master + worker
  
  network_address = ENV['network_address'] || "192.168.35."
  min_address = (ENV['initial_address'] || 10).to_i
  max_address = min_address + master + worker - 1
  private_count = 0

  (1..(master + worker)).each do |machine|
    name = (machine <= worker) ? "w" : "m"
    id   = (machine <= worker) ? (worker - machine + 1) : (total_node - machine + 1)
    id   = (id <= 10) ? "0#{id}" : "#{id}"

    config.vm.define "#{name}#{id}" do |n|
      n.vm.host_name = "#{name}#{id}"
      machine_address = max_address - private_count
      ip_addr = "#{network_address}#{machine_address}"
      n.vm.network :private_network, ip: "#{ip_addr}", auto_config: true, virtualbox__intnet: "NatNetwork"
      
      n.vm.provider :virtualbox do |vb, override|
        vb.name = "#{n.vm.hostname}"
        set_vbox(vb, override, os_image)
        vb.cpus = (machine <= worker) ? 1 : 2
      end
      if machine == (master + worker)
        n.vm.provision :shell, path: "provision/bootstrap.sh"
        n.vm.provision "file", source: "provision/Ansible_env_ready.yaml", destination: "Ansible_env_ready.yaml"
        n.vm.provision "shell", inline: "ansible-playbook Ansible_env_ready.yaml"
        n.vm.provision "shell", path: "provision/add_ssh_auth.sh", privileged: false
      end
      private_count += 1
    end
  end
end