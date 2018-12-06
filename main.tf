provider "linode" {
  token = "${var.linode_token}"
  version = "1.3.0"
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
    command    = "${path.module}/scripts/local/preflight.sh"
  }
}

module "masters" {
  source = "./modules/masters"
  label_prefix = "${terraform.workspace}"
  node_class = "master"
  node_count = "${var.masters}"
  node_type = "${var.server_type_master}"
}

module "nodes" {
  source = "./modules/nodes"
  label_prefix = "${terraform.workspace}"
  node_class = "node"
  node_count = "${var.nodes}"
  node_type = "${var.server_type_node}"
}


resource "null_resource" "local_kubectl" {
  depends_on = ["module.masters.module.master_instance.module.instances.linode_instance.instance.0"]

  provisioner "local-exec" {
    command    = "${path.module}/scripts/local/kubectl-conf.sh ${terraform.workspace} ${module.masters.master_instance.linode_instance.instance.0.ip_address} ${module.masters.master_instance.linode_instance.instance.0.private_ip_address} ${var.ssh_public_key}"
    on_failure = "continue"
  }
}