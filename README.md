# bkeXtest

dead simple nginx app that serves from a file from the NFS storage

## Prerequisites
* [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [docker](https://docs.docker.com/install/)
* [1Password CLI](https://developer.1password.com/docs/cli/get-started/)

## Info

This app tests Ingress, NFS and basic K8S api service. These are sufficient to
ensure a cluster is working, but doesn't test all nodes.

Domains:
* bkeitest.virtorch.brown.edu - PROD INT
* bkedtest.virtorch.brown.edu - PROD DMZ
* drbkeitest.virtorch.brown.edu - DR INT
* drbkedtest.virtorch.brown.edu - DR DMZ
* qbkeitest.virtorch.brown.edu - QA INT
* qbkedtest.virtorch.brown.edu - QA DMZ
* dbkeitest.virtorch.brown.edu - DEV INT
* dbkedtest.virtorch.brown.edu - DEV DMZ

## Makefile

Use the default "make" target to see what commands can be run. 

This set of commands will delete and existing deploy then build, push, and deploy
a new set of instances.

```
# make local-dev
# make delete
# make build
# make push
# make deploy
# make test
```

### Local Dev
Local dev is possible by using 1Password to retreive secrets. See [sec_locations.exe](./seclocations.txt)
for details on the relevent secrets. GH Action deployment uses the OIT 
SecretsVault service. 

