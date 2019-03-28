data "linode_instance_type" "type" {
  id = "${var.node_type}"
}

resource "linode_instance" "instance" {
  count      = "${var.node_count}"
  region     = "${var.region}"
  label      = "${var.label_prefix == "" ? "" : "${var.label_prefix}-"}${var.node_class}-${count.index + 1}"
  group      = "${var.linode_group}"
  type       = "${var.node_type}"
  private_ip = "${var.private_ip}"

  disk {
    label           = "boot"
    size            = "${data.linode_instance_type.type.disk}"
    authorized_keys = ["${chomp(file(var.ssh_public_key))}"]
    image           = "linode/containerlinux"
  }

  config {
    label = "${var.node_class}"

    kernel = "linode/direct-disk"

    devices {
      sda = {
        disk_label = "boot"
      }
    }
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/core/init/",
    ]

    connection {
      user    = "core"
      timeout = "300s"
    }
  }

  provisioner "file" {
    source      = "${path.module}/scripts/"
    destination = "/home/core/init/"

    connection {
      user    = "core"
      timeout = "300s"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "chmod +x /home/core/init/start.sh && sudo /home/core/init/start.sh",
      "chmod +x /home/core/init/linode-network.sh && sudo /home/core/init/linode-network.sh ${self.private_ip_address} ${self.label}",
      "chmod +x /home/core/init/kubeadm-install.sh && sudo /home/core/init/kubeadm-install.sh ${var.k8s_version} ${var.cni_version} ${self.label} ${var.use_public ? self.ip_address : self.private_ip_address} ${var.k8s_feature_gates}",
    ]

    connection {
      user    = "core"
      timeout = "300s"
    }
  }
}
