module "node" {
    source = "../instances"
    label_prefix = "${var.label_prefix}"
    node_type = "${var.node_type}"
    node_count = "1"
    node_class = "node"
    group = "${var.group}"
    private_ip = "true"
}

resource "null_resource" "kubeadm_join" {
    count = "${var.node_count}"
    provisioner "remote-exec" {
        inline = [
            "set -e",
            "export PATH=$${PATH}:/opt/bin",
            "sudo ${data.external.kubeadm_join.result.command}",
            "chmod +x /tmp/end.sh && sudo /tmp/end.sh",
        ]

        connection {
            host = "${element(module.node.*.public_ip, var.node_count)}"
            user    = "core"
            timeout = "300s"
        }
    }
}