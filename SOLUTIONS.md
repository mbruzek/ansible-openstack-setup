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
