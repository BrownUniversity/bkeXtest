.DEFAULT_GOAL := help

#help:  @ List available tasks on this project
help:
	@grep -E '[a-zA-Z\.\-]+:.*?@ .*$$' $(MAKEFILE_LIST)| tr -d '#'  | awk 'BEGIN {FS = ":.*?@ "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

CLUSTERS ?= qa-bkpd qa-bkpi bkpd bkpi bkpddr bkpidr

#secrets: @ Files to decrypt
SECRET_FILES=$(shell cat .blackbox/blackbox-files.txt)
$(SECRET_FILES): %: %.gpg
	gpg --decrypt --quiet --no-tty --yes $< > $@

.PHONY: $(SECRET_FILES)

#build: @ Build bkextest image
build: 
	docker -t harbor.services.brown.edu/bkextest/bkextest -t harbor.cis-qas.brown.edu/bkextest/bkextest -t harbordr.services.brown.edu/bkextest/bkextest

## Docker Logins

#dlogin.qa: @ qa docker login
dlogin.qa: files/robot.qa
	cat files/robot.qa | docker login -u 'bke-bkextest+bkextest' --password-stdin

#dlogin.prod: @ prod docker login
dlogin.prod: files/robot.prod
	cat files/robot.prod | docker login -u 'bke-bkextest+bkextest' --password-stdin

#dlogin.dr: @ dr docker login
dlogin.dr: files/robot.dr
	cat files/robot.dr | docker login -u 'bke-bkextest+bkextest' --password-stdin


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

#deploy.qa-bkpd: @ qa-bkpd deploy
deploy.qa-bkpd: files/qa-bkpd.yaml
	kubectl apply -k ./qa-bkpd --kubeconfig=files/qa-bkpd.yaml

#deploy.qa-bkpi: @ qa-bkpi deploy
deploy.qa-bkpi: files/qa-bkpi.yaml
	kubectl apply -k ./qa-bkpi --kubeconfig=files/qa-bkpi.yaml

#deploy.bkpd: @ bkpd deploy
deploy.bkpd: files/bkpd.yaml
	kubectl apply -k ./bkpd --kubeconfig=files/bkpd.yaml

#deploy.bkpi: @ bkpi deploy
deploy.bkpi: files/bkpi.yaml
	kubectl apply -k ./bkpi --kubeconfig=files/bkpi.yaml

#deploy.bkpddr: @ bkpddr deploy
deploy.bkpddr: files/bkpddr.yaml
	kubectl apply -k ./bkpddr --kubeconfig=files/bkpddr.yaml

#deploy.bkpidr: @ bkpidr deploy
deploy.bkpidr: files/bkpidr.yaml
	kubectl apply -k ./bkpidr --kubeconfig=files/bkpidr.yaml

#deploy: @ deploy bkeXtest app to all clusters
deploy: deploy.qa-bkpd  deploy.qa-bkpi deploy.bkpd deploy.bkpi deploy.bkpddr deploy.bkpidr

