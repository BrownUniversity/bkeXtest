# bkeXtest

dead simple nginx app that serves from a file from the NFS storage

## Prerequisites
* [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [blackbox](https://github.com/StackExchange/blackbox)
* [docker](https://docs.docker.com/install/)

## Info

This app tests Ingress, NFS and basic K8S api service. These are sufficient to
ensure a cluster is working, but can't test all nodes (yet)

Domains:
* bkeitest.virtorch.brown.edu - PROD INT
* bkedtest.virtorch.brown.edu - PROD DMZ
* drbkeitest.virtorch.brown.edu - DR INT
* drbkedtest.virtorch.brown.edu - DR DMZ
* qbkeitest.virtorch.brown.edu - QA INT
* qbkedtest.virtorch.brown.edu - QA DMZ

## Makefile

Use the default "make" target to see what commands can be run. 

This set of commands will delete and existing deploy then build, push, and deploy
a new set of instances.

```
# make delete
# make build
# make push
# make deploy
# make test
```
## Cleanup

This app creates a new NFS PV each time is deploys. Due to the NFS provisioner's
config old PVs might need to be deleted manually.