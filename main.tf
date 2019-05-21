provider "linode" {
  token   = "${var.linode_token}"
  version = "1.5.0"
}

provider "external" {
  version = "1.0.0"
}

resource "null_resource" "preflight-checks" {
  # Force re-run
  triggers {
    key = "${uuid()}"
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/local/preflight.sh"
  }
}

module "masters" {
  source       = "./modules/masters"
  label_prefix = "${var.cluster_name == "" ? terraform.workspace : var.cluster_name}"
  node_class   = "master"
  node_count   = "${var.masters}"
  node_type    = "${var.server_type_master}"
  linode_token = "${var.linode_token}"

  k8s_version       = "${var.k8s_version}"
  crictl_version    = "${var.crictl_version}"
  k8s_feature_gates = "${var.k8s_feature_gates}"
  cni_version       = "${var.cni_version}"
  ssh_public_key    = "${var.ssh_public_key}"
  region            = "${var.region}"
  linode_group      = "${var.cluster_name}"
  lb_ip             = "${module.loadbalancer.loadbalancer_ip}"

  //todo variable instead of workspace?
  cluster_name = "${var.cluster_name == "" ? terraform.workspace : var.cluster_name}"
}

module "nodes" {
  source       = "./modules/nodes"
  label_prefix = "${var.cluster_name == "" ? terraform.workspace : var.cluster_name}"
  node_class   = "node"
  node_count   = "${var.nodes}"
  node_type    = "${var.server_type_node}"

  k8s_version          = "${var.k8s_version}"
  crictl_version       = "${var.crictl_version}"
  k8s_feature_gates    = "${var.k8s_feature_gates}"
  cni_version          = "${var.cni_version}"
  ssh_public_key       = "${var.ssh_public_key}"
  region               = "${var.region}"
  linode_group         = "${var.cluster_name}"
  kubeadm_join_command = "${module.masters.kubeadm_join_command}"
}

module "loadbalancer" {
  source = "./modules/loadbalancer"
  addl_master_count = "${var.addl-masters}"
  cluster_name = "${var.cluster_name == "" ? terraform.workspace : var.cluster_name}"
  master_ip = "${module.masters.k8s_master_private_ip}"
  master_label = "${module.masters.label[0]}"
  label_prefix = "${var.cluster_name == "" ? terraform.workspace : var.cluster_name}"
  node_class   = "master"
  node_count   = "${var.addl-masters}"
  node_type    = "${var.server_type_master}"
  kubeadm_join_command = "${module.masters.kubeadm_join_command}"
  kubeadm_cert_key  = "${module.masters.kubeadm_cert_key}"
  k8s_version       = "${var.k8s_version}"
  crictl_version    = "${var.crictl_version}"
  k8s_feature_gates = "${var.k8s_feature_gates}"
  cni_version       = "${var.cni_version}"
  ssh_public_key    = "${var.ssh_public_key}"
  region            = "${var.region}"
  linode_group      = "${var.cluster_name}"
}

resource "null_resource" "local_kubectl" {
  // todo
  depends_on = ["module.masters"]

  provisioner "local-exec" {
    command    = "${path.module}/scripts/local/kubectl-conf.sh ${terraform.workspace} ${module.masters.k8s_master_public_ip} ${module.masters.k8s_master_private_ip} ${var.ssh_public_key}"
    on_failure = "continue"
  }
}

resource "null_resource" "update-agent" {
  depends_on = ["module.masters", "module.nodes"]

  triggers {
    cluster_ips = "${"${module.masters.k8s_master_public_ip} ${join(" ", module.nodes.nodes_public_ip)}"}"
  }

  provisioner "remote-exec" {
    connection {
      host = "${module.masters.k8s_master_public_ip}"
      user = "core"
    }

    inline = ["/opt/bin/kubectl annotate node --all --overwrite container-linux-update.v1.coreos.com/reboot-paused=${var.update_agent_reboot_paused}"]
  }
}
