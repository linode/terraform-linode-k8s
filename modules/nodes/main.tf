module "node" {
  source         = "../instances"
  label_prefix   = "${var.label_prefix}"
  node_type      = "${var.node_type}"
  node_count     = "${var.node_count}"
  node_class     = "node"
  private_ip     = "true"
  ssh_public_key = "${var.ssh_public_key}"
  region         = "${var.region}"

  linode_group = "${var.linode_group}"

  k8s_version       = "${var.k8s_version}"
  k8s_feature_gates = "${var.k8s_feature_gates}"
  cni_version       = "${var.cni_version}"
}

// todo: does the use of var.kubeadm_join_command (from master output)  queue nodes behind masters? move to parent main.tf if so
resource "null_resource" "kubeadm_join" {
  count = "${var.node_count}"

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "export PATH=$${PATH}:/opt/bin",
      "sudo ${var.kubeadm_join_command}",
      "sudo KUBECONFIG=/etc/kubernetes/kubelet.conf kubectl annotate node $${HOSTNAME} --overwrite container-linux-update.v1.coreos.com/last-checked-time=$(date +'%s' -d 'tomorrow')",
      "chmod +x /tmp/end.sh && sudo /tmp/end.sh",
    ]

    connection {
      host    = "${element(module.node.nodes_public_ip, count.index)}"
      user    = "core"
      timeout = "300s"
    }
  }
}
