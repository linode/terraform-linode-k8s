# Linode Addons Examples

This directory contains simple helm scripts to confirm the the various Linode Addons are working.

* [**Linode Cloud Controller Manager (CCM)**](https://github.com/linode/linode-cloud-controller-manager)
  * Traefik - Test Loadbalancer Service
* [**Linode Container Storage Interface (CSI)**](https://github.com/linode/linode-blockstorage-csi-driver)
  * mysql-ha - A database to consume block storage volume space.
* [**External-DNS support for Linode**](https://github.com/kubernetes-incubator/external-dns)
  * Wordpress - The goto "It works!" blogging application

## Requirements

1. [Helm binary and tiller on cluster](https://docs.helm.sh/using_helm/), for example:

    ```bash
    kubectl -n kube-system create sa tiller
    kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
    helm init --service-account tiller
    ```

1. A domain that can be safely overwritten by external-dns.

      Domain records (of type `A` and `TXT`) will be created for `dashboard`, `traefik`, and `wordpress` on the chosen domain.

## Install

```bash
DOMAIN=example.com ./install.sh
```

### Verify that it works

Confirm that the pods and ingress routes have been configured:

```bash
kubectl get pods,ing,rs,deploy,statefulsets -o wide
```

Navigate to

* wordpress.*example.com*

  It may take several minutes for the DNS change to propogate.  Check for the new DNS names in your Linode account.

* traefik.*example.com*

  The Traefik admin dashboard shows all ingress routes that Traefik controlls.  Traefik will also register ACME Certificates for these domains once the DNS propogation has completed.
  
## Uninstall

To uninstall the examples:

1. Remove the deployments, statefulsets, and replicasets via helm

    ```bash
    ./uninstall.sh
    ```

1. Manually delete the domain records that were created using the [Linode CLI](https://github.com/linode/linode-cli) or the [Linode Cloud Manager](https://cloud.linode.com)

## Notes

* The MySQL-HA chart is used because it is a stateful set
* Traefik ACME staging is intentionally set to true
