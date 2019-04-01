output "k8s_master_public_ip" {
  depends_on  = ["module.master_instance"]
  description = "Public IP Address of the master node"
  value       = "${module.master_instance.public_ip_address}"
}

output "k8s_master_private_ip" {
  depends_on  = ["module.master_instance"]
  description = "Private IP Address of the master node"
  value       = "${module.master_instance.private_ip_address}"
}

locals {
  result = {
    command = ""
  }

  kubeadm_join_results = "${concat(data.external.kubeadm_join.*.result, list(local.result))}"
  kubeadm_join_command = "${lookup(local.kubeadm_join_results["0"], "command", "")}"
}

output "kubeadm_join_command" {
  depends_on  = ["null_resource.masters_provisioner"]
  description = "kubeadm join command that can be used to add a node to the cluster"
  value       = "${local.kubeadm_join_command}"
}
