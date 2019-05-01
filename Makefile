.PHONY: init plan apply destroy test

export TF_INPUT=0
export TF_WORKSPACE=testing
export TF_IN_AUTOMATION=1

export TF_VAR_nodes=1
export TF_VAR_linode_token=$$LINODE_TOKEN

init:
	terraform init

plan:
	terraform plan

apply:
	terraform apply -auto-approve

destroy:
	terraform destroy -auto-approve

test: init plan apply destroy
