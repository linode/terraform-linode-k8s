variable "node_count" {
  default     = "1"
  description = "Number of Kubernetes Nodes to provision"
}

variable "node_class" {
  default     = "node"
  description = "Node class is determines Kubernetes provisioning behavior (also used as a Linode label prefix)"
}

variable "node_type" {
  default     = "g6-standard-4"
  description = "Linode Instance type for nodes"
}

variable "private_ip" {
  default     = true
  description = "Enables Linode Instance Private IP addresses"
}

variable "label_prefix" {
  default     = ""
  description = "Linode label prefix"
}

variable "use_public" {
  description = "Use the public network interface"
  default     = false
}

variable "cni_version" {
  description = "Container Network Plugin Version"
}

variable "ssh_public_key" {}

variable "region" {
  description = "Linode Region: us-central us-west us-southeast us-east eu-west ap-south eu-central ap-northeast ap-northeast-1a"
}

variable "linode_group" {
  default     = ""
  description = "Linode display group for provisioned instances"
}

variable "k8s_version" {
  description = "Kubernetes version to install"
}

variable "crictl_version" {
  description = "Contrainer Runtime Interface version to install"
}

variable "k8s_feature_gates" {
  description = "Feature gates to enable in the Kubelet and API server"
}
