# Problems and Solutions

This repository automates a wide variety of software and sometimes that does
not go as planed. This document is a list of problems that were encountered
when developing this repository and the steps to fix those problems.

If you encounter an error that is not listed here that would be a good
contribution.

### TASK [Waiting for the server ansible-host to start]
#### Problem: Timeout when waiting for <target-host-ip-address>:22
While running the create_server_openstack.yml playbook on Jenkins
the task was attempting to wait for ssh-server on the target host to start.
#### Solution: Change the task to run on the openstack-server rather than the localhost
The task was written to wait from the local system (in this case Jenkins slave).
The networking on some OpenStack environment is configured so only the
openstack-server can access the floating ips. Change this task to wait from the
openstack-server rather than the server running the playbook.

### TASK [Bootstrapping Python on this host]
#### Problem: Failed to connect to the host via ssh: ssh: connect to host <target-host-ip-address> port 22: Connection timed out
#### Solution: Run the script from the openstack-host
The Ansible host can not connect to the target-host ip address because only the
openstack-host can see that network.

### TASK [Finding the oldest atomic and rhel qcow2 images]
#### Problem: No first item, sequence was empty.
Encountered an error when running the find_and_prepare_images.yml playbook.
#### Solution: Only run the task when matching > 0 on each file return value.
There were no qcow2 images on the server. The task tried to grab the first
element in an empty list of files. Rewrote the task to use:
`when: atomic_qcow2_images['matched'] > 0` and
`when: rhel_qcow2_images['matched'] > 0`

### TASK [Converting and compressing the images for transport]
#### Problem: Includes a variable that is undefined 'dict object' has no attribute 'path'
Encountered an error running the find_and_prepare_images.yml playbook. This was
a problem when creating the images and the code was using the results of the
stat module. As it  turns out the stat module does not return 'path' if the file
does not exist.
#### Solution: Changed the task to use item[0] to generate the qcow2 file path.
Still want to use the stat results to prevent creating an image when one
already exists, just can not use the 'path' attribute on files that do not
exist.

### TASK [Creating the ci_subnet subnet]
#### Problem: More than one Network exists with the name 'ci_network'.
The create_server_openstack.yml playbook could not create the subnet because
there were more than one network with the same name.
#### Solution: Clean up the OpenStack environment better and use UUIDs.
The delete_server_openstack.yml uses the UUIDs of all the networks with the
same name and deletes each UUID. There must have been an error deleting the
network from last time. The creation code could also use UUIDs to prevent this
error from occurring again.

### TASK [Creating a symbolic link to the openshift-ansible directory]
#### Problem: src file does not exist, use \"force=yes\" if you really want to create the link: /usr/share/ansible/openshift-ansible
The image that is used for ansible-host is fedora-26, and does not contain
the openshift-ansible code. The ocp-3.7 images contain the openshift-ansible
code of that particular build.
#### Solution: Download the OCP images before creating the ansible-host and use that image for the VM.
The find_and_prepare_images.yml downloads the images to the ansible-host so that
needs to change to the openstack-server host, unless you can download the images
to Glance directly. Move find_and_prepare_images.yml up in the call chain to
have the images available when create_server_openstack.yml creates the server
VM.

### TASK [Deleting the subnet ci_subnet]
#### Problem: Failed to delete subnet with name or ID '19e72f57-8f4e-4214-bdce-02de67d565a8'
The delete_server_openstack.yml playbook encountered an error when attempting
to delete the ci_subnet. The message specified further information:
`Unable to complete operation on subnet 19e72f57-8f4e-4214-bdce-02de67d565a8: One or more ports have an IP allocation from this subnet.`
#### Solution: Delete the test server VM on that subnet.
Was testing some things with a manually created VM server that used that subnet.
The delete script does not know about servers not created by the scripts.

### TASK [openstack-stack : Handle the Stack (create/delete)]
#### Problem: AttributeError: 'bool' object has no attribute 'id'
The openshift-ansible-contrib provision.yaml playbook encountered an error when
attempting to create resources. The flavor size was too small for the image.
The message specified further information:
`Flavor's disk is too small for requested image. Flavor disk is 34359738368 bytes, image is 54760833024 bytes.`
#### Solution: Increase the size of the node_small flavor.
Changed the size of the node_small flavor in create_server_openstack.yml to
64GB so it can handle the 54GB image.

### TASK [general-prerequisites : Bootstrapping Python on this system]
#### Problem: Failed to connect to the host via ssh: Connection timed out
The install_server_dependencies.yml playbook stopped on the first task of the
general-prerequisites role with a connection timed out error.
`Failed to connect to the host via ssh: Connection timed out during banner exchange`
`unreachable`
#### Solution: Add a retry in the general-prerequisites tasks.
The connection timeout commands could be a network problem change the script
to retry the raw commands on the new server.

### TASK [Copying the Ansible configuration file from inventory]
#### Problem: The openshift-ansible-contrib repo changed location of ansible.cfg
One of the last changes in the openshift-ansible-contrib repository updated
the README.md and in an effort to streamline the experience removed the
configuration file from the sample-inventory directory which is copied to
inventory. Also remove the task that deletes that file.
`Source inventory/ansible.cfg not found`
#### Solution: Make openshift_on_openstack.yml playbook look for the new location.
The ansible.cfg file can be found in `openshift-ansible-contrib/playbooks/provisioning/openstack`
directory from now on. 
