terraform {
    required_providers {
        digitalocean = {
            source = "digitalocean/digitalocean"
            version = "~> 2.0"
        }
    }
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
    token = var.do_token
}

# Set the SSH key used
data "digitalocean_ssh_key" "my_key" {
    name = "my_key"
}

# Set the project used
data "digitalocean_project" "lab_project" {
    name = "4640_labs"
}

# Create a new tag
resource "digitalocean_tag" "do_tag" {
    name = "Web"
}

# Create a new VPC
resource "digitalocean_vpc" "web_vpc" {
    name = "web"
    region = var.region
}

resource "digitalocean_database_firewall" "mongodb-firewall" {
    
    cluster_id = digitalocean_database_cluster.mongodb-example.id
    # allow connection from resources with a given tag
    # for example if our droplets all have a tag "web" we could use web as the value
    rule {
        type = "tag"
        value = "web"
    }
}

resource "digitalocean_droplet" "web" {
    image = "rockylinux-9-x64"
    count = var.droplet_count
    name = "web-${count_index + 1}"
    tags = [digitalocean_tag.do_tag.id]
    region = var.region
    size = "s-1vcpu-512mb-10gb"
    vpc_uuid = digitalocean_vpc.web_vpc.id
    ssh_keys = [data.digitalocean_ssh_key.my_key.id]

    lifecycle {
        create_before_destroy = true
    }
}

resource "digitalocean_database_cluster" "mongodb-example" {
    name       = "example-mongo-cluster"
    engine     = "mongodb"
    version    = "4"
    size       = "db-s-1vcpu-1gb"
    region     = var.region
    node_count = 1

    private_network_uuid = digitalocean_vpc.web_vpc.id
}
