#!/bin/bash

#ssh key 생성
sshpass -p vagrant ssh -T -o StrictHostKeyChecking=no vagrant@w01
# sshpass -p vagrant ssh -T -o StrictHostKeyChecking=no vagrant@w02
# sshpass -p vagrant ssh -T -o StrictHostKeyChecking=no vagrant@m02
# sshpass -p vagrant ssh -T -o StrictHostKeyChecking=no vagrant@m03