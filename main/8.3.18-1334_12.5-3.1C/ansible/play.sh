#!/bin/bash

cd /home/ansible

if [ -n "$1" ]; then
  ansible-playbook -i ./inventory.yaml ./tune_all.yaml --tags $1
else
  ansible-playbook -i ./inventory.yaml ./tune_all.yaml
fi

