variable "node_count" {
  default     = "1"
  description = "Number of Kubernetes Control-Plane nodes to provision (max 1)"
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

variable "linode_token" {
  description = "Linode Token used for CSI, CCM, an other Linode addons in the cluster"
}

variable "k8s_version" {
  description = "Kubernetes version to install"
}

variable "cni_version" {
  description = "Container Network Plugin Version"
}

variable "crictl_version" {
  description = "Contrainer Runtime Interface version to install"
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
}

variable "ssh_public_key" {
  description = "SSH keys authorized for the Linux user account (core on Container Linux, root otherwise)"
}

variable "linode_group" {
  default     = ""
  description = "Linode display group for provisioned instances"
}

variable "k8s_feature_gates" {
  description = "Feature gates to enable in the Kubelet and API server"
}

variable "region" {
  description = "Linode Region: us-central us-west us-southeast us-east eu-west ap-south eu-central ap-northeast ap-northeast-1a"
}
