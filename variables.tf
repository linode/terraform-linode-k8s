variable "cni_version" {
  default     = "v0.6.0"
  description = "Container Network Plugin Version"
}

variable "k8s_version" {
  default = "v1.13.6"
}

variable "k8s_feature_gates" {
  default = "CSINodeInfo=true,CSIDriverRegistry=true,BlockVolume=true,CSIBlockVolume=true"
}

variable "region" {
  default     = "eu-west"
  description = "Values: us-east ap-east"
}

variable "server_type_master" {
  default     = "g6-standard-2"
  description = "Values: g6-standard-2 g6-standard-4"
}

variable "server_type_node" {
  default     = "g6-standard-2"
  description = "Values: g6-standard-2 g6-standard-4"
}

variable "nodes" {
  default = 1
}

variable "linode_token" {
  type        = string
  description = "Linode API v4 Personal Access Token"
}

variable "linode_group" {
  default = "k8s-terraform"
}

variable "ssh_private_key" {
  type        = string
  default     = "~/.ssh/id_rsa"
  description = "The path to your private key"
}

variable "ssh_public_key" {
  type        = string
  default     = "~/.ssh/id_rsa.pub"
  description = "The path to your public key"
}

variable "ccm_image" {
  type        = string
  default     = "linode/linode-cloud-controller-manager:latest"
  description = "The docker repo/image:tag to use for the CCM"
}

variable "csi_image" {
  type        = string
  default     = "linode/linode-blockstorage-csi-driver:canary"
  description = "The docker repo/image:tag to use for the CSI"
}

