module "master_instance" {
  source       = "../instances"
  label_prefix = var.label_prefix
  node_type    = var.node_type
  node_count   = "1" // HA not supported yet
  node_class   = "master"
  linode_group = var.linode_group
  private_ip   = "true"
  use_public   = "true" // rename this var, sent to kubeadm

  k8s_version       = var.k8s_version
  k8s_feature_gates = var.k8s_feature_gates
  cni_version       = var.cni_version
  crictl_version    = var.crictl_version
  ssh_public_key    = var.ssh_public_key
  region            = var.region
}

resource "null_resource" "masters_provisioner" {
  depends_on = [module.master_instance]

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/core/init/",
    ]

    connection {
      user    = "core"
      timeout = "300s"
      host    = module.master_instance.public_ip_address
    }
  }

  provisioner "file" {
    source      = "${path.cwd}/${path.module}/manifests/"
    destination = "/home/core/init/"

    connection {
      user    = "core"
      timeout = "300s"
      host    = module.master_instance.public_ip_address
    }
  }

  provisioner "remote-exec" {
    # TODO advertise on public adress
    inline = [
      "set -e",
      "chmod +x /home/core/init/kubeadm-init.sh && sudo /home/core/init/kubeadm-init.sh ${var.cluster_name} ${var.k8s_version} ${module.master_instance.public_ip_address} ${module.master_instance.private_ip_address} ${var.k8s_feature_gates}",
      "mkdir -p $HOME/.kube && sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config && sudo chown core $HOME/.kube/config",
      "export PATH=$${PATH}:/opt/bin",
      "kubectl apply -f /home/core/init/calico.yaml",
      "chmod +x /home/core/init/linode-addons.sh && /home/core/init/linode-addons.sh ${var.region} ${var.linode_token}",
      "chmod +x /home/core/init/monitoring-install.sh && /home/core/init/monitoring-install.sh",
      "chmod +x /home/core/init/update-operator.sh && /home/core/init/update-operator.sh",
      "kubectl annotate node $${HOSTNAME} --overwrite container-linux-update.v1.coreos.com/reboot-paused=true",
      "chmod +x /home/core/init/end.sh && sudo /home/core/init/end.sh",
    ]

    connection {
      user    = "core"
      timeout = "300s"
      host    = module.master_instance.public_ip_address
    }
  }
}

data "external" "kubeadm_join" {
  program = ["${path.cwd}/${path.module}/scripts/local/kubeadm-token.sh"]

  query = {
    host = module.master_instance.public_ip_address
  }

  depends_on = [null_resource.masters_provisioner]
}
