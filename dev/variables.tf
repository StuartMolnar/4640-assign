variable "do_token" {}

variable "region" {
    type = string
    default = "sfo3"
}

variable "droplet_count" {
    type = number
    default = 2
}

variable "destination_addresses" {
    type = list
    default = ["0.0.0.0/0", "::/0"]
}

variable "port_range" {
    type = string
    default = "1-65535"
}