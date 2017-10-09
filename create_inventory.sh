#!/bin/bash

set -u

# Create an inventory for the playbooks in this repository.
echo -e "[all:vars]\nansible_public_key_file=${PUBLIC_KEY}\nansible_private_key_file=${PRIVATE_KEY}" > inventory
echo -e "[openstack-server]\n${OPENSTACK_SERVER} ansible_user=${OPENSTACK_USER}" >> inventory
echo -e "[image-server]\n${IMAGE_SERVER} ansible_user=${IMAGE_USER}" >> inventory

cat inventory
