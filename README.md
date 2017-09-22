# ansible-openstack-setup

This repository contains a playbook to setup an bare OpenStack environment
using the python-openstackclient package. The playboook requires sudo to
install the operating system and Python packages.

# Usage

1. Edit the `inventory` and  `variables` files to suit your environment. The
`inventory` needs a server to copy the official images from. The `variable`
file should contain path from the localhost to keys and the location of the
OpenStack variable file.
2. Source the `variables` file:
```sh
source variables
```
3. Run the Ansible playbook:
```sh
ansible-playbook -vv create_server_openstack.yml
```

This playbook runs a series of commands on localhost (some require sudo so use
`-K` if needed) to create a VM server in OpenStack. A floating IP address is
created for this VM server and the address is added to the Ansible dynamic
inventory. Other playbooks are run in sequence at the end of the playbook to
automate the different parts of the install.

When finished with this system you can use the shell script to undo the changes
made to go back to an unconfigured state.
