provider "linode" {
  token   = var.linode_token
  version = "1.7.0"
}

provider "external" {
  version = "1.1.0"
}

resource "null_resource" "preflight-checks" {
  # Force re-run
  triggers = {
    key = uuid()
  }
  provisioner "local-exec" {
    command    = "${path.cwd}/${path.module}/scripts/local/preflight.sh ${var.ccm_image} ${var.csi_image}"
    working_dir = "${path.cwd}/${path.module}"
  }
}
