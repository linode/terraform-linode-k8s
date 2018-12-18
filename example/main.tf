// # Work In Progress Example
// 
// This generally demonstrates how to use the terraform-linode-k8s module, however there
// are some provisioning errors with the usage of the helm provider here.  The
// install.sh script in this example/ directory is equivalent.
// 
// ## TODO
// - Fix timeouts (set better "depends_on" values)
// - Fix permission issue with helm listing configmaps from the kube-system namespace

module "linode_k8s" {
  # source = "linode/k8s/linode"
  # version      = "0.0.6"
  source = "git::https://github.com/displague/terraform-linode-k8s?ref=separate_modules"
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

provider "helm" {
  kubernetes {
//    host        = "https://${module.linode_k8s.k8s_master_public_ip}"
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
  version    = "3.0.2"
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
  version = "1.54.0"
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
