# Kubernetes Terraform installer for Linode Instances

This Terraform module creates a Kubernetes v1.13 Cluster on Linode Cloud infrastructure using the ContainerLinux operating system.  The cluster is designed to take advantage of the Linode regional private network, and is equiped with Linode specific cluster enhancements.

Cluster size and instance types are configurable through Terraform variables.

## Install

### Prerequisites

* Terraform must be installed
* `jq` must be installed
* SSH should be installed and configured with an SSH Key and Agent (Recommended)
* Having kubectl installed is recommended

Note that you'll need Terraform v0.10 or newer to run this project.

### Linode API Token

Before running the project you'll have to create an access token for Terraform to connect to the Linode API.
Using the token and your access key, create the `LINODE_TOKEN` environment variable:

```bash
read -sp "Linode Token: " LINODE_TOKEN # Enter your Linode Token (it will be hidden)
export LINODE_TOKEN
```

This variable will need to be supplied to every Terraform `apply`, `plan`, and `destroy` command using `-var linode_token=$LINODE_TOKEN` unless a `terraform.tfvars` file is created with this secret token.

## Usage

Create a `main.tf` file in a new directory with the following contents:

```hcl
module "k8s" {
  source  = "linode/k8s/linode"
  linode_token = "YOUR TOKEN HERE"
}
```

That's all it takes to get started!

Choose a Terraform workspace name (because the default is `default`).  In this example we've chosen `linode`.  The workspace name will be used as a prefix for Linode resource created in this cluster, for example: `linode-master-1`, `linode-node-1`.  Alternate workspaces can be created and selected to change clusters.

```bash
terraform workspace new linode
```

Create an Linode Kubernetes cluster with one master and a node:

```bash
terraform apply \
 -var region=eu-west \
 -var server_type_master=g6-standard-2 \
 -var nodes=1 \
 -var server_type_node=g6-standard-2 \
```

This will do the following:

* provisions Linode Instances in parallel with CoreOS ContainerLinux (the Linode instance type/size of the `master` and the `node` may be different)
* connects to the Linode Instances via SSH and installs kubeadm, kubectl, and other Kubernetes binaries to /opt/bin
* installs a Calico network between Linode Instances
* runs kubeadm init on the master server and configures kubectl
* joins the nodes in the cluster using the kubeadm token obtained from the master
  * installs Linode add-ons: CSI (LinodeBlock Storage Volumes), CCM (Linode NodeBalancers), External-DNS (Linode Domains)
  * installs cluster add-ons: Kubernetes dashboard, metrics server and Heapster
* copies the kubectl admin config file for local `kubectl` use via the public IP of the API server

A full list of the supported variables are available in the [Terraform Module Registry](https://registry.terraform.io/modules/linode/k8s/linode/?tab=inputs).

After applying the Terraform plan you'll see several output variables like the master public IP,
the `kubeadmn join` command and the current workspace admin config (for use with `kubectl`).

The cluster node count can be scaled up by increasing the number of Linode Instances acting as nodes:

```bash
terraform apply -var nodes=3
```

Tear down the whole infrastructure with:

```bash
terraform destroy -force
```

Be sure to clean-up any CSI created Block Storage Volumes, and CCM created NodeBalancers that you no longer require.

### Remote control

The `kubectl` config file format is `<WORKSPACE>.conf` as in `linode.conf`.  Kubectl will use this file when provided through `--kubeconfig` or when set in the `KUBECONFIG` environment variable.

If you have `kubectl` install locally, you can use it to work with your Linode cluster.  You can always ssh into the master Linode Instance and run `kubectl` there (without the `--kubeconfig` option or environment variable).

```bash
$ export KUBECONFIG="$(pwd)/$(terraform output kubectl_config)"
$ kubectl top nodes

NAME           CPU(cores)   CPU%      MEMORY(bytes)   MEMORY%
linode-master-1   655m         16%       873Mi           45%
linode-node-1     147m         3%        618Mi           32%
linode-node-2     101m         2%        584Mi           30%
```

In order to access the dashboard locally, you can use `kubectl proxy` then browse to <http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy>

```bash
$ kubectl proxy &
[1] 37630
Starting to serve on 127.0.0.1:8001
```

To authenticate, provide the [kubeconfig file or generate a token](https://github.com/kubernetes/dashboard/wiki/Access-control#authentication).  For demonstrative purposes, an existing system token can be used.  This is not recommended for production clusters.

```bash
kubectl -n kube-system describe secrets `kubectl -n kube-system get secrets | awk '/clusterrole-aggregation-controller/ {print $1}'` | awk '/token:/ {print $2}'
```

![Overview](https://github.com/linode/terraform-linode-k8s/blob/master/screens/dash-overview.png)

![Nodes](https://github.com/linode/terraform-linode-k8s/blob/master/screens/dash-nodes.png)

## Addons Included

### [**Linode Cloud Controller Manager (CCM)**](https://github.com/linode/linode-cloud-controller-manager)

A primary function of the CCM is to register and maintain Kubernetes `LoadBalancer` settings within a Linode [`NodeBalancer`](https://www.linode.com/nodebalancers).  This is needed to allow traffic from the Internet into the cluster in the most fault tollerant way (obviously very important!)

The CCM also annotates new Kubernetes Nodes with Linode specific details, including the LinodeID and instance type.  Linode hostnames and network addresses are automatically associated with their corresponding Kubernetes resources, forming the basis for a variety of Kubernetes features.  T

The CCM monitors the Linode API for changes in the Linode instance and will remove a Kubernetes Node if it finds the Linode has been deleted.  Resources will automatically be re-scheduled if the Linode is powered off.

[Learn more about the CCM concept on kubernetes.io.](https://kubernetes.io/docs/concepts/architecture/cloud-controller/)  

### [**Linode Container Storage Interface (CSI)**](https://github.com/linode/linode-blockstorage-csi-driver)

The CSI provides a Kubernetes `Storage Class` which can be used to create `Persistent Volumes` (PV) using [Linode Block Storage Volumes](https://www.linode.com/blockstorage).  Pods then create `Persistent Volume Claims` (PVC) to attach to these volumes.

When a `PV` is deleted, the Linode Block Storage Volume will be deleted as well, based on the `ReclaimPolicy`.

In this Terraform Module, the `DefaultStorageClass` is provided by the `Linode CSI`.  Persistent volumes can be defined with an alternate  `storageClass`.

[Learn More about Persistent Volumes on kubernetes.io.](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)

### [**External-DNS support for Linode**](https://github.com/kubernetes-incubator/external-dns/blob/master/docs/tutorials/linode.md)

Unlike [CoreDNS](https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/) (or KubeDNS), which provides DNS services within the Kubernetes cluster, [External-DNS](https://github.com/kubernetes-incubator/external-dns/blob/master/README.md) publishes the public facing IP addresses associated with exposed services to a public DNS server, such as the [Linode DNS Manager](https://www.linode.com/dns-manager).

As configured in this Terraform module, any service or ingress with a specific annotation, will have a DNS record managed for it, pointing to the appropriate Linode or NodeBalancer IP address.  The domain must already be configured in the [Linode DNS Manager](https://www.linode.com/docs/platform/manager/dns-manager/#domain-zones).

[Learn more at the External-DNS Github project.](https://github.com/kubernetes-incubator/external-dns)

## Development

To make changes to this project, verify that you have the prerequisites and then clone the repo.  Instead of using the Terraform `module` syntax, and being confined by the variables that are provided, you'll be able to make any changes necessary.

```bash
git clone https://github.com/linode/terraform-linode-k8s.git
cd terraform-linode-k8s
```

Or if you won't be submitting changes, you can use `terraform init`:

```bash
terraform init --from-module=linode/k8s/linode linode-k8s
```

### Contribution Guidelines

Would you like to improve the `terraform-linode-k8s` module? Please start [here](https://github.com/linode/terraform-linode-k8s/blob/master/.github/CONTRIBUTING.md).

### Join us on Slack

For general help or discussion, join the [Kubernetes Slack](http://slack.k8s.io/) channel [#linode](https://kubernetes.slack.com/messages/CD4B15LUR).
