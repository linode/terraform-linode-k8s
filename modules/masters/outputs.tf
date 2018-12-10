output "k8s_master_public_ip" {
  value = "${module.master_instance.public_ip_address}"
}

output "k8s_master_private_ip" {
  value = "${module.master_instance.private_ip_address}"
}

output "kubeadm_join_command" {
  value = "${data.external.kubeadm_join.result["command"]}"
}
