# ansible-openstack-setup

This repository contains a playbook to setup an bare OpenStack environment
using the python-openstackclient package. The playboook requires sudo to
install the operating system and Python packages.

# Usage

1. Edit the `inventory` file to suit your environment. The openstack-server
group is a system that runs the OpenStack commands such as localhost or what
is known as an overcloud system. The path to the key files is also important.
2. Run the Ansible playbook:
```sh
ansible-playbook -vv create_server_openstack.yml
```

This playbook runs a series of commands on the openstack-server (some require
sudo so use the sudo password flag `-K` if needed) to create a VM server in
OpenStack. A floating IP address is created for this VM server and the address
is added to the Ansible dynamic inventory. Other playbooks are run in sequence
at the end of the playbook to automate the different parts of the install.

When finished with this system you can use the delete playbook to undo the
changes made to go back to an unconfigured state.
