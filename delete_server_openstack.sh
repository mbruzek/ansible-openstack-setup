#!/bin/bash

# This script reverses the commands performed in create_server_openstack.yml

set -ux

# Load the variables for the values to clean up.
source variables
source $openstack_rc_path
# Path to the openstack client.
openstack=virtualenv/bin/openstack

echo "Checking for the ${env_id} stack"
if ${openstack} stack show ${env_id}.example.com --format value -c id; then
  echo "Deleting the ${env_id} stack"
  ${openstack} stack delete ${env_id}.example.com --yes --wait
fi

servers=$(${openstack} server list --name ${server_name} --format value -c ID)
for server_id in ${servers}; do
  echo "Deleting the ${server_name} server"
  ${openstack} server delete ${server_id}
done

echo "Deleting the ${keypair_name} keypair"
${openstack} keypair delete ${keypair_name}

read -p "Delete the flavors? " yesorno
if [[ $yesorno == 'yes' || $yesorno == 'y' ]]; then
  echo "Deleting all the flavors"
  flavor_ids=$(${openstack} flavor list --format value -c ID)
  for flavor_id in ${flavor_ids}; do
    ${openstack} flavor delete ${flavor_id}
  done
fi

floating_ips=$(${openstack} floating ip list --format value -c ID)
echo "Deleting all floating ips"
for floating_id in ${floating_ips}; do
  ${openstack} floating ip delete ${floating_id}
done

# Check for the security group before attempting delete.
if ${openstack} security group show ${security_group_name}; then
  echo "Deleting the ${security_group_name} that has all rules"
  ${openstack} security group delete ${security_group_name}
fi

routers=$(${openstack} router list --name ${router_name} --format value -c ID)
subnets=$(${openstack} subnet list --name ${subnet_name} --format value -c ID)
for router_id in ${routers}; do
  for subnet_id in ${subnets}; do
    echo "Removing the subnet ${subnet_name} from the router ${router_name}"
    ${openstack} router remove subnet ${router_id} ${subnet_id}
  done
  ${openstack} subnet delete ${subnet_id}
done

networks=$(${openstack} network list --name ${network_name} --format value -c ID)
for network_id in ${networks}; do
  echo "Deleting the network ${network_name}"
  ${openstack} network delete ${network_id}
done

routers=$(${openstack} router list --name ${router_name} --format value -c ID)
for router_id in ${routers}; do
  echo "Deleting the ${router_name} router"
  ${openstack} router delete ${router_id}
done

read -p "Delete the images? " yesorno
if [[ $yesorno == 'yes' || $yesorno  == 'y' ]]; then
  image_ids=$(${openstack} image list --format value -c ID)
  for image_id in ${image_ids}; do
    ${openstack} image delete ${image_id}
  done
fi
