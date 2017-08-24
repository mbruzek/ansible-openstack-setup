#!/bin/bash

set -eu

# Load the variables for the values to clean up.
source variables
source $openstack_rc_path

server_ids=$(openstack server list --format value -c ID)
echo "Deleting all servers"
for server_id in ${server_ids}; do
  openstack server delete ${server_id}
done

keypair_names=$(openstack keypair list --format value -c Name)
echo "Deleting all keypairs"
for keypair_name in ${keypair_names}; do
  openstack keypair delete ${keypair_name}
done

floating_ips=$(openstack floating ip list --format value -c ID)
echo "Deleting all floating ips"
for floating_id in ${floating_ips}; do
  openstack floating ip delete ${floating_id}
done

# Check for the security group before attempting delete.
if openstack security group show ${security_group_name}; then
  echo "Deleting the ${security_group_name} that has all rules"
  openstack security group delete ${security_group_name}
fi

# Check for the subnet before attempting to delete it.
if openstack subnet show ${subnet_name}; then
  # The subnet can not be deleted until it is removed from the router.
  echo "Remove the subnet ${subnet_name} from the router ${router_name}"
  openstack router remove subnet ${router_name} ${subnet_name} || true

  echo "Deleting the subnet ${subnet_name}"
  openstack subnet delete ${subnet_name}
fi

# Check for the network before attempting to delete it.
if openstack network show ${network_name}; then
  echo "Deleting the network ${network_name}"
  openstack network delete ${network_name}
fi

routers=$(openstack router list --format value -c ID)
echo "Deleting all routers"
for router in ${routers}; do
  openstack router delete ${router}
done
