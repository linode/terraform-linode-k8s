# Linode Addons Examples

This directory contains simple helm scripts to confirm the the various Linode Addons are working.

## Addon Summary

### [**Linode Cloud Controller Manager (CCM)**](https://github.com/linode/linode-cloud-controller-manager)

A primary function of the CCM is to register and maintain Kubernetes `LoadBalancer` settings within a Linode [`NodeBalancer`](https://www.linode.com/nodebalancers).  This is needed to allow traffic from the Internet into the cluster in the most fault tollerant way (obviously very important!)

The CCM also annotates new Kubernetes Nodes with Linode specific details, including the LinodeID and instance type.  Linode hostnames and network addresses are automatically associated with their corresponding Kubernetes resources, forming the basis for a variety of Kubernetes features.  T

The CCM monitors the Linode API for changes in the Linode instance and will remove a Kubernetes Node if it finds the Linode has been deleted.  Resources will automatically be re-scheduled if the Linode is powered off.

[Learn more about the CCM concept on kubernetes.io.](https://kubernetes.io/docs/concepts/architecture/cloud-controller/)  

### [**Linode Container Storage Interface (CSI)**](https://github.com/linode/linode-blockstorage-csi-driver)

Thi CSI provides a Kubernetes `Storage Class` which can be used to create `Persistent Volumes` (PV) using [Linode Block Storage Volumes](https://www.linode.com/blockstorage).  Pods then create `Persistent Volume Claims` (PVC) to attach to these volumes.

When a `PV` is deleted, the Linode Block Storage Volume will be deleted as well, based on the `ReclaimPolicy`.

In this Terraform Module, the `DefaultStorageClass` is provided by the `Linode CSI`.  Persistent volumes can be defined with an alternate  `storageClass`.

[Learn More about Persistent Volumes on kubernetes.io.](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)

### [**External-DNS support for Linode**](https://github.com/kubernetes-incubator/external-dns/blob/master/docs/tutorials/linode.md)

Unlike [CoreDNS](https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/) (or KubeDNS), which provides DNS services within the Kubernetes cluster, [External-DNS](https://github.com/kubernetes-incubator/external-dns/blob/master/README.md) publishes the public facing IP addresses associated with exposed services to a public DNS server, such as the [Linode DNS Manager](https://www.linode.com/dns-manager).

As configured in this Terraform module, any service or ingress with a specific annotation, will have a DNS record managed for it, pointing to the appropriate Linode or NodeBalancer IP address.  The domain must already be configured in the [Linode DNS Manager](https://www.linode.com/docs/platform/manager/dns-manager/#domain-zones).

[Learn more at the External-DNS Github project.](https://github.com/kubernetes-incubator/external-dns)

## How the Linode addons are used

* [Traefik](https://traefik.io/) - The Cloud Native Edge Router
  
  Traefik is configured to use a LoadBalancer, which creates a Linode NodeBalancer.  This ingress router easily allows for public hostnames and URL paths to reach a service running in the cluster.

* mysql-ha - A database to consume block storage volume space.

  MySQL is backed by a PV to persist the database if the pods is terminated and scheduled on a new node.

* Wordpress - The goto "It works!" blogging application

  Wordpress in this example is deployed using a helm chart that relies on the `mysql-ha` for database storage, and a persistent volume to back file resources.

## Requirements

1. You should have the [Helm binary](https://github.com/helm/helm/blob/master/docs/install.md) [with tiller on the cluster](https://docs.helm.sh/using_helm/#role-based-access-control), for example:

    ```bash
    # Install Helm (in this case, using Homebrew in OSX)
    brew install helm

    # Create a RBAC service account and
    # let Helm install itself and configure Tiller
    kubectl -n kube-system create sa tiller
    kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
    helm init --service-account tiller
    ```

1. Choose a Linode DNS managed domain that can be safely overwritten by External-DNS.

      Domain records (of type `A` and `TXT`) will be created for `dashboard` and `wordpress` on the chosen domain.

## Install

Run the following after changing *example.com* to a domain managed by Linode DNS.  Use a sub-domain (*sub.example.com*) to avoid potential collisions with other names in your domain.

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

* dashboard.*example.com*

  The Traefik admin dashboard shows all ingress routes that Traefik controlls.  Traefik will also register ACME Certificates for these domains once the DNS propogation has completed.
  
## Uninstall

To uninstall the examples:

1. Remove the deployments, statefulsets, and replicasets via helm

    ```bash
    ./uninstall.sh
    ```

1. Manually delete the domain records that were created using the [Linode CLI](https://github.com/linode/linode-cli) or the [Linode Cloud Manager](https://cloud.linode.com)

1. Manually delete any Block Storage volumes that were not automatically removed.

1. Manually delete any NodeBalancers that were not automatically removed.

## Notes

* The MySQL-HA chart is used because it is a stateful set
