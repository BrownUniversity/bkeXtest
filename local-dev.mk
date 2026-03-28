#local-check: @ Using the LOCALDEV=y var will pull secrets to local files.
LOCALDEV ?= no
ifeq ($(LOCALDEV), $(filter $(LOCALDEV), y Y yes Yes True true))
local-check:
	mkdir secrets
	op read op://ozxznermh2dq4gbh55do65oq7e/npjh733tyzkabzayuav7acwaiy/credential > secrets/robot-dev.txt
	op read op://ozxznermh2dq4gbh55do65oq7e/d3thgre3wspmoxld6mlazplnhy/credential > secrets/robot-qa.txt
	op read op://ozxznermh2dq4gbh55do65oq7e/i7jtsx3ebey2oabehgft2os46e/credential > secrets/robot-dr.txt
	op read op://ozxznermh2dq4gbh55do65oq7e/rdy73megsttd5bmfusa7ngeiqe/credential > secrets/robot-prod.txt
	op read op://ozxznermh2dq4gbh55do65oq7e/tsiwmcw7ah3urm3hh3jtixsqc4/dev-bkei.yaml > secrets/dev-bkei.yaml
	op read op://ozxznermh2dq4gbh55do65oq7e/mhm3722zxoyp6tn5osntrcsptq/dev-bked.yaml > secrets/dev-bked.yaml
	op read op://ozxznermh2dq4gbh55do65oq7e/x6xih2sdzstjcwna4xnhfwyqru/qa-bkei.yaml > secrets/qa-bkei.yaml
	op read op://ozxznermh2dq4gbh55do65oq7e/fslejjfdbkkor2cpn7kfxa2hua/qa-bked.yaml > secrets/qa-bked.yaml
	op read op://ozxznermh2dq4gbh55do65oq7e/li75xnokbtcydhq6cozgb4a6z4/dr-bkei.yaml > secrets/dr-bkei.yaml
	op read op://ozxznermh2dq4gbh55do65oq7e/vblcf726cyjcai6mevaxmjg5ra/dr-bked.yaml > secrets/dr-bked.yaml
	op read op://ozxznermh2dq4gbh55do65oq7e/p3prcq4ibc4ped7hhace22uv7a/prod-bkei.yaml > secrets/prod-bkei.yaml
	op read op://ozxznermh2dq4gbh55do65oq7e/kmvnborkdzg2xrq5y5hayglrse/prod-bked.yaml > secrets/prod-bked.yaml
else
local-check: ;
endif

#clean: @ clean local-dev secrets
clean:
	rm -rf ./secrets