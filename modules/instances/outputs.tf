// todo: ha, return nb address
output "public_ip_address" {
  depends_on = ["linode_instance.instance.0"]
  value      = "${element(concat(linode_instance.instance.*.ip_address, list("")), 0)}"
}

// todo: this doesnt make sense in ha  -- return all?
output "private_ip_address" {
  depends_on = ["linode_instance.instance.0"]
  value      = "${element(concat(linode_instance.instance.*.private_ip_address, list("")), 0)}"
}

output "nodes_public_ip" {
  depends_on = ["linode_instance.instance.*"]
  value      = "${concat(linode_instance.instance.*.ip_address)}"
}
