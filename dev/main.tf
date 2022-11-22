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

# Create firewall for droplets 
resource "digitalocean_firewall" "web" {

    # The name we give our firewall for ease of use                            #    
    name = "web-firewall"

    # The droplets to apply this firewall to                                   #
    droplet_ids = digitalocean_droplet.web.*.id

    # Internal VPC Rules. We have to let ourselves talk to each other
    inbound_rule {
        protocol = "tcp"
        port_range = "1-65535"
        source_addresses = [digitalocean_vpc.web.ip_range]
    }

    inbound_rule {
        protocol = "udp"
        port_range = "1-65535"
        source_addresses = [digitalocean_vpc.web.ip_range]
    }

    inbound_rule {
        protocol = "icmp"
        source_addresses = [digitalocean_vpc.web.ip_range]
    }

    outbound_rule {
        protocol = "udp"
        port_range = "1-65535"
        destination_addresses = [digitalocean_vpc.web.ip_range]
    }

    outbound_rule {
        protocol = "tcp"
        port_range = "1-65535"
        destination_addresses = [digitalocean_vpc.web.ip_range]
    }

    outbound_rule {
        protocol = "icmp"
        destination_addresses = [digitalocean_vpc.web.ip_range]
    }

    # Selective Outbound Traffic Rules

    # HTTP
    outbound_rule {
        protocol = "tcp"
        port_range = "80"
        destination_addresses = ["0.0.0.0/0", "::/0"]
    }

    # HTTPS
    outbound_rule {
        protocol = "tcp"
        port_range = "443"
        destination_addresses = ["0.0.0.0/0", "::/0"]
    }

    # ICMP (Ping)
    outbound_rule {
        protocol              = "icmp"
        destination_addresses = ["0.0.0.0/0", "::/0"]
    }
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
resource "digitalocean_project_resources" "project_attach" {
    project = data.digitalocean_project.lab_project.id
    resources = flatten([digitalocean_droplet.web.*.urn]) 
}

# Create load balancer for droplets
resource "digitalocean_loadbalancer" "public" {
  name = "loadbalancer-1"
  region = var.region

  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"

    target_port     = 80
    target_protocol = "http"
  }

  healthcheck {
    port     = 22
    protocol = "tcp"
  }

  droplet_tag = "Web"
  vpc_uuid = digitalocean_vpc.web_vpc.id
}

# Create a database firewall
resource "digitalocean_database_firewall" "mongodb-firewall" {

  cluster_id = digitalocean_database_cluster.mongodb-example.id
  # allow connection from resources with a given tag
  # for example if our droplets all have a tag "web" we could use web as the value
  rule {
    type  = "tag"
    value = "web"
  }
}

# Create a database
resource "digitalocean_database_cluster" "mongodb-example" {
  name       = "example-mongo-cluster"
  engine     = "mongodb"
  version    = "4"
  size       = "db-s-1vcpu-1gb"
  region     = var.region
  node_count = 1

  private_network_uuid = digitalocean_vpc.web_vpc.id
}


# firewall for bastion server
resource "digitalocean_firewall" "bastion" {
  
  #firewall name
  name = "ssh-bastion-firewall"

  # Droplets to apply the firewall to
  droplet_ids = [digitalocean_droplet.bastion.id]

  inbound_rule {
    protocol = "tcp"
    port_range = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol = "tcp"
    port_range = "22"
    destination_addresses = [digitalocean_vpc.web_vpc.ip_range]
  }

  outbound_rule {
    protocol = "icmp"
    destination_addresses = [digitalocean_vpc.web_vpc.ip_range]
  }
}
# Create a bastion server
resource "digitalocean_droplet" "bastion" {
  image    = "rockylinux-9-x64"
  name     = "bastion-${var.region}"
  region   = var.region
  size     = "s-1vcpu-512mb-10gb"
  ssh_keys = [data.digitalocean_ssh_key.my_key.id]
  vpc_uuid = digitalocean_vpc.web_vpc.id
}
