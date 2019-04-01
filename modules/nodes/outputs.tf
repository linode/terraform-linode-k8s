output "nodes_public_ip" {
  description = "Public IP Address of the worker nodes"
  value       = "${module.node.nodes_public_ip}"
}
