locals {
  root_user = "root"

  ubuntu_images = {
    "16.04" : "linode/ubuntu16.04lts",
    "18.04" : "linode/ubuntu18.04",
    "20.04" : "linode/ubuntu20.04",
  }
}

resource "linode_instance" "instance" {
  count      = var.node_count
  region     = var.region
  label      = "${var.label_prefix == "" ? "" : "${var.label_prefix}-"}${var.node_class}-${count.index + 1}"
  group      = var.linode_group
  type       = var.node_type
  private_ip = var.private_ip

  authorized_keys = [chomp(file(var.ssh_public_key))]
  image           = local.ubuntu_images[var.ubuntu_version]

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /root/init/",
    ]

    connection {
      host    = self.ip_address
      user    = local.root_user
      timeout = "300s"
    }
  }

  provisioner "file" {
    source      = "${path.cwd}/${path.module}/scripts/"
    destination = "/root/init/"

    connection {
      host    = self.ip_address
      user    = local.root_user
      timeout = "300s"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "chmod +x /root/init/start.sh && sudo /root/init/start.sh",
      "chmod +x /root/init/linode-network.sh && sudo /root/init/linode-network.sh ${self.private_ip_address} ${self.label}",
      "chmod +x /root/init/kubeadm-install.sh && sudo /root/init/kubeadm-install.sh \"${var.k8s_version}\" \"${var.cni_version}\" \"${var.crictl_version}\" \"${self.label}\" \"${var.use_public ? self.ip_address : self.private_ip_address}\" \"${var.k8s_feature_gates}\" \"${var.docker_version}\"",
    ]

    connection {
      host    = self.ip_address
      user    = local.root_user
      timeout = "300s"
    }
  }
}
