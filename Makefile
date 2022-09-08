.DEFAULT_GOAL := help

#help:  @ List available tasks on this project
help:
	@grep -E '[a-zA-Z\.\-]+:.*?@ .*$$' $(MAKEFILE_LIST)| tr -d '#'  | awk 'BEGIN {FS = ":.*?@ "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

CLUSTERS ?= qa-bkpd qa-bkpi bkpd bkpi bkpddr bkpidr dev-bkpi dev-bkpd
SERVS ?= bkeitest bkedtest drbkeitest drbkedtest qbkeitest qbkedtest dbkeitest dbkedtest

#secrets: @ Files to decrypt
SECRET_FILES=$(shell cat .blackbox/blackbox-files.txt)
$(SECRET_FILES): %: %.gpg
	gpg --decrypt --quiet --no-tty --yes $< > $@

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

decrypt: files/bkpidr.yaml

#build: @ Build bkextest image
build: 
	docker build -t harbor.services.brown.edu/bkextest/bkextest -t harbor.cis-qas.brown.edu/bkextest/bkextest -t harbordr.services.brown.edu/bkextest/bkextest ./

## Docker Logins

#dlogin.qa: @ qa docker login
dlogin.qa: files/robot.qa
	cat files/robot.qa | docker login -u 'bke-bkextest+bkextest' --password-stdin harbor.cis-qas.brown.edu

#dlogin.prod: @ prod docker login
dlogin.prod: files/robot.prod
	cat files/robot.prod | docker login -u 'bke-bkextest+bkextest' --password-stdin harbor.services.brown.edu

#dlogin.dr: @ dr docker login
dlogin.dr: files/robot.dr
	cat files/robot.dr | docker login -u 'bke-bkextest+bkextest' --password-stdin harbordr.services.brown.edu

## Harbor push

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
deploy.dev-bkpi: files/dev-bkpi.yaml
	kubectl apply -k ./dev-bkpi --kubeconfig=files/dev-bkpi.yaml
	echo "dbkeitest.virtorch.brown.edu"

#deploy.dev-bkpd: @ dev-bkpd deploy
deploy.dev-bkpd: files/dev-bkpd.yaml
	kubectl apply -k ./dev-bkpd --kubeconfig=files/dev-bkpd.yaml
	echo "dbkedtest.virtorch.brown.edu"

#deploy.qa-bkpd: @ qa-bkpd deploy
deploy.qa-bkpd: files/qa-bkpd.yaml
	kubectl apply -k ./qa-bkpd --kubeconfig=files/qa-bkpd.yaml
	echo "qbkedtest.virtorch.brown.edu"

#deploy.qa-bkpi: @ qa-bkpi deploy
deploy.qa-bkpi: files/qa-bkpi.yaml
	kubectl apply -k ./qa-bkpi --kubeconfig=files/qa-bkpi.yaml
	echo "qbkeitest.virtorch.brown.edu"

#deploy.bkpd: @ bkpd deploy
deploy.bkpd: files/bkpd.yaml
	kubectl apply -k ./bkpd --kubeconfig=files/bkpd.yaml
	echo "bkedtest.virtorch.brown.edu"

#deploy.bkpi: @ bkpi deploy
deploy.bkpi: files/bkpi.yaml
	kubectl apply -k ./bkpi --kubeconfig=files/bkpi.yaml
	echo "bkeitest.virtorch.brown.edu"

#deploy.bkpddr: @ bkpddr deploy
deploy.bkpddr: files/bkpddr.yaml
	kubectl apply -k ./bkpddr --kubeconfig=files/bkpddr.yaml
	echo "drbkedtest.virtorch.brown.edu"

#deploy.bkpidr: @ bkpidr deploy
deploy.bkpidr: files/bkpidr.yaml
	kubectl apply -k ./bkpidr --kubeconfig=files/bkpidr.yaml
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
delete.dev-bkpi: files/dev-bkpi.yaml
	-kubectl delete -k ./dev-bkpi --kubeconfig=files/dev-bkpi.yaml

#delete.dev-bkpd: @ dev-bkpd delete
delete.dev-bkpd: files/dev-bkpd.yaml
	-kubectl delete -k ./dev-bkpd --kubeconfig=files/dev-bkpd.yaml

#delete.qa-bkpd: @ qa-bkpd delete
delete.qa-bkpd: files/qa-bkpd.yaml
	-kubectl delete -k ./qa-bkpd --kubeconfig=files/qa-bkpd.yaml

#delete.qa-bkpi: @ qa-bkpi delete
delete.qa-bkpi: files/qa-bkpi.yaml
	-kubectl delete -k ./qa-bkpi --kubeconfig=files/qa-bkpi.yaml

#delete.bkpd: @ bkpd delete
delete.bkpd: files/bkpd.yaml
	-kubectl delete -k ./bkpd --kubeconfig=files/bkpd.yaml

#delete.bkpi: @ bkpi delete
delete.bkpi: files/bkpi.yaml
	-kubectl delete -k ./bkpi --kubeconfig=files/bkpi.yaml

#delete.bkpddr: @ bkpddr delete
delete.bkpddr: files/bkpddr.yaml
	-kubectl delete -k ./bkpddr --kubeconfig=files/bkpddr.yaml

#delete.bkpidr: @ bkpidr delete
delete.bkpidr: files/bkpidr.yaml
	-kubectl delete -k ./bkpidr --kubeconfig=files/bkpidr.yaml

#delete.prod: @ Delete PROD
delete.prod: delete.bkpd delete.bkpi

#delete.dr: @ Delete DR
delete.dr: delete.bkpddr delete.bkpidr

#delete.qa: @ Delete QA
delete.qa: delete.qa-bkpd delete.qa-bkpi

#delete: @ delete bkeXtest app to all clusters
delete: delete.dev-bkpi delete.dev-bkpd delete.qa-bkpd delete.qa-bkpi delete.bkpd delete.bkpi delete.bkpddr delete.bkpidr

## Tests
#test: @ simple curl test of URLs
test: 
	@$(foreach serv, $(SERVS), echo -n "$(serv): "; curl -m 3 https://$(serv).virtorch.brown.edu; echo ""; )

#report: @ report on all clusters
report: files/qa-bkpi.yaml files/qa-bkpd.yaml files/bkpi.yaml files/bkpd.yaml files/bkpidr.yaml files/bkpddr.yaml files/dev-bkpi.yaml files/dev-bkpd.yaml
	@$(foreach file, $(CLUSTERS), kubectl get nodes --kubeconfig=files/$(file).yaml| grep Ready | wc -l ; )