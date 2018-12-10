// todo: ha, return nb address
output "public_ip_address" {
  value = "${linode_instance.instance.0.ip_address}"
}

// todo: this doesnt make sense in ha  -- return all?
output "private_ip_address" {
  value = "${linode_instance.instance.0.private_ip_address}"
}

output "nodes_public_ip" {
  value = "${concat(linode_instance.instance.*.label, linode_instance.instance.*.ip_address)}"
}
