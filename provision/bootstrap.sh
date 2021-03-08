#!/bin/bash
#
# Program: Initial vagrant.
# History: 2017/1/16 Kyle.b Release, 2021/03/08 Brian.Choi Modify


function set_hosts() {
cat <<EOF > ~/hosts
127.0.0.1   localhost
::1         localhost

192.168.33.10 m01
192.168.33.11 m02
192.168.33.12 m03
192.168.33.13 w01
192.168.33.14 w02
EOF
}

set -e
HOST_NAME=$(hostname)
OS_NAME=$(awk -F= '/^NAME/{print $2}' /etc/os-release | grep -o "\w*"| head -n 1)

if [ ${HOST_NAME} == "m01" ]; then
  case "${OS_NAME}" in
    "CentOS")
      sudo yum install -y epel-release
      sudo yum install -y ansible
      #sudo yum install -y git ansible sshpass python-netaddr openssl-devel
    ;;
    "Ubuntu")
      sudo apt update
      sudo apt install -y software-properties-common
      sudo apt-add-repository --yes --update ppa:ansible/ansible
      sudo apt install -y ansible
      #echo "192.168.33.10" | sudo tee -a /etc/ansible/hosts
      #echo "192.168.33.11" | sudo tee -a /etc/ansible/hosts
      # sudo useradd -m -s /bin/bash devops
      # echo "root:$root_passwd" | sudo chpasswd
      # echo "PermitRootLogin yes" | sudo tee -a /etc/ssh/sshd_config
      # sudo systemctl restart sshd
    ;;
    *)
      echo "${OS_NAME} is not support ..."; exit 1
  esac

  set_hosts
  sudo cp ~/hosts /etc/
else
  set_hosts
  sudo cp ~/hosts /etc/
fi

mkdir -p /home/vagrant/.vim/autoload /home/vagrant/.vim/bundle
touch /home/vagrant/.vimrc
touch /home/vagrant/.bashrc
