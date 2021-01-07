variable "ubuntu_version" {
  description = "Ubuntu version to install"
  default     = "20.04"
}

variable "cni_version" {
  default     = "v0.8.7"
  description = "Container Network Plugin Version"
}

variable "k8s_version" {
  default     = "v1.18.13"
  description = "Kubernetes version to install"
}

variable "crictl_version" {
  default     = "v1.15.0"
  description = "Container Runtime Interface version to install"
}

variable "k8s_feature_gates" {
  default     = ""
  description = "Feature gates to enable in the Kubelet and API server"
}

variable "region" {
  default     = "eu-west"
  description = "Linode Region: us-central us-west us-southeast us-east eu-west ap-south eu-central ap-northeast ap-northeast-1a"
}

variable "server_type_master" {
  default     = "g6-standard-2"
  description = "Linode Instance type: g6-nanode-1 g6-standard-1 g6-standard-2 g6-standard-4 g6-standard-6 g6-standard-8 g6-standard-16 g6-standard-20 g6-standard-24 g6-standard-32 g6-highmem-1 g6-highmem-2 g6-highmem-4 g6-highmem-8 g6-highmem-16"
}

variable "server_type_node" {
  default     = "g6-standard-2"
  description = "Linode Instance type: g6-nanode-1 g6-standard-1 g6-standard-2 g6-standard-4 g6-standard-6 g6-standard-8 g6-standard-16 g6-standard-20 g6-standard-24 g6-standard-32 g6-highmem-1 g6-highmem-2 g6-highmem-4 g6-highmem-8 g6-highmem-16"
}

variable "masters" {
  default     = 1
  description = "Number of control-plane (master) nodes.  This must be 1 for now."
}

variable "nodes" {
  default     = 3
  description = "Number of worker nodes to provision"
}

variable "cluster_name" {
  default     = ""
  description = "Name of the Kubernetes cluster"
}

variable "linode_token" {
  type        = string
  description = "Linode API v4 Personal Access Token"
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

variable "csi_manifest" {
  type        = string
  default     = "https://raw.githubusercontent.com/linode/linode-blockstorage-csi-driver/master/pkg/linode-bs/deploy/releases/linode-blockstorage-csi-driver-v0.1.7.yaml"
  description = "The linode csi manifest location"
}

variable "calico_manifest" {
  type        = string
  default     = "https://docs.projectcalico.org/manifests/calico.yaml"
  description = "The calico manifest location"
}

variable "docker_version" {
  type        = string
  default     = "19.03"
  description = "The docker version to install"
}
