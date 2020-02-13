output "loadbalancer_ip" {
  value = "${linode_nodebalancer.apiserver-nodebalancer.ipv4}"
}
