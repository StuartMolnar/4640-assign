# Create a new VPC
resource "digitalocean_vpc" "web_vpc" {
  name   = var.vpc_name
  region = var.region
}
