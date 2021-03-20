# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'fileutils'

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

  provision = convert_string_to_boolean(ENV['PROVISION'] || false)
  ansible_provision = convert_string_to_boolean(ENV['ANSIBLE_PROVISION'] || false)
  docker_provision = convert_string_to_boolean(ENV['DOCKER_PROVISION'] || false)
  k8s_provision = convert_string_to_boolean(ENV['KUBERNETES_PROVISION'] || false)
  cluster_structure = convert_string_to_boolean(ENV['CLUSTER_STRUCTURE_AUTO_CREATE'] || false)
  spec_file = convert_string_to_boolean(ENV['SERVERSPEC_FILEUTIL_ENABLE'] || false)
  spec_test = convert_string_to_boolean(ENV['SERVERSPEC_TEST'] || false)
  spec_provision = convert_string_to_boolean(ENV['SERVERSPEC_PROVISION'] || false)

  host_file_text = "nodes: \""
  ansible_host_file_text = ""
  inventory_text = "[all]"
  master_hosts = ""
  worker_hosts = ""
  etcd_hosts = ""
  ssh_auth_text = "#!/bin/bash\nif [ ! -f \"/home/vagrant/.ssh/id_rsa\" ]; then\n  yes \"/home/vagrant/.ssh/id_rsa\" | ssh-keygen -t rsa -N \"\"\nelse\n  echo \"id_rsa file already exists. Skip ssh-keygen...\"\nfi\n"
  path = "templates"
  spec_prefix_text = read_file("#{path}/default.rb")
  control_node_spec_text = spec_prefix_text
  master_node_spec_text = spec_prefix_text
  worker_node_sepc_text = spec_prefix_text

  if spec_file
    if ansible_provision
      control_node_spec_text += "\n\n" + read_file("#{path}/ansible.rb")
    end
    if docker_provision
      control_node_spec_text += "\n\n" + read_file("#{path}/docker_c.rb")
      if k8s_provision
        master_node_spec_text += "\n\n" + read_file("#{path}/docker.rb")
        worker_node_sepc_text += "\n\n" + read_file("#{path}/docker.rb")
      end
    end
    if k8s_provision
      if !docker_provision
        control_node_spec_text += "\n\n" + read_file("#{path}/docker.rb")
        master_node_spec_text += "\n\n" + read_file("#{path}/docker.rb")
        worker_node_sepc_text += "\n\n" + read_file("#{path}/docker.rb")
      end
      control_node_spec_text += "\n\n" + read_file("#{path}/kubernetes_m.rb")
      master_node_spec_text += "\n\n" + read_file("#{path}/kubernetes_m.rb")
      worker_node_sepc_text += "\n\n" + read_file("#{path}/kubernetes_w.rb")
    end
    Dir.foreach("spec") do | entry |
      if (entry != "." && entry != ".." && entry != "spec_helper.rb" && entry != "spec.tar.gz" && entry != "spec_env.yaml")
        FileUtils.remove_dir("spec/#{entry}")
      end
    end
  end

  ansible_provision = provision ? ansible_provision : false
  docker_provision = provision ? docker_provision : false
  k8s_provision = provision ? k8s_provision : false
  
  master_group = ENV['MASTER_NODE_ANSIBLE_GROUP_NAME'] || "master"
  worker_group = ENV['WORKER_NODE_ANSIBLE_GROUP_NAME'] || "worker"

  private_count = 0

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
      n.vm.boot_timeout = 600

      if spec_file
        Dir.mkdir("spec/#{name}#{id}")
        if (machine <= worker)
          write_file(worker_node_sepc_text, "spec/#{name}#{id}/check_spec.rb")
        elsif (machine == master + worker)
          write_file(control_node_spec_text, "spec/#{name}#{id}/check_spec.rb")
        else
          write_file(master_node_spec_text, "spec/#{name}#{id}/check_spec.rb")
        end
      end
      
      if ansible_provision
        host_file_text += (machine == 1) ? "#{ip_addr} #{name}#{id}" : "\\n#{ip_addr} #{name}#{id}"
        if name == worker_node_name
          ansible_host_file_text += (id == worker) ? "[" + worker_group + "]" : ""
        else
          ansible_host_file_text += (id == master) ? (worker == 0) ? "[" + master_group + "]" : "\n\n[" + master_group + "]" : ""
        end
        ansible_host_file_text += "\n#{name}#{id} ansible_host=#{ip_addr}"
        ssh_auth_text += "\ncat /home/vagrant/.ssh/id_rsa.pub | sshpass -p vagrant ssh -o StrictHostKeyChecking=no vagrant@#{name}#{id} \"exit\""
        ssh_auth_text += "\ncat /home/vagrant/.ssh/id_rsa.pub | sshpass -p vagrant ssh -o StrictHostKeyChecking=no vagrant@#{ip_addr} \"sudo tee -a /home/vagrant/.ssh/authorized_keys\""
        if machine < (master + worker)
          n.vm.provision "shell", path: "environment/scripts/bash_ssh_conf.sh"
        else
          write_file(host_file_text + "\"", "environment/ansible/host_vars/localhost.yaml")
          write_file(ansible_host_file_text, "environment/ansible/hosts.ini")
          write_file(ssh_auth_text, "environment/scripts/add_ssh_auth.sh")
          n.vm.provision "file", source: "environment/ansible", destination: "~/environment/ansible"
          n.vm.provision "file", source: "environment/scripts/add_ssh_auth.sh", destination: "~/environment/ansible/"
          n.vm.provision "shell", path: "environment/scripts/bootstrap.sh"
          n.vm.provision "shell", keep_color: true, inline: "ANSIBLE_FORCE_COLOR=true ansible-playbook environment/ansible/ansible_env.yaml", privileged: false
          n.vm.provision "shell", keep_color: true, inline: "ANSIBLE_FORCE_COLOR=true ansible-playbook environment/ansible/ansible_ssh.yaml"
          n.vm.provision "shell", path: "environment/scripts/add_ssh_auth.sh", privileged: false
          n.vm.provision "shell", keep_color: true, inline: "ANSIBLE_FORCE_COLOR=true ansible-playbook -i ~/hosts.ini environment/ansible/custom/motd.yaml", privileged: false
        end
      end
      if k8s_provision
        
        if machine < (master + worker)
          if cluster_structure
            if name == worker_node_name
              worker_hosts += "\n#{name}#{id}"
              inventory_text += "\n#{name}#{id} ansible_host=#{ip_addr}  ip=#{ip_addr}"
            else
              master_hosts += "\n#{name}#{id}"
              if (machine == worker + 1 && master % 2 == 0)
                inventory_text += "\n#{name}#{id} ansible_host=#{ip_addr}  ip=#{ip_addr}"
              else
                inventory_text += "\n#{name}#{id} ansible_host=#{ip_addr}  ip=#{ip_addr} etcd_member_name=etcd#{id}"
                etcd_hosts += "\n#{name}#{id}"
              end
            end
          end
        else
          n.vm.provision "file", source: "environment/kubernetes", destination: "~/environment/kubernetes"
          if cluster_structure
            master_hosts += "\n#{name}#{id}"
            etcd_hosts += "\n#{name}#{id}"
            inventory_text += "\n#{name}#{id} ansible_host=#{ip_addr}  ip=#{ip_addr} etcd_member_name=etcd#{id}"
            inventory_text += "\n\n[kube-master]#{master_hosts}\n\n[etcd]#{etcd_hosts}\n\n[kube-node]#{worker_hosts}\n\n[calico-rr]\n\n[k8s-cluster:children]\nkube-master\nkube-node\ncalico-rr"
            write_file(inventory_text, "environment/kubernetes/inventory.ini")
            n.vm.provision "shell", keep_color: true, inline: "ANSIBLE_FORCE_COLOR=true ansible-playbook environment/kubernetes/kubespray_env.yaml", privileged: false
          else
            n.vm.provision "file", source: "cluster/inventory.ini", destination: "environment/kubernetes/inventory.ini"
            n.vm.provision "file", source: "cluster/group_vars", destination: "environment/kubernetes/group_vars"
            n.vm.provision "shell", keep_color: true, inline: "ANSIBLE_FORCE_COLOR=true ansible-playbook -e cluster_structure=false environment/kubernetes/kubespray_env.yaml", privileged: false
          end
          n.vm.provision "shell", keep_color: true, inline: "cd environment/kubernetes/ && ANSIBLE_FORCE_COLOR=true ansible-playbook -i inventory.ini kubespray/cluster.yml -v --become --become-user=root", privileged: false
          n.vm.provision "shell", keep_color: true, inline: "ANSIBLE_FORCE_COLOR=true ansible-playbook -i environment/kubernetes/inventory.ini environment/kubernetes/kubernetes_env.yaml", privileged: false
        end
      end
      if docker_provision
        if machine == (master + worker)
          n.vm.provision "file", source: "environment/docker", destination: "~/environment/docker"
          n.vm.provision "shell", keep_color: true, inline: "ANSIBLE_FORCE_COLOR=true ansible-playbook environment/docker/docker_env.yaml", privileged: false
        end
      end
      if spec_provision
        if machine == (master + worker)
          n.vm.provision "file", source: "spec", destination: "~/environment/serverspec/spec"
          n.vm.provision "file", source: "Gemfile", destination: "~/environment/serverspec/"
          n.vm.provision "file", source: "Rakefile", destination: "~/environment/serverspec/"
          n.vm.provision "file", source: ".rspec", destination: "~/environment/serverspec/"
          n.vm.provision "file", source: "templates/spec_helper.rb", destination: "~/environment/serverspec/spec/spec_helper.rb"
          n.vm.provision "shell", keep_color: true, inline: "ANSIBLE_FORCE_COLOR=true ansible-playbook environment/serverspec/spec/spec_env.yaml", privileged: false
        end
      end
      if spec_test
        if machine == (master + worker)
          n.vm.provision "shell", inline: "cd environment/serverspec/ && rake spec", privileged: false
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
    config.vm.box = "generic/ubuntu1804"
  when :ubuntu20
    config.vm.box = "generic/ubuntu2004"
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