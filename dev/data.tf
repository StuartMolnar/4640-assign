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
  name = var.do_tag_name
}
