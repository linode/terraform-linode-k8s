terraform {
  required_providers {
    external = {
      source  = "hashicorp/external"
      version = "~> 2.0.0"
    }
    linode = {
      source  = "linode/linode"
      version = "~> 1.16.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0.0"
    }
  }
  required_version = ">= 0.13"
}
