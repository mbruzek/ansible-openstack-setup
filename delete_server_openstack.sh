#!/bin/bash

# This script reverses the commands performed in create_server_openstack.yml

set -eu

# Load the variables for the values to clean up.
source variables
source $openstack_rc_path

server_ids=$(virtualenv/bin/openstack server list --format value -c ID)
echo "Deleting all servers"
for server_id in ${server_ids}; do
  virtualenv/bin/openstack server delete ${server_id}
done

keypair_names=$(virtualenv/bin/openstack keypair list --format value -c Name)
echo "Deleting all keypairs"
for keypair_name in ${keypair_names}; do
  virtualenv/bin/openstack keypair delete ${keypair_name}
done

flavor_id=$(virtualenv/bin/openstack flavor show ${server_flavor} --format value -c id)
echo "Deleting flavor"
virtualenv/bin/openstack flavor delete ${flavor_id}

floating_ips=$(virtualenv/bin/openstack floating ip list --format value -c ID)
echo "Deleting all floating ips"
for floating_id in ${floating_ips}; do
  virtualenv/bin/openstack floating ip delete ${floating_id}
done

# Check for the security group before attempting delete.
if virtualenv/bin/openstack security group show ${security_group_name}; then
  echo "Deleting the ${security_group_name} that has all rules"
  virtualenv/bin/openstack security group delete ${security_group_name}
fi

# Check for the subnet before attempting to delete it.
if virtualenv/bin/openstack subnet show ${subnet_name}; then
  # The subnet can not be deleted until it is removed from the router.
  echo "Remove the subnet ${subnet_name} from the router ${router_name}"
  virtualenv/bin/openstack router remove subnet ${router_name} ${subnet_name} || true

  echo "Deleting the subnet ${subnet_name}"
  virtualenv/bin/openstack subnet delete ${subnet_name}
fi

# Check for the network before attempting to delete it.
if virtualenv/bin/openstack network show ${network_name}; then
  echo "Deleting the network ${network_name}"
  networks=$(virtualenv/bin/openstack network show ${network_name} --format value -c id)
  for network_id in ${networks}; do
    virtualenv/bin/openstack network delete ${network_id}
  done
fi

routers=$(virtualenv/bin/openstack router list --format value -c ID)
echo "Deleting all routers"
for router in ${routers}; do
  virtualenv/bin/openstack router delete ${router}
done
