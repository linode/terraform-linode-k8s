output "k8s_master_public_ip" {
  depends_on = ["module.master_instance"]
  value      = "${module.master_instance.public_ip_address}"
}

output "k8s_master_private_ip" {
  depends_on = ["module.master_instance"]
  value      = "${module.master_instance.private_ip_address}"
}

output "kubeadm_join_command" {
  // depends_on = ["module.master_instance", "data.external.kubeadm_join"]
  value      = "${lookup(data.external.kubeadm_join.result, "command", "")}"
}
