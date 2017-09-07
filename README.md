# ansible-openstack-setup

This repository contains a playbook to setup an bare OpenStack environment
using the python-openstackclient package. The playboook requires sudo to
install the operating system and Python packages.

# Usage

1. Edit the `variables` file to suit your environment. The most important
variable being the `openstack_rc_path` is the location of the RC file.
2. Source the `variables` file:
```sh
source variables
```
3. Run the Ansible playbook:
```sh
ansible-playbook -v create_server_openstack.yml
```
4. Install the dependencies on this new OpenStack server:
```sh
ansible-playbook -v install_server_dependencies.yml # connection information generated from create playbook.
```
5. Provision and install OpenShift on OpenStack:
```sh
ansible-playbook -v openshift_on_openstack.yml # connection information generated from create playbook.
```

If all the variables are set correctly, this will result in a server VM started
in your OpenStack environment, connected to a floating IP address accessible
via ssh using the private key.

When finished with this system you can use the shell script to undo the changes
made to go back to an unconfigured state.
