.DEFAULT_GOAL := help

#help:  @ List available tasks on this project
help:
	@grep -E '[a-zA-Z\.\-]+:.*?@ .*$$' $(MAKEFILE_LIST)| tr -d '#'  | awk 'BEGIN {FS = ":.*?@ "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

CLUSTERS ?= qa-bkpd qa-bkpi bkpd bkpi bkpddr bkpidr dev-bkpi dev-bkpd
SERVS ?= bkeitest bkedtest drbkeitest drbkedtest qbkeitest qbkedtest dbkeitest dbkedtest

.PHONY: build dlogin.qa dlogin.prod dlogin.dr \
	push.qa push.prod push.dr \
	deploy.qa-bkpd deploy.qa-bkpi \
	deploy.bkpd deploy.bkpi \
	deploy.bkpddr deploy.bkpidr \
	deploy.dev-bkpi deploy.dev-bkpd \
	delete.qa-bkpd delete.qa-bkpi \
	delete.bkpd delete.bkpi \
	delete.bkpddr delete.bkpidr \
	delete.dev-bkpi delete.dev-bkpd \
	test report

#local-dev: @ pull in secrets from bke-vo-secrets repo
local-dev:
	mkdir secrets
	cp ../bke-vo-secrets/kubeconf/*.yaml ./secrets
	cp ../bke-vo-secrets/robot/*.txt ./secrets

#clean: @ clean local-dev secrets
clean:
	rm -rf ./secrets

#build: @ Build bkextest image
build: 
	docker build -t harbor.services.brown.edu/bkextest/bkextest -t harbor.cis-qas.brown.edu/bkextest/bkextest -t harbordr.services.brown.edu/bkextest/bkextest -t harbor.cis-dev.brown.edu/bkextest/bkextest ./

## Docker Logins

#dlogin.dev: @ dev docker login
dlogin.dev:
	cat secrets/robot-dev.txt | docker login -u 'bke-bkextest+bkextest' --password-stdin harbor.cis-dev.brown.edu

#dlogin.qa: @ qa docker login
dlogin.qa: 
	cat secrets/robot-qa.txt | docker login -u 'bke-bkextest+bkextest' --password-stdin harbor.cis-qas.brown.edu

#dlogin.prod: @ prod docker login
dlogin.prod: 
	cat secrets/robot-prod.txt | docker login -u 'bke-bkextest+bkextest' --password-stdin harbor.services.brown.edu

#dlogin.dr: @ dr docker login
dlogin.dr: 
	cat secrets/robot-dr.txt | docker login -u 'bke-bkextest+bkextest' --password-stdin harbordr.services.brown.edu

## Harbor push

#push.dev: @ Push to DEV harbor
push.dev: dlogin.dev
	docker push harbor.cis-dev.brown.edu/bkextest/bkextest

#push.qa: @ Push to QA harbor
push.qa: dlogin.qa
	docker push harbor.cis-qas.brown.edu/bkextest/bkextest

#push.prod: @ Push to Prod harbor
push.prod: dlogin.prod
	docker push harbor.services.brown.edu/bkextest/bkextest

#push.dr: @ Psh to DR harbor
push.dr: 	dlogin.dr
	docker push harbordr.services.brown.edu/bkextest/bkextest

#push: @ Push bkextest images to repos
push: push.qa push.prod push.dr

## Deploys

#deploy.dev-bkpi: @ dev-bkpi deploy
deploy.dev-bkpi: 
	kubectl apply -k ./dev-bkpi --kubeconfig=secrets/dev-bkpi.yaml
	echo "dbkeitest.virtorch.brown.edu"

#deploy.dev-bkpd: @ dev-bkpd deploy
deploy.dev-bkpd: 
	kubectl apply -k ./dev-bkpd --kubeconfig=secrets/dev-bkpd.yaml
	echo "dbkedtest.virtorch.brown.edu"

#deploy.qa-bkpd: @ qa-bkpd deploy
deploy.qa-bkpd: 
	kubectl apply -k ./qa-bkpd --kubeconfig=secrets/qa-bkpd.yaml
	echo "qbkedtest.virtorch.brown.edu"

#deploy.qa-bkpi: @ qa-bkpi deploy
deploy.qa-bkpi: 
	kubectl apply -k ./qa-bkpi --kubeconfig=secrets/qa-bkpi.yaml
	echo "qbkeitest.virtorch.brown.edu"

#deploy.bkpd: @ bkpd deploy
deploy.bkpd: 
	kubectl apply -k ./bkpd --kubeconfig=secrets/prod-bkpd.yaml
	echo "bkedtest.virtorch.brown.edu"

#deploy.bkpi: @ bkpi deploy
deploy.bkpi: 
	kubectl apply -k ./bkpi --kubeconfig=secrets/prod-bkpi.yaml
	echo "bkeitest.virtorch.brown.edu"

#deploy.bkpddr: @ bkpddr deploy
deploy.bkpddr: 
	kubectl apply -k ./bkpddr --kubeconfig=secrets/dr-bkpd.yaml
	echo "drbkedtest.virtorch.brown.edu"

#deploy.bkpidr: @ bkpidr deploy
deploy.bkpidr: 
	kubectl apply -k ./bkpidr --kubeconfig=secrets/dr-bkpi.yaml
	echo "drbkeitest.virtorch.brown.edu"

#deploy.prod: @ Deploy to PROD
deploy.prod: deploy.bkpd deploy.bkpi

#deploy.dr: @ Deploy to DR
deploy.dr: deploy.bkpddr deploy.bkpidr

#deploy.qa: @ Deploy to QA
deploy.qa: deploy.qa-bkpd  deploy.qa-bkpi

#deploy.dev: @ Deploy to DEV
deploy.dev: deploy.dev-bkpi deploy.dev-bkpd

#deploy: @ deploy bkeXtest app to all clusters
deploy: deploy.dev-bkpi deploy.dev-bkpd deploy.qa-bkpd  deploy.qa-bkpi deploy.bkpd deploy.bkpi deploy.bkpddr deploy.bkpidr deploy.dev-bkpd

## Deletes

#delete.dev-bkpi: @ dev-bkpi delete
delete.dev-bkpi: 
	-kubectl delete -k ./dev-bkpi --kubeconfig=secrets/dev-bkpi.yaml

#delete.dev-bkpd: @ dev-bkpd delete
delete.dev-bkpd: 
	-kubectl delete -k ./dev-bkpd --kubeconfig=secrets/dev-bkpd.yaml

#delete.qa-bkpd: @ qa-bkpd delete
delete.qa-bkpd: 
	-kubectl delete -k ./qa-bkpd --kubeconfig=secrets/qa-bkpd.yaml

#delete.qa-bkpi: @ qa-bkpi delete
delete.qa-bkpi: 
	-kubectl delete -k ./qa-bkpi --kubeconfig=secrets/qa-bkpi.yaml

#delete.bkpd: @ bkpd delete
delete.bkpd: 
	-kubectl delete -k ./bkpd --kubeconfig=secrets/prod-bkpd.yaml

#delete.bkpi: @ bkpi delete
delete.bkpi: 
	-kubectl delete -k ./bkpi --kubeconfig=secrets/prod-bkpi.yaml

#delete.bkpddr: @ bkpddr delete
delete.bkpddr: 
	-kubectl delete -k ./bkpddr --kubeconfig=secrets/dr-bkpd.yaml

#delete.bkpidr: @ bkpidr delete
delete.bkpidr: 
	-kubectl delete -k ./bkpidr --kubeconfig=secrets/dr-bkpi.yaml

#delete.prod: @ Delete PROD
delete.prod: delete.bkpd delete.bkpi

#delete.dr: @ Delete DR
delete.dr: delete.bkpddr delete.bkpidr

#delete.qa: @ Delete QA
delete.qa: delete.qa-bkpd delete.qa-bkpi

#delete.dev: @ Delete DEV
delete.dev: delete.dev-bkpd delete.dev-bkpi

#delete: @ delete bkeXtest app to all clusters
delete: delete.dev-bkpi delete.dev-bkpd delete.qa-bkpd delete.qa-bkpi delete.bkpd delete.bkpi delete.bkpddr delete.bkpidr

## Tests
#test: @ simple curl test of URLs
test: 
	@$(foreach serv, $(SERVS), echo -n "$(serv): "; curl -m 3 https://$(serv).virtorch.brown.edu; echo ""; )