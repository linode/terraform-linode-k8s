terraform {
  required_providers {
    external = {
      source = "hashicorp/external"
    }
    linode = {
      source = "terraform-providers/linode"
    }
    null = {
      source = "hashicorp/null"
    }
  }
  required_version = ">= 0.13"
}
