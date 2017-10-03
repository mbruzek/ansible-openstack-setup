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
#### Solution: Only run the task when matching > 0 on each file return value.
There were no qcow2 images on the server. The task tried to grab the first
element in an empty list of files. Rewrote the task to use:
`when: atomic_qcow2_images['matched'] > 0` and
`when: rhel_qcow2_images['matched'] > 0`
