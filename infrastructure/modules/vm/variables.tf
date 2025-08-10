variable "name" {}
variable "machine_type" {}
variable "zone" {}
variable "image" {}
variable "subnet_link" {}
variable "pubkey" {}
variable "tags" {
    type = list(string)
    default = []
}