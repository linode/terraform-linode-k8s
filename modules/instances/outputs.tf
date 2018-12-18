// todo: ha, return nb address
output "public_ip_address" {
  value = "${element(linode_instance.instance.*.ip_address, 0)}"
}

// todo: this doesnt make sense in ha  -- return all?
output "private_ip_address" {
  value = "${element(linode_instance.instance.*.private_ip_address, 0)}"
}

output "nodes_public_ip" {
  value = "${concat(linode_instance.instance.*.ip_address)}"
}
