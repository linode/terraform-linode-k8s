variable "node_count" {
  default = "1"
}

variable "node_class" {
  default = "node"
}

variable "node_type" {
  default = "g6-standard-4"
}

variable "private_ip" {
  default = true
}

variable "label_prefix" {
  default = ""
}

variable "use_public" {
  default = false
}

variable "cni_version" {}
variable "ssh_public_key" {}
variable "region" {}

variable "linode_group" {
  default = ""
}

variable "k8s_version" {}
variable "k8s_feature_gates" {}
