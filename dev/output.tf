output "bastion_ip_addr" {
    value = digitalocean_droplet.bastion.ipv4_address
    description = "Bastion IPv4 Address"
}

output "droplet_internal_addr" {
    value = digitalocean_droplet.web.*.ipv4_address_private
    description = "Web Droplet Internal IPv4 Addresses"
}

/*
output "database_connection_uri" {
    value = digitalocean_database_cluster.mongodb-example.co
}
*/