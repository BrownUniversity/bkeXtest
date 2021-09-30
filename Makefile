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

#build: Build bkextest image
build: 
	docker -t harbor.services.brown.edu/bkextest/bkextest -t harbor.cis-qas.brown.edu/bkextest/bkextest -t harbordr.services.brown.edu/bkextest/bkextest

#dlogin.qa:
dlogin.qa: files/robot.qa
	cat files/robot.qa | docker login -u 'bke-bkextest+bkextest' --password-stdin

#dlogin.prod:
dlogin.qa: files/robot.prod
	cat files/robot.prod | docker login -u 'bke-bkextest+bkextest' --password-stdin

#dlogin.dr:
dlogin.qa: files/robot.dr
	cat files/robot.dr | docker login -u 'bke-bkextest+bkextest' --password-stdin

#push.qa
push.qa: dlogin.qa
	docker push harbor.cis-qas.brown.edu/bkextest/bkextest

#push.prod
push.prod: dlogin.prod
	docker push harbor.services.brown.edu/bkextest/bkextest

#push.dr
push.dr: 	dlogin.dr
	docker push harbordr.services.brown.edu/bkextest/bkextest

#push: Push bkextest images to repos
push: push.qa push.prod push.dr




#deploy: deploy bkeXtest app to clusters
deploy: files/
	$(foreach cluster, $(CLUSTERS), kubectl apply -k ./$(cluster) --kubeconfig=files/$(cluster).yaml; )

