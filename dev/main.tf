/*terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}
*/

terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
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
  name   = "web"
  region = var.region
}


# Create droplets
resource "digitalocean_droplet" "web" {
  image    = "rockylinux-9-x64"
  count    = var.droplet_count
  name     = "web-${count.index + 1}"
  tags     = [digitalocean_tag.do_tag.id]
  region   = var.region
  size     = "s-1vcpu-512mb-10gb"
  vpc_uuid = digitalocean_vpc.web_vpc.id
  ssh_keys = [data.digitalocean_ssh_key.my_key.id]

  lifecycle {
    create_before_destroy = true
  }
}

# Add new web droplets to existing 4640_labs project
resource "digitalocean_project_resources" "project_attach_servers" {
    project = data.digitalocean_project.lab_project.id
    resources = flatten([digitalocean_droplet.web.*.urn]) 
}

resource "digitalocean_database_firewall" "mongodb-firewall" {
    
    cluster_id = digitalocean_database_cluster.mongodb-example.id
    # allow connection from resources with a given tag
    # for example if our droplets all have a tag "web" we could use web as the value
    rule {
      type = "tag"
      value = "web"
    }

    rule {
      type  = "ip_addr"
      value = "0.0.0.0"
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


resource "digitalocean_database_db" "database-example" {
  cluster_id = digitalocean_database_cluster.mongodb-example.id
  name       = "example-mongo-database"
}

output "host" {
  value = digitalocean_database_db.database-example.id
}

/*
output "password" {
  value = digitalocean_database_db.database-example.passwords
}
*/
