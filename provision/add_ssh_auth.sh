#!/bin/bash

#ssh key 생성
sshpass -p vagrant ssh -T -o StrictHostKeyChecking=no vagrant@m1
sshpass -p vagrant ssh -T -o StrictHostKeyChecking=no vagrant@m2
# sshpass -p vagrant ssh -T -o StrictHostKeyChecking=no vagrant@m3

sshpass -p vagrant ssh -T -o StrictHostKeyChecking=no vagrant@w1
sshpass -p vagrant ssh -T -o StrictHostKeyChecking=no vagrant@w2