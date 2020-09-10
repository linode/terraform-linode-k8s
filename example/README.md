# Linode Addons Examples

This directory contains simple helm scripts to confirm the various Linode Addons are working.

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
