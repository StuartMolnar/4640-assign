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

variable "default_droplet_image" {
    type = string
    default = "rockylinux-9-x64"
}

variable "default_droplet_size" {
    type = string
    default = "s-1vcpu-512mb-10gb"
}

variable "vpc_name" {
    type = string
    default = "web"
}

variable "do_tag_name" {
    type = string
    default = "Web"
}