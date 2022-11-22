# firewall for bastion server
resource "digitalocean_firewall" "bastion" {
  
  #firewall name
  name = "ssh-bastion-firewall"

  # Droplets to apply the firewall to
  droplet_ids = [digitalocean_droplet.bastion.id]

  inbound_rule {
    protocol = "tcp"
    port_range = "22"
    source_addresses = var.destination_addresses
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

# Add bastion to existing 4640_labs project
resource "digitalocean_project_resources" "project_attach_bastion" {
    project = data.digitalocean_project.lab_project.id
    resources = [digitalocean_droplet.bastion.urn]
}