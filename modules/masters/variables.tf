variable "node_count" {
  default = "1"
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

variable "linode_token" {
  description = "Linode Token used for CSI, CCM, an other Linode addons in the cluster"
}

variable "k8s_version" {}
variable "cni_version" {}
variable "cluster_name" {}
variable "ssh_public_key" {}

variable "linode_group" {
  default = ""
}

variable "k8s_feature_gates" {}
variable "region" {}
