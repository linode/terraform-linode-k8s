resource "linode_instance" "k8s_node" {
  count      = "${var.nodes}"
  region     = "${var.region}"
  label      = "${terraform.workspace}-node-${count.index + 1}"
  group      = "${var.linode_group}"
  type       = "${var.server_type_node}"
  private_ip = true

  disk {
    label           = "boot"
    size            = 81920
    authorized_keys = ["${chomp(file(var.ssh_public_key))}"]
    root_pass       = "${random_string.password.result}"
    image           = "linode/containerlinux"
  }

  config {
    label  = "node"
    kernel = "linode/direct-disk"

    devices {
      sda = {
        disk_label = "boot"
      }
    }
  }

  provisioner "file" {
    source      = "scripts/"
    destination = "/tmp"

    connection {
      user    = "core"
      timeout = "30s"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "chmod +x /tmp/start.sh && sudo /tmp/start.sh",
      "chmod +x /tmp/linode-network.sh && sudo /tmp/linode-network.sh ${self.private_ip_address} ${self.label}",
      "chmod +x /tmp/kubeadm-install.sh && sudo /tmp/kubeadm-install.sh ${var.k8s_version} ${var.cni_version} ${self.label}",
      "export PATH=$${PATH}:/opt/bin",
      "chmod +x /tmp/kubeadm-join.sh && sudo /tmp/kubeadm-join.sh '${data.external.kubeadm_join.result.command}'",
      "chmod +x /tmp/end.sh && sudo /tmp/end.sh",
    ]

    connection {
      user    = "core"
      timeout = "30s"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "kubectl get pods --all-namespaces",
    ]

    on_failure = "continue"

    connection {
      user    = "core"
      timeout = "30s"
      host    = "${linode_instance.k8s_master.0.ip_address}"
    }
  }
}
