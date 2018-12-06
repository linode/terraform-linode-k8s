output "nodes_public_ip" {
  value = "${concat(module.node.linode_instance.instance.*.label, module.node.linode_instance.instance.*.ip_address)}"
}
