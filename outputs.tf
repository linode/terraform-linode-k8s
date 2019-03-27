output "k8s_master_public_ip" {
  description = "Public IP Address of the Kubernetes API Server"
  value       = "${module.masters.k8s_master_public_ip}"
}

output "kubeadm_join_command" {
  description = "kubeadm join command that can be used to add a node to the cluster"
  value       = "${module.masters.kubeadm_join_command}"
}

output "nodes_public_ip" {
  description = "Public IP Address of the worker nodes"
  value       = "${module.nodes.nodes_public_ip}"
}

output "kubectl_config" {
  description = "Filename of the Kubernetes config file"
  value       = "${terraform.workspace}.conf"
}
