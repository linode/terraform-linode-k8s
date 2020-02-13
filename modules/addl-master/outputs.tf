output "addl_masters_private_ip" {
  value = "${module.addl-master.instances_private_ip}"
}

output "label" {
  value   = "${module.addl-master.label}"
}