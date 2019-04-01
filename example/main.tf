// # Work In Progress Example
// 
// This generally demonstrates how to use the terraform-linode-k8s module, however there
// are some provisioning errors with the usage of the helm provider here.  The
// install.sh script in this example/ directory is equivalent.
// 
// ## TODO
// - Fix timeouts (set better "depends_on" values)
// - Fix permission issue with helm listing configmaps from the kube-system namespace:
//   https://github.com/terraform-providers/terraform-provider-helm/issues/77

module "linode_k8s" {
  # Work against a branch:
  # source = "git::https://github.com/linode/terraform-linode-k8s?ref=some_branch"
  #
  # Or download a tagged releases
  source = "linode/k8s/linode"

  version = "0.1.0"

  nodes        = "${var.nodes}"
  linode_token = "${var.linode_token}"
}

variable "nodes" {
  default = "3"
}

variable "linode_token" {
  description = "Linode APIv4 Token"
}

variable "linode_domain" {
  description = "Domain managed by Linode Domain Manager"
}

provider "kubernetes" {
  config_path = "${module.linode_k8s.kubectl_config}"
}

resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "tiller" {
  depends_on = ["kubernetes_service_account.tiller"]

  metadata {
    name = "tiller"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind = "User"
    name = "system:serviceaccount:kube-system:tiller"
  }
}

resource null_resource "tiller" {
  depends_on = ["kubernetes_cluster_role_binding.tiller"]

  provisioner "local-exec" {
    environment {
      KUBECONFIG = "${module.linode_k8s.kubectl_config}"
    }

    command = "helm init --service-account tiller --wait"
  }
}

provider "helm" {
  service_account = "tiller"
  namespace       = "kube-system"
  install_tiller  = false

  kubernetes {
    config_path = "${module.linode_k8s.kubectl_config}"
  }
}

resource "helm_repository" "incubator" {
  name = "incubator"
  url  = "https://kubernetes-charts-incubator.storage.googleapis.com"
}

resource "helm_release" "wordpress" {
  depends_on = ["helm_release.mysqlha"]
  name       = "stable"
  chart      = "wordpress"
  version    = "5.0.1"
  values     = ["${file("${path.module}/values/wordpress.values.yaml")}"]

  set {
    name  = "ingress.hosts[0].name"
    value = "wordpress.${var.linode_domain}"
  }
}

resource "helm_release" "mysqlha" {
  name    = "${helm_repository.incubator.name}"
  chart   = "mysqlha"
  version = "0.4.0"
  values  = ["${file("${path.module}/values/mysqlha.values.yaml")}"]
}

resource "helm_release" "traefik" {
  name    = "stable"
  chart   = "traefik"
  version = "1.55.1"
  values  = ["${file("${path.module}/values/traefik.values.yaml")}"]

  set {
    name  = "service.annotations.external-dns\\.alpha\\.kubernetes\\.io/hostname\\.io/hostname"
    value = "dashboard.${var.linode_domain}"
  }

  set {
    name  = "dashboard.domain"
    value = "dashboard.${var.linode_domain}"
  }
}
