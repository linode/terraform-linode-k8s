resource "linode_instance" "k8s_node" {
  count  = "${var.nodes}"
  region = "${var.region}"
  label  = "${terraform.workspace}-node-${count.index + 1}"
  group  = "${var.linode_group}"
  type   = "${var.server_type_node}"

  private_ip = true

  disk {
    label           = "boot"
    size            = 81920
    authorized_keys = ["${chomp(file(var.ssh_public_key))}"]
    root_pass       = "${random_string.password.result}"
    image           = "linode/ubuntu16.04lts"
  }

  config {
    label  = "node"
    kernel = "linode/grub2"

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
      "chmod +x /tmp/docker-install.sh && /tmp/docker-install.sh ${var.docker_version}",
      "chmod +x /tmp/kubeadm-install.sh && /tmp/kubeadm-install.sh ${var.kubeadm_version}",
      "${data.external.kubeadm_join.result.command}",
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
