resource "linode_instance" "k8s_master" {
  count      = 1
  region     = "${var.region}"
  label      = "${terraform.workspace}-master-${count.index + 1}"
  group      = "${var.linode_group}"
  type       = "${var.server_type_master}"
  private_ip = true

  disk {
    label           = "boot"
    size            = 81920
    authorized_keys = ["${chomp(file(var.ssh_public_key))}"]
    image           = "linode/containerlinux"
  }

  config {
    label = "master"

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
      timeout = "300s"
    }
  }

  provisioner "file" {
    source      = "addons/"
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
      "chmod +x /tmp/start.sh && sudo /tmp/start.sh",
      "chmod +x /tmp/master-iptables.sh && sudo /tmp/master-iptables.sh",
      "chmod +x /tmp/linode-network.sh && sudo /tmp/linode-network.sh ${self.private_ip_address} ${self.label}",
      "chmod +x /tmp/kubeadm-install.sh && sudo /tmp/kubeadm-install.sh ${var.k8s_version} ${var.cni_version} ${self.label} ${self.ip_address}",
      "chmod +x /tmp/kubeadm-init.sh && sudo /tmp/kubeadm-init.sh ${self.ip_address} ${self.private_ip_address}",
      "mkdir -p $HOME/.kube && sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config && sudo chown core $HOME/.kube/config",
      "export PATH=$${PATH}:/opt/bin",
      "kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.10.0/Documentation/kube-flannel.yml",
      "chmod +x /tmp/linode-addons.sh && /tmp/linode-addons.sh ${self.region} ${var.linode_token}",
      "chmod +x /tmp/monitoring-install.sh && /tmp/monitoring-install.sh",
      "chmod +x /tmp/end.sh && sudo /tmp/end.sh",
    ]

    connection {
      user    = "core"
      timeout = "300s"
    }
  }

  provisioner "local-exec" {
    command    = "${path.module}/scripts/kubectl-conf.sh ${terraform.workspace} ${self.ip_address} ${self.private_ip_address} ${var.ssh_public_key}"
    on_failure = "continue"
  }
}

data "external" "kubeadm_join" {
  program = ["${path.module}/scripts/kubeadm-token.sh"]

  query = {
    host = "${linode_instance.k8s_master.0.ip_address}"
  }

  depends_on = ["linode_instance.k8s_master"]
}
