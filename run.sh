#!/bin/zsh

set -a
source .env
set +a

export PATH="/usr/local/bin:$PATH"
export ANSIBLE_HOST_KEY_CHECKING=False

ansible-playbook playbook.yml -v
