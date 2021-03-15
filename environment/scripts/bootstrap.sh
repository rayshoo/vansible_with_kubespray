#!/bin/bash
#
# Program: Initial vagrant.
# History: 2017/1/16 Kyle.b Release, 2021/03/08 Brian.Choi Modify
set -e
OS_NAME=$(awk -F= '/^NAME/{print $2}' /etc/os-release | grep -o "\w*"| head -n 1)

case "${OS_NAME}" in
  "CentOS")
    sudo yum install -y epel-release
    sudo yum install -y ansible
  ;;
  "Ubuntu")
    sudo apt update
    sudo apt install -y software-properties-common
    sudo apt-add-repository --yes --update ppa:ansible/ansible
    sudo apt install -y ansible
  ;;
  *)
    echo "${OS_NAME} is not support ..."; exit 1
esac