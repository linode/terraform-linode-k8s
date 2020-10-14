.PHONY: init plan apply destroy test

.EXPORT_ALL_VARIABLES:

TF_INPUT = 0
TF_WORKSPACE = testing
TF_IN_AUTOMATION = 1
TF_VAR_nodes = 1
TF_VAR_linode_token = ${LINODE_TOKEN}

init:
	terraform init

lint:
	terraform fmt -recursive -check -diff .

plan: check-token
	terraform plan

apply: check-token
	terraform apply -auto-approve

destroy: check-token
	terraform destroy -auto-approve

test: lint init plan apply destroy

check-token:
	@if test "$(LINODE_TOKEN)" = "" ; then \
	  echo "LINODE_TOKEN must be set"; \
	  exit 1; \
	fi
