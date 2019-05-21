module "addl-masters" {
  source       = "../addl-master"
  label_prefix = "${var.cluster_name == "" ? terraform.workspace : var.cluster_name}"
  node_class   = "master"
  node_count   = "${var.addl_master_count}"
  node_type    = "${var.node_type}"
  kubeadm_join_command = "${var.kubeadm_join_command}"
  kubeadm_cert_key  = "${var.kubeadm_cert_key}"
  k8s_version       = "${var.k8s_version}"
  crictl_version    = "${var.crictl_version}"
  k8s_feature_gates = "${var.k8s_feature_gates}"
  cni_version       = "${var.cni_version}"
  ssh_public_key    = "${var.ssh_public_key}"
  region            = "${var.region}"
  linode_group      = "${var.cluster_name}"
}

resource "linode_nodebalancer" "apiserver-nodebalancer" {
  label = "${var.cluster_name}"
  region = "${var.region}"
}

resource "linode_nodebalancer_config" "apiserver-nodebalancer-config" {
  nodebalancer_id = "${linode_nodebalancer.apiserver-nodebalancer.id}"
  port = 6443
  protocol = "tcp"
}

resource "linode_nodebalancer_node" "nodebalancer-node-master" {
  nodebalancer_id = "${linode_nodebalancer.apiserver-nodebalancer.id}"
  config_id = "${linode_nodebalancer_config.apiserver-nodebalancer-config.id}"
  label = "${var.master_label}"
  address = "${var.master_ip}:6443"
  mode = "accept"
}

resource "linode_nodebalancer_node" "nodebalancer-node-addl-master" {
  count = "${var.addl_master_count}"
  nodebalancer_id = "${linode_nodebalancer.apiserver-nodebalancer.id}"
  config_id = "${linode_nodebalancer_config.apiserver-nodebalancer-config.id}"
  label = "${element(module.addl-masters.label, count.index)}"
  address = "${element(module.addl-masters.addl_masters_private_ip, count.index)}:6443"
  mode = "accept"

  # The additional masters should be added to the loadbalancer after all of them are ready
  depends_on = ["module.addl-masters"]
}
