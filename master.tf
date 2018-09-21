resource "linode_instance" "k8s_master" {
  count  = 1
  region = "${var.region}"
  label  = "${terraform.workspace}-master-${count.index + 1}"
  group  = "${var.linode_group}"
  type   = "${var.server_type_master}"

  private_ip = true

  disk {
    label           = "boot"
    size            = 81920
    authorized_keys = ["${chomp(file(var.ssh_public_key))}"]
    root_pass       = "${random_string.password.result}"
    image           = "linode/ubuntu16.04lts"
  }

  config {
    label  = "master"
    kernel = "linode/grub2"

    devices {
      sda = {
        disk_label = "boot"
      }
    }
  }

  //  volume {
  //    size_in_gb = 50
  //    type       = "l_ssd"
  //  }

  connection {
    type        = "ssh"
    user        = "root"
    private_key = "${file(var.ssh_private_key)}"
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
    source      = "scripts/"
    destination = "/tmp"
  }
  provisioner "file" {
    source      = "addons/"
    destination = "/tmp"
  }
  provisioner "remote-exec" {
    # TODO advertise on public adress
    inline = [
      "set -e",
      "chmod +x /tmp/docker-install.sh && /tmp/docker-install.sh ${var.docker_version}",
      "chmod +x /tmp/kubeadm-install.sh && /tmp/kubeadm-install.sh ${var.kubeadm_version}",
      "kubeadm init --apiserver-advertise-address=${self.private_ip_address} --apiserver-cert-extra-sans=${self.ip_address}",
      "mkdir -p $HOME/.kube && cp -i /etc/kubernetes/admin.conf $HOME/.kube/config",
      "kubectl create secret -n kube-system generic weave-passwd --from-literal=weave-passwd=${var.weave_passwd}",
      "kubectl apply -f \"https://cloud.weave.works/k8s/net?password-secret=weave-passwd&k8s-version=$(kubectl version | base64 | tr -d '\n')\"",
      "chmod +x /tmp/monitoring-install.sh && /tmp/monitoring-install.sh ${var.arch} 2>&1 | tee /tmp/monitoring-install.log",
    ]
  }
  provisioner "local-exec" {
    command    = "./scripts/kubectl-conf.sh ${terraform.workspace} ${self.ip_address} ${self.private_ip_address}"
    on_failure = "continue"
  }
}

data "external" "kubeadm_join" {
  program = ["./scripts/kubeadm-token.sh"]

  query = {
    host = "${linode_instance.k8s_master.0.ip_address}"
  }

  depends_on = ["linode_instance.k8s_master"]
}
