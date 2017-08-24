# ansible-openstack-setup

This repository contains a playbook to setup an bare OpenStack environment
using the python-openstackclient package. It is meant to be run on the
localhost and requires sudo to install the python package.

# Usage

1. Edit the `variables` file to suit your environment. The most important
variable being the `openstack_rc_path` is the location of the RC file.
2. Source the variables file:
```sh
source variables
```
3. Run the ansible playbook:
```sh
ansible-playbook openstack_setup.yml --ask-become-pass
```

NOTE: The SUDO password is to install the OpenStack client. Or:  

```sh
ansible-playbook openstack_setup.yml --skip-tags install
```

If you don't want to install the python-openstackclient.

If all the variables are set correctly, this will result in a server VM started
in your OpenStack environment, connected to a floating IP address accessible
via ssh using the private key.

When finished with this system you can use the shell script to undo the changes
made to go back to an unconfigured state.
