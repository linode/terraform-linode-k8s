module "addl-master" {
  source         = "../instances"
  label_prefix   = "${var.label_prefix}"
  node_type      = "${var.node_type}"
  node_count     = "${var.node_count}"
  master_type    = "addl-master"
  node_class     = "master"
  private_ip     = "true"
  ssh_public_key = "${var.ssh_public_key}"
  region         = "${var.region}"

  linode_group = "${var.linode_group}"

  k8s_version       = "${var.k8s_version}"
  k8s_feature_gates = "${var.k8s_feature_gates}"
  cni_version       = "${var.cni_version}"
  crictl_version    = "${var.crictl_version}"
}

resource "null_resource" "kubeadm_join" {
  count = "${var.node_count}"

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "export PATH=$${PATH}:/opt/bin",
      "sudo ${var.kubeadm_join_command} --experimental-control-plane --certificate-key ${var.kubeadm_cert_key}",
      "chmod +x /tmp/end.sh && sudo /tmp/end.sh",
    ]

    connection {
      host    = "${element(module.addl-master.instances_public_ip, count.index)}"
      user    = "core"
      timeout = "300s"
    }
  }
}
