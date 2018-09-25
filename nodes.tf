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

  provisioner file {
    source      = "config/sshd_config"
    destination = "/etc/ssh/sshd_config"
  }

  provisioner remote-exec {
    inline = [
      "systemctl restart sshd",
    ]
  }

  provisioner "file" {
    source      = "scripts/docker-install.sh"
    destination = "/tmp/docker-install.sh"
  }

  provisioner "file" {
    source      = "scripts/kubeadm-install.sh"
    destination = "/tmp/kubeadm-install.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "chmod +x /tmp/start.sh && sudo /tmp/start.sh",
      "chmod +x /tmp/linode-network.sh && sudo /tmp/linode-network.sh ${self.private_ip_address} ${self.label}",
      "chmod +x /tmp/kubeadm-install.sh && sudo /tmp/kubeadm-install.sh ${var.k8s_version} ${var.cni_version} ${self.label}",
      "${data.external.kubeadm_join.result.command}",
      "chmod +x /tmp/end.sh && sudo /tmp/end.sh",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "kubectl get pods --all-namespaces",
    ]

    on_failure = "continue"

    connection {
      type = "ssh"
      user = "root"
      host = "${linode_instance.k8s_master.0.ip_address}"
    }
  }
}
