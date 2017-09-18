#!/bin/bash

# This script reverses the commands performed in create_server_openstack.yml

set -u

# Load the variables for the values to clean up.
source variables
source $openstack_rc_path
# Path to the openstack client.
openstack=virtualenv/bin/openstack

echo "Checking for the ${env_id} stack"
if ${openstack} stack show ${env_id}.example.com --format value -c id; then
  echo "Deleting the ${env_id} stack"
  ${openstack} stack delete ${env_id}.example.com
fi

echo "Deleting the ${server_name} server"
${openstack} server delete ${server_name}

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

# Check for the subnet before attempting to delete it.
if ${openstack} subnet show ${subnet_name}; then
  # The subnet can not be deleted until it is removed from the router.
  echo "Remove the subnet ${subnet_name} from the router ${router_name}"
  ${openstack} router remove subnet ${router_name} ${subnet_name} || true

  echo "Deleting the subnet ${subnet_name}"
  ${openstack} subnet delete ${subnet_name}
fi

# Check for the network before attempting to delete it.
if ${openstack} network show ${network_name}; then
  echo "Deleting the network ${network_name}"
  networks=$(${openstack} network show ${network_name} --format value -c id)
  for network_id in ${networks}; do
    ${openstack} network delete ${network_id}
  done
fi

echo "Deleting the ${router_name} router"
${openstack} router delete ${router_name}

read -p "Delete the images? " yesorno
if [[ $yesorno == 'yes' || $yesorno  == 'y' ]]; then
  image_ids=$(${openstack} image list --format value -c ID)
  for image_id in ${image_ids}; do
    ${openstack} image delete ${image_id}
  done
fi
