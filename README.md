# bkeXtest

dead simple nginx app that serves from a file from the NFS storage


```
# kubectl apply -k ./<ENV> -kubeconfig ./<ENV>/kubeconfig.json
```


## Info

Domains:
* bkeitest.virtorch.brown.edu - PROD INT
* bkedtest.virtorch.brown.edu - PROD DMZ
* drbkeitest.virtorch.brown.edu - DR INT
* drbkedtest.virtorch.brown.edu - DR DMZ
* qbkeitest.virtorch.brown.edu - QA INT
* qbkedtest.virtorch.brown.edu - QA DMZ

## Makefile