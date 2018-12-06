variable "node_count" { default = "1" }
variable "group" { default = "" }

variable "node_class" { default = "node" }
variable "node_type" { default = "g6-standard-4" }
variable "private_ip" { default = true }
variable "label_prefix" { default = "" }
variable "use_public" {default = false}