.DEFAULT_GOAL := help

#help:  @ List available tasks on this project
help:
	@grep -E '[a-zA-Z\.\-]+:.*?@ .*$$' $(MAKEFILE_LIST)| tr -d '#'  | awk 'BEGIN {FS = ":.*?@ "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

CLUSTERS ?= qa-bked qa-bkei bked bkei bkeddr bkeidr dev-bkei dev-bked
SERVS ?= bkeitest bkedtest drbkeitest drbkedtest qbkeitest qbkedtest dbkeitest dbkedtest

.PHONY: build dlogin.qa dlogin.prod dlogin.dr \
	push.qa push.prod push.dr \
	deploy.qa-bked deploy.qa-bkei \
	deploy.bked deploy.bkei \
	deploy.bkeddr deploy.bkeidr \
	deploy.dev-bkei deploy.dev-bked \
	delete.qa-bked delete.qa-bkei \
	delete.bked delete.bkei \
	delete.bkeddr delete.bkeidr \
	delete.dev-bkei delete.dev-bked \
	test report

#local-dev: @ pull in secrets from bke-vo-secrets repo
local-dev:
	git clone git@github.com:BrownUniversity/bke-vo-secrets.git 
	cd bke-vo-secrets && make secrets
	mkdir secrets
	cp ./bke-vo-secrets/kubeconf/*.yaml ./secrets
	cp ./bke-vo-secrets/robot/*.txt ./secrets

#clean: @ clean local-dev secrets
clean:
	rm -rf ./secrets
	rm -rf ./bke-vo-secrets

#build: @ Build bkextest image
build: 
	docker build --load -t harbor.services.brown.edu/bkextest/bkextest -t harbor.cis-qas.brown.edu/bkextest/bkextest -t harbordr.services.brown.edu/bkextest/bkextest -t harbor.cis-dev.brown.edu/bkextest/bkextest ./

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

#deploy.dev-bkei: @ dev-bkei deploy
deploy.dev-bkei: 
	kubectl apply -k ./dev-bkei --kubeconfig=secrets/dev-bkei.yaml
	echo "dbkeitest.virtorch.brown.edu"

#deploy.dev-bked: @ dev-bked deploy
deploy.dev-bked: 
	kubectl apply -k ./dev-bked --kubeconfig=secrets/dev-bked.yaml
	echo "dbkedtest.virtorch.brown.edu"

#deploy.qa-bked: @ qa-bked deploy
deploy.qa-bked: 
	kubectl apply -k ./qa-bked --kubeconfig=secrets/qa-bked.yaml
	echo "qbkedtest.virtorch.brown.edu"

#deploy.qa-bkei: @ qa-bkei deploy
deploy.qa-bkei: 
	kubectl apply -k ./qa-bkei --kubeconfig=secrets/qa-bkei.yaml
	echo "qbkeitest.virtorch.brown.edu"

#deploy.bked: @ bked deploy
deploy.bked: 
	kubectl apply -k ./bked --kubeconfig=secrets/prod-bked.yaml
	echo "bkedtest.virtorch.brown.edu"

#deploy.bkei: @ bkei deploy
deploy.bkei: 
	kubectl apply -k ./bkei --kubeconfig=secrets/prod-bkei.yaml
	echo "bkeitest.virtorch.brown.edu"

#deploy.bkeddr: @ bkeddr deploy
deploy.bkeddr: 
	kubectl apply -k ./bkeddr --kubeconfig=secrets/dr-bked.yaml
	echo "drbkedtest.virtorch.brown.edu"

#deploy.bkeidr: @ bkeidr deploy
deploy.bkeidr: 
	kubectl apply -k ./bkeidr --kubeconfig=secrets/dr-bkei.yaml
	echo "drbkeitest.virtorch.brown.edu"

#deploy.prod: @ Deploy to PROD
deploy.prod: deploy.bked deploy.bkei

#deploy.dr: @ Deploy to DR
deploy.dr: deploy.bkeddr deploy.bkeidr

#deploy.qa: @ Deploy to QA
deploy.qa: deploy.qa-bked  deploy.qa-bkei

#deploy.dev: @ Deploy to DEV
deploy.dev: deploy.dev-bkei deploy.dev-bked

#deploy: @ deploy bkeXtest app to all clusters
deploy: deploy.dev-bkei deploy.dev-bked deploy.qa-bked  deploy.qa-bkei deploy.bked deploy.bkei deploy.bkeddr deploy.bkeidr deploy.dev-bked

## Deletes

#delete.dev-bkei: @ dev-bkei delete
delete.dev-bkei: 
	-kubectl delete -k ./dev-bkei --kubeconfig=secrets/dev-bkei.yaml

#delete.dev-bked: @ dev-bked delete
delete.dev-bked: 
	-kubectl delete -k ./dev-bked --kubeconfig=secrets/dev-bked.yaml

#delete.qa-bked: @ qa-bked delete
delete.qa-bked: 
	-kubectl delete -k ./qa-bked --kubeconfig=secrets/qa-bked.yaml

#delete.qa-bkei: @ qa-bkei delete
delete.qa-bkei: 
	-kubectl delete -k ./qa-bkei --kubeconfig=secrets/qa-bkei.yaml

#delete.bked: @ bked delete
delete.bked: 
	-kubectl delete -k ./bked --kubeconfig=secrets/prod-bked.yaml

#delete.bkei: @ bkei delete
delete.bkei: 
	-kubectl delete -k ./bkei --kubeconfig=secrets/prod-bkei.yaml

#delete.bkeddr: @ bkeddr delete
delete.bkeddr: 
	-kubectl delete -k ./bkeddr --kubeconfig=secrets/dr-bked.yaml

#delete.bkeidr: @ bkeidr delete
delete.bkeidr: 
	-kubectl delete -k ./bkeidr --kubeconfig=secrets/dr-bkei.yaml

#delete.prod: @ Delete PROD
delete.prod: delete.bked delete.bkei

#delete.dr: @ Delete DR
delete.dr: delete.bkeddr delete.bkeidr

#delete.qa: @ Delete QA
delete.qa: delete.qa-bked delete.qa-bkei

#delete.dev: @ Delete DEV
delete.dev: delete.dev-bked delete.dev-bkei

#delete: @ delete bkeXtest app to all clusters
delete: delete.dev-bkei delete.dev-bked delete.qa-bked delete.qa-bkei delete.bked delete.bkei delete.bkeddr delete.bkeidr

## Tests
#test: @ simple curl test of URLs
test: 
	@$(foreach serv, $(SERVS), echo -n "$(serv): "; curl -m 3 https://$(serv).virtorch.brown.edu; echo ""; )