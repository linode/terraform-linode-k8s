provider "linode" {
  version = "0.0.1"
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
    command    = "./scripts/local/preflight.sh"
  }
}