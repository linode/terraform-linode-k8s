output "k8s_master_public_ip" {
  value = "${module.master_instance.linode_instance.instance.0.ip_address}"
}

output "kubeadm_join_command" {
  value = "${data.external.kubeadm_join.result["command"]}"
}