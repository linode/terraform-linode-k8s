module "linode_k8s" {
  source       = "linode/k8s/linode"
  version      = "0.0.5"
  nodes        = "1"
  linode_token = "${var.linode_token}"
}

variable "linode_token" {
  description = "Linode APIv4 Token"
}

variable "linode_domain" {
  description = "Domain managed by Linode Domain Manager"
}

provider "helm" {
  kubernetes {
    host        = "https://${module.linode_k8s.k8s_master_public_ip}"
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
