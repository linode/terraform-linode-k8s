variable "node_count" {
  default = "1"
}

variable "group" {
  default = ""
}

variable "node_class" {
  default = "node"
}

variable "node_type" {
  default = "g-standard-4"
}

variable "private_ip" {
  default = true
}

variable "label_prefix" {
  default = ""
}

variable "kubeadm_join_command" {}
variable "region" {}
variable "ssh_public_key" {}
variable "linode_group" {}

variable "k8s_version" {}
variable "cni_version" {}
variable "k8s_feature_gates" {}
