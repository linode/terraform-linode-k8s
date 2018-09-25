output "k8s_master_public_ip" {
  value = "${linode_instance.k8s_master.0.ip_address}"
}

output "kubeadm_join_command" {
  value = "${data.external.kubeadm_join.result["command"]}"
}

output "nodes_public_ip" {
  value = "${concat(linode_instance.k8s_node.*.label, linode_instance.k8s_node.*.ip_address)}"
}

output "kubectl_config" {
  value = "${terraform.workspace}.conf"
}
