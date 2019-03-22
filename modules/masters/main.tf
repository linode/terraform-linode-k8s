module "master_instance" {
  source       = "../instances"
  label_prefix = "${var.label_prefix}"
  node_type    = "${var.node_type}"
  node_count   = "1"                   // HA not supported yet
  node_class   = "master"
  linode_group = "${var.linode_group}"
  private_ip   = "true"
  use_public   = "true"                // rename this var, sent to kubeadm

  k8s_version       = "${var.k8s_version}"
  k8s_feature_gates = "${var.k8s_feature_gates}"
  cni_version       = "${var.cni_version}"
  ssh_public_key    = "${var.ssh_public_key}"
  region            = "${var.region}"
}

resource "null_resource" "masters_provisioner" {
  depends_on = ["module.master_instance"]

  provisioner "file" {
    source      = "${path.module}/manifests/"
    destination = "/tmp"

    connection {
      user    = "core"
      timeout = "300s"
      host    = "${module.master_instance.public_ip_address}"
    }
  }

  provisioner "remote-exec" {
    # TODO advertise on public adress
    inline = [
      "set -e",
      "chmod +x /tmp/kubeadm-init.sh && sudo /tmp/kubeadm-init.sh ${var.cluster_name} ${var.k8s_version} ${module.master_instance.public_ip_address} ${module.master_instance.private_ip_address} ${var.k8s_feature_gates}",
      "mkdir -p $HOME/.kube && sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config && sudo chown core $HOME/.kube/config",
      "export PATH=$${PATH}:/opt/bin",
      "kubectl apply -f /tmp/calico.yaml",
      "chmod +x /tmp/linode-addons.sh && /tmp/linode-addons.sh ${var.region} ${var.linode_token}",
      "chmod +x /tmp/monitoring-install.sh && /tmp/monitoring-install.sh",
      "chmod +x /tmp/ingress-install.sh && /tmp/ingress-install.sh",
      "chmod +x /tmp/end.sh && sudo /tmp/end.sh",
    ]

    connection {
      user    = "core"
      timeout = "300s"
      host    = "${module.master_instance.public_ip_address}"
    }
  }
}

data "external" "kubeadm_join" {
  program = ["${path.module}/scripts/local/kubeadm-token.sh"]

  query = {
    host = "${module.master_instance.public_ip_address}"
  }

  depends_on = ["null_resource.masters_provisioner"]
}
