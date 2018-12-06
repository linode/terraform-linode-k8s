module "master_instance" {
    source = "../instances"
    label_prefix = "${var.label_prefix}"
    node_type = "${var.node_type}"
    node_count = "1" // HA not supported yet
    node_class = "master"
    group = "${var.group}"
    private_ip = "true"
    use_public = "true" // rename this var, sent to kubeadm
}

resource "null_resource" "masters_provisioner" {
    depends_on = [ "module.master_instance.linode_instance.instance"]
  provisioner "file" {
    source      = "${path.module}/manifests/"
    destination = "/tmp"

    connection {
      user    = "core"
      timeout = "300s"
    }
  }

  provisioner "remote-exec" {
    # TODO advertise on public adress
    inline = [
      "set -e",
      "chmod +x /tmp/kubeadm-init.sh && sudo /tmp/kubeadm-init.sh ${var.cluster_name} ${var.k8s_version} ${module.master_instance.linode_instance.instance.ip_address} ${module.master_instance.linode_instance.instance.private_ip_address} ${var.k8s_feature_gates}",
      "mkdir -p $HOME/.kube && sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config && sudo chown core $HOME/.kube/config",
      "export PATH=$${PATH}:/opt/bin",
      "kubectl apply -f /tmp/calico.yaml",
      "chmod +x /tmp/linode-addons.sh && /tmp/linode-addons.sh ${module.master_instance.linode_instance.instance.region} ${var.linode_token}",
      "chmod +x /tmp/monitoring-install.sh && /tmp/monitoring-install.sh",
      "chmod +x /tmp/end.sh && sudo /tmp/end.sh",
    ]

    connection {
      user    = "core"
      timeout = "300s"
    }
  }

}

data "external" "kubeadm_join" {
  program = ["${path.module}/scripts/kubeadm-token.sh"]

  query = {
    host = "${module.master_instance.linode_instance.instance.0.ip_address}"
  }

  depends_on = ["module.master_instance.linode_instance.instance.0"]
}
