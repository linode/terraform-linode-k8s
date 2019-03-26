output "k8s_master_public_ip" {
  value = "${module.masters.k8s_master_public_ip}"
}

output "kubeadm_join_command" {
  value     = "${module.masters.kubeadm_join_command}"
  sensitive = true
}

output "nodes_public_ip" {
  value = "${module.nodes.nodes_public_ip}"
}

output "kubectl_config" {
  value = "${terraform.workspace}.conf"
}
