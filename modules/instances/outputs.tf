output "master_public_ip" {
  depends_on = ["linode_instance.instance.0"]
  value      = "${element(concat(linode_instance.instance.*.ip_address, list("")), 0)}"
}

output "master_private_ip" {
  depends_on = ["linode_instance.instance.0"]
  value      = "${element(concat(linode_instance.instance.*.private_ip_address, list("")), 0)}"
}

output "instances_private_ip" {
  depends_on = ["linode_instance.instance.*"]
  value      = "${concat(linode_instance.instance.*.private_ip_address, list(""))}"
}

output "instances_public_ip" {
  depends_on = ["linode_instance.instance.*"]
  value      = "${concat(linode_instance.instance.*.ip_address)}"
}

output "label" {
  value   = "${linode_instance.instance.*.label}"
}