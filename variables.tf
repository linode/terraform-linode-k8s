variable "docker_version" {
  default     = "17.03.0~ce-0~ubuntu-xenial"
  description = "Use 17.12.0~ce-0~ubuntu for x86_64 and 17.03.0~ce-0~ubuntu-xenial for arm"
}

variable "kubeadm_version" {
  default = "1.11.3-00"
}

variable "k8s_version" {
  default = "stable-1.11"
}

variable "weave_passwd" {
  default = "ChangeMe"
}

variable "arch" {
  default     = "x86_64"
  description = "Values: arm arm64 x86_64"
}

variable "region" {
  default     = "eu-west"
  description = "Values: par1 ams1"
}

variable "server_type_master" {
  default     = "g6-standard-2"
  description = ""
}

variable "server_type_node" {
  default     = "g6-standard-1"
  description = ""
}

variable "nodes" {
  default = 1
}

variable "linode_group" {
  default = "k8-terraform-test"
}

variable "ssh_private_key" {
  type        = "string"
  default     = "~/.ssh/id_rsa"
  description = "The path to your private key"
}

variable "ssh_public_key" {
  type        = "string"
  default     = "~/.ssh/id_rsa.pub"
  description = "The path to your public key"
}

resource "random_string" "password" {
  length           = 16
  special          = true
  override_special = "/@\" "
}
