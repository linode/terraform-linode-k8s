provider "linode" {
  token   = var.linode_token
  version = "1.9.2"
}

provider "external" {
  version = "1.2.0"
}
