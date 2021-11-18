# bkeXtest

dead simple nginx app that serves from a file from the NFS storage

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

```make test```

This will test each URL and report if it works.

Make will also deploy or delete as needed to test setup functions.

