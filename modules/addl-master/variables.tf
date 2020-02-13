variable "node_count" {
  default     = "0"
  description = "Number of Kubernetes Nodes to provision"
}

variable "master_type" {
  default     = "addl-master"
  description = "Determines the type of the master (primary master or additional master)"
}

variable "node_class" {
  default     = "master"
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

variable "linode_group" {
  default     = ""
  description = "Linode display group for provisioned instances"
}

variable "kubeadm_join_command" {
  description = "Kubernetes 'kubeadm join' command to join this node to the cluster"
}

variable "kubeadm_cert_key" {
  description = "Kubernetes kubeadm cert key to join the additional controlplane"
}

variable "region" {
  description = "Linode region for instances"
}

variable "ssh_public_key" {
  description = "SSH keys authorized for the Linux user account (core on Container Linux, root otherwise)"
}

variable "k8s_version" {
  description = "Kubernetes version to install"
}

variable "cni_version" {
  description = "CNI version to install"
}

variable "crictl_version" {
  description = "Container Runtime Interface version to install"
}

variable "k8s_feature_gates" {
  description = "Kubernetes Feature gates to enable in the Kubelet"
}
