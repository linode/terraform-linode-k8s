provider "linode" {
  token = "${var.linode_token}"
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
