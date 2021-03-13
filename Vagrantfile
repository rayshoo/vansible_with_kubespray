# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox"
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.env.enable # enable the plugin
  os_image = (ENV['OS_IMAGE'] || "ubuntu20").to_sym
  master = (ENV['MASTER'] || 3).to_i
  worker = (ENV['WORKER'] || 2).to_i
  total_node = master + worker
  master_node_name = ENV['MASTER_NODE_NAME'] || "m"
  worker_node_name = ENV['WORKER_NODE_NAME'] || 'w'
  
  network_address = ENV['NETWORK_ADDRESS'] || "192.168.35."
  min_address = (ENV['MIN_ADDRESS'] || 10).to_i
  max_address = min_address + total_node - 1
  min_host_port = (ENV['MIN_HOST_PORT'] || 19210).to_i
  max_host_port = min_host_port + total_node - 1

  host_file_text = "nodes: \""
  ansible_host_file_text = ""
  ssh_auth_text = "#!/bin/bash"
  ssh_copy_text = "#!/bin/bash"
  
  private_count = 0

  ansible_provision = convert_string_to_boolean(ENV['ANSIBLE_PROVISION'] || false)
  k8s_provision = convert_string_to_boolean(ENV['KUBERNETES_PROVISION'] || false)

  master_group = ENV['MASTER_NODE_ANSIBLE_GROUP_NAME'] || "master"
  worker_group = ENV['WORKER_NODE_ANSIBLE_GROUP_NAME'] || "worker"

  (1..(master + worker)).each do |machine|
    name = (machine <= worker) ? "#{worker_node_name}" : "#{master_node_name}"
    id   = (machine <= worker) ? (worker - machine + 1) : (total_node - machine + 1)

    config.vm.define "#{name}#{id}" do |n|
      n.vm.host_name = "#{name}#{id}"

      machine_address = max_address - private_count
      ip_addr = "#{network_address}#{machine_address}"
      n.vm.network "private_network", ip: "#{ip_addr}"
      n.vm.network "forwarded_port", guest: 22, host: (max_host_port - private_count), auto_correct: false, id: "ssh"
      n.vm.provider :virtualbox do |vb, override|
        vb.name = "#{n.vm.hostname}"
        set_vbox(vb, override, os_image)
        vb.cpus = (machine <= worker) ? 1 : 2
      end
      
      if ansible_provision == true
        host_file_text += (machine == 1) ? "#{ip_addr} #{name}#{id}" : "\\n#{ip_addr} #{name}#{id}"
        if name == worker_node_name
          ansible_host_file_text += (id == worker) ? "[" + worker_group + "]" : ""
        else
          ansible_host_file_text += (id == master) ? (worker == 0) ? "[" + master_group + "]" : "\n\n[" + master_group + "]" : ""
        end
        ansible_host_file_text += "\n#{name}#{id}"
        ssh_auth_text += "\nsshpass -p vagrant ssh -T -o StrictHostKeyChecking=no vagrant@#{name}#{id} \"exit\""
        if machine < (master + worker)
          n.vm.provision "shell", path: "environment/scripts/bash_ssh_conf.sh"
        else
          write_file(host_file_text + "\"", "environment/ansible/host_vars/localhost.yaml")
          write_file(ansible_host_file_text, "environment/ansible/hosts.ini")
          write_file(ssh_auth_text, "environment/scripts/add_ssh_auth.sh")
          n.vm.provision "file", source: "environment/ansible", destination: "~/environment/ansible"
          n.vm.provision "shell", path: "environment/scripts/bootstrap.sh"
          n.vm.provision "shell", inline: "ansible-playbook environment/ansible/Ansible_env_ready.yaml"
          n.vm.provision "shell", inline: "ansible-playbook environment/ansible/Ansible_ssh_conf.yaml"
          n.vm.provision "shell", path: "environment/scripts/add_ssh_auth.sh", privileged: false
        end
      end
      if k8s_provision == true
        ssh_copy_text += "\ncat /home/vagrant/.ssh/id_rsa.pub | sshpass -p vagrant ssh -o StrictHostKeyChecking=no vagrant@#{ip_addr} \"sudo tee -a /home/vagrant/.ssh/authorized_keys\""
        if machine == (master + worker)
          write_file(ssh_copy_text, "environment/scripts/ssh_copy_id.sh")
          n.vm.provision "file", source: "environment/kubernetes", destination: "~/environment/kubernetes"
          n.vm.provision "file", source: "environment/ansible/ansible.cfg", destination: "~/environment/kubernetes/"
          n.vm.provision "file", source: "environment/ansible/hosts.ini", destination: "~/environment/kubernetes/"
          n.vm.provision "shell", inline: "ansible-playbook environment/kubernetes/Kubespray_env_ready.yaml"
          n.vm.provision "shell", inline: "yes \"/home/vagrant/.ssh/id_rsa\" | ssh-keygen -t rsa -N \"\"", privileged: false
          n.vm.provision "shell", path: "environment/scripts/ssh_copy_id.sh", privileged: false
        end
      end
      private_count += 1
    end
  end
end

def set_vbox(vb, config, os_image)
  vb.gui = convert_string_to_boolean(ENV['GUI'] || false)
  vb.memory = (ENV['MEMORY'] || 2048).to_i

  case os_image
  when :centos7
    config.vm.box = "bento/centos-7.8"
  when :ubuntu18
    config.vm.box = "bento/ubuntu-18.04"
  when :ubuntu20
    config.vm.box = "ubuntu/focal64"
  else
    config.vm.box = os_image.to_s
  end
end

def convert_string_to_boolean(obj)
  value = obj.to_s.downcase
  return (value == "yes" or value == "true")
end

def read_file(file)
  aFile = File.new(file, 'r')
  fSize = aFile.stat.size
  content = aFile.sysread(fSize)
  return content
end

def write_file(text, name)
  aFile = File.new(name, "w")
  aFile.syswrite(text)
end

case Random.new.rand(1..5)
when 1
  puts "⠀⠀⠀⠀⠀  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣷⠆
⣶⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣴
⢹⣿⡋⠁⣦⣄⡀⠀⠀⣠⣤⠀⠀⠀⠀⠀⠀⠀⢰⣦⣄⣤⣶⣤⣠⣤⣿⣿⣿⡏
⠀⢻⣿⣷⣿⣿⣿⣷⡿⢿⣿⡆⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏
⠀⠀⢿⣿⣿⣿⣿⣧⣄⣸⣿⣿⡀⠀⠀⠀⠀⢀⣿⣿⣿⠛⠉⠛⢿⣿⣿⡿
⠀⠀⠀⠉⣿⣿⣿⣿⣿⣿⣿⣿⣷⠀⠀⠀⠀⣾⣿⣿⣿⣷⣦⣾⣿⣿⡿
⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⡿⠃
⠀⠀⠀⠀⠸⣿⠛⠛⠿⣿⣿⣿⣿⣿⡆⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃
⠀⠀⠀⠀⠀⠻⣶⣤⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⣿⣿⣿⣿⠏
⠀⠀⠀⠀⠀⠀⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣁⣴⣾⣿⣿⡏
⠀⠀⠀⠀⠀⠀⠈⢿⣿⣿⣿⣿⣿⡿⠟⢿⣿⣿⣿⣿⣿⣿⡟
⠀⠀⠀⠀⠀⠀⠀⠈⣿⣿⣿⣿⣿⣦⣄⣠⣴⣿⡟⢿⣿⡿⠁
⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⡿⣿⣿⣿⡇⣠⣼⠁
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠻⢿⣿⣥⣄⣿⣿⣿⠿⠋⠁
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠿⠟⠋
⢀⠀⠀⢀⠀⠀⣀⠀⠀⢀⣀⡀⠀⢀⣀⣀⠀⠀⢀⡀⠀⠀⣀⠀⠀⡀⣀⣀⣀⡀
⠀⢃⠀⡸⠀⡘⠘⡄⠀⡇⠀⠀⠀⢀⣀⣸⠀⠀⡜⠸⡀⠀⡇⢆⠀⡇⠀⢸
⠀⠘⣤⠁⢠⠛⠒⢳⠀⢇⣀⣸⠀⠈⠀⠱⡀⢰⠓⠚⢣⠀⡇⠈⢢⡇⠀⢸"
when 2
  puts "⠀⠀  ⠀⠀⠀⠀⣀⣤⣶⣶⣾⣿⣿⣿⣿⣷⣶⣶⣤⣀
⠀⠀⠀⠀⠀⣠⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⣄
⠀⠀⠀⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣄
⠀⠀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⠀⠹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧
⠀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⠀⡄⠀⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷
⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠏⠀⣼⣿⡀⠀⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇
⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⠀⢰⣿⣿⣷⡀⠈⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠀⢀⠀⠙⠿⣿⣧⠀⠈⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⢹⣿⣿⣿⣿⣿⣿⣿⣿⡿⠀⢀⣾⣷⣦⡀⠈⠛⢧⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿⡟
⠘⣿⣿⣿⣿⣿⣿⣿⡿⠁⠀⣾⣿⣿⣿⣿⣷⣄⠀⠀⠀⠸⣿⣿⣿⣿⣿⣿⣿⠇
⠀⠹⣿⣿⣿⣿⣿⣿⠃⠀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣦⣀⢀⣿⣿⣿⣿⣿⣿⠏
⠀⠀⠙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋
⠀⠀⠀⠈⠙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠛⠁
⠀⠀⠀⠀⠀⠀⠙⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⠋
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠛⠛⠛⠛⠛⠛⠛⠛⠋⠁

⠀⡔⡄⠀⠀⡶⣄⢰⡆⠀⢰⡒⠒⠀⠀⢰⠀⠀⣶⠒⡦⠀⠀⡆⠀⠀⠀⢰⠒⠒
⡸⠑⢷⠀⠀⠇⠈⠾⠇⠀⠠⣈⡱⠀⠀⠸⠀⠀⢿⣀⡹⠀⠀⢧⣀⡀⠀⠺⣁⣀"
when 3
  puts "⠀  ⠀⠀⠀⠀⢰⡇

⠀⠀⠀⠀⠀⠀⠀⢀⣄
⣀⠀⠀⠀⠀⠀⠀⣿⣿
⠛⠀⠀⣠⡀⠀⠀⠙⠋
⠀⠀⢰⣿⣿⠀⠀⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡆
⠀⠀⠀⠙⠁⠀⣠⣾⣿⣦⠀⠀⢰⠀⣴⢰⠀⢰⠀⡷⢶⡄⣴⢶⡄⣴⠶⡆⢰⠶⣦⢰⠶⢠⡶⢦⢰⡆⢰⡆
⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⠀⠀⢸⣾⣇⢸⠀⢸⠀⡇⠈⡇⣷⠶⠇⠻⠶⣅⢸⠀⣿⢸⠀⢰⠟⢻⢸⡇⢸⡇
⠀⠀⠀⣠⡀⠀⠻⣿⣿⠟⠀⠀⢸⠀⢹⠸⣦⣼⠀⣧⣼⠇⢷⣴⠆⢻⣴⠟⢸⣤⡟⢸⠀⠸⣦⣼⠘⢧⣼⡇
⠀⠀⢸⣿⣿⠀⠀⠈⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⢷⡾⠁
⣤⠀⠀⠙⠁⠀⠀⢀⣄
⠙⠀⠀⠀⠀⠀⠀⣿⣿
⠀⠀⠀⠀⠀⠀⠀⠈⠋

⠀⠀⠀⠀⠀⠀⠀⠰⡇"
when 4
  puts "⠀⠀  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⡇
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠛⠛⠛⠃
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⢸⣿⣿⡇⣿⣿⣿⡇⠀⠀⠀⠀⠀⢀⣦⡄
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⣀⠀⣉⣉⣉⢈⣉⣉⡁⣉⣉⣉⡁⣀⣀⣀⠀⠀⣾⣿⣿⣆
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⠀⣿⣿⣿⢸⣿⣿⡇⣿⣿⣿⡇⣿⣿⣿⠀⠀⢿⣿⣿⣿⣿⣿⣷⡆
  ⠀⠀⠀⠀⠀⠀⢀⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣶⣿⣿⣿⣿⠿⠛⠁
  ⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟
  ⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠁
  ⠀⠀⠀⠀⠀⠀⠀⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟
  ⠀⠀⠀⠀⠀⠀⠀⠀⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠁
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠛⠁
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠛⠛⠛⠛⠛⠛⠋⠉
  
  ⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇
  ⠀⢀⣤⣤⣄⣸⡇⠀⢀⣠⣤⣤⣀⠀⠀⠀⣀⣤⣤⣄⡀⢸⡇⠀⠀⣀⣤⠀⢀⣠⣤⣤⣀⠀⠀⣤⣀⣤⣤⣄
  ⣰⠟⠁⠀⠈⢻⡇⢀⡾⠉⠀⠀⠻⣧⠀⣼⠏⠁⠀⠉⠃⢸⣇⣤⡾⠛⠁⢠⣿⠋⠀⠈⢹⣷⠀⣿⠏⠁
  ⢿⡄⠀⠀⠀⣸⡇⠸⣧⠀⠀⠀⢀⣿⠀⣿⡀⠀⠀⠀⠀⢸⡟⠙⢷⣄⠀⢸⣟⠛⠛⠛⠛⠛⠀⣿
  ⠈⠻⢶⣶⡶⠟⠀⠀⠙⠷⣶⣶⠟⠃⠀⠘⠿⢶⣶⠾⠇⢸⡇⠀⠀⠙⢷⠀⠙⠷⣶⣶⠿⠀⠀⣿"
when 5
  puts "⠀⠀⠀  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣴⣾⣷⣤⣀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣾⣿⣿⣿⡿⢿⣿⣿⣿⣦⣄⡀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣾⣿⣿⣿⣿⣿⣿⡇⢸⣿⣿⣿⣿⣿⣿⣷⣦
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⠛⢿⣿⠟⠉⠁⠀⠀⠉⠙⢿⣿⠟⢻⣿⣿⡄
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣷⡄⠀⠠⣶⣿⠀⢸⣷⡦⠀⠀⣴⣿⣿⣿⡇
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⣿⣿⣿⠁⢠⣄⠈⠙⠀⠘⠋⠀⣠⡄⠸⣿⣿⣿⣿
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⡇⠀⡿⠿⠃⠀⣴⡄⠀⠺⠿⡇⠀⣿⣿⣿⣿⡇
  ⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣿⡟⠛⠁⠀⢀⣠⣤⠀⠀⠀⢠⣤⣄⠀⠀⡉⠛⣿⣿⣧
  ⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⣿⣿⣿⣿⣆⠈⠻⡏⠀⣴⡆⠀⢿⠏⠀⣼⣿⣿⣿⣿⡟
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢻⣿⣿⣿⣿⣦⡀⠀⠘⠛⠛⠀⠀⣠⣾⣿⣿⣿⣿⠏
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣿⣿⣿⣿⠃⣴⣶⣶⣶⣶⡆⠹⣿⣿⣿⡿⠃
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢿⣿⣿⣶⣿⣿⣿⣿⣿⣿⣾⣿⣿⠟⠁
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋
  ⢀⡀⠀⠀⠀⠀⠀⠀⠀⣀
  ⢸⡇⢀⣀⢀⡀⠀⣀⠀⣿⣀⣀⠀⠀⣀⣀⠀⢀⣀⣀⢀⣀⣀⡀⠀⢀⣀⣀⠀⣾⣇⡀⠀⣀⣀⠀⠀⣀⣀
  ⢸⣷⣾⠃⢸⣿⢸⣿⠀⣿⠋⢻⡇⣼⣏⣹⣧⢸⣿⠙⢸⣿⠙⣿⢀⣿⣋⣿⡆⣿⡏⠁⣼⣏⣹⣧⢸⣯⣉
  ⢸⡏⢻⣦⠸⣿⣼⣿⠀⣿⣤⣾⠇⠹⣯⣭⡅⢸⣿⠀⢸⣿⠀⣿⠈⢿⣭⣭⡁⢻⣧⣄⢻⣯⣭⡅⢠⣬⣿⠇
  ⠀⠀⠀⠀⠀⠈⠉⠀⠀⠈⠉⠀⠀⠀⠈⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠁⠀⠀⠉⠁⠀⠈⠉⠀⠀⠉⠁"
end
puts "\nVansible with Kubespray\n- github.com/rayshoo/vansible_with_kubespray"