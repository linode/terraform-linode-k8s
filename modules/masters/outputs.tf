output "k8s_master_public_ip" {
  depends_on = ["module.master_instance"]
  value      = "${module.master_instance.master_public_ip}"
}

output "k8s_master_private_ip" {
  depends_on = ["module.master_instance"]
  value      = "${module.master_instance.master_private_ip}"
}

locals {
  result = {
    command = ""
  }

  kubeadm_join_results = "${concat(data.external.kubeadm_join.*.result, list(local.result))}"
  kubeadm_join_command = "${lookup(local.kubeadm_join_results["0"], "command", "")}"
}

output "kubeadm_join_command" {
  depends_on = ["null_resource.masters_provisioner"]
  value      = "${local.kubeadm_join_command}"
}

locals {
  result_key = {
    command = ""
  }

  kubeadm_certkey_results = "${concat(data.external.kubeadm_cert_key.*.result, list(local.result_key))}"
  kubeadm_certkey = "${lookup(local.kubeadm_certkey_results["0"], "cert-key", "")}"
}

output "kubeadm_cert_key" {
  depends_on = ["null_resource.masters_provisioner"]
  value      = "${local.kubeadm_certkey}"
}

output "label" {
  value   = "${module.master_instance.label}"
}