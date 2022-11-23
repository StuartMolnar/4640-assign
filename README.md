<b>Assumptions:</b>
- terraform is installed 
- SSH key named "my_key" attached to DigitalOcean account (or edit line 16 in main.tf)
- project named 4640_labs exists

<h4>First</h4>

Initialize a git repository in ```~/``` with the following file:
- .gitignore

Add the following <b>folder</b> to the git repository:
- dev

Add the following files inside of ```/dev```:
- .env
- main.tf
- terraform.tvars
- variables.tf

<h4>Next</h4>

Create a <b>DigitalOcean API Token</b> and keep track of its <b>authentication string</b> for the next task.

<h4>Next</h4>

Open your .env file at ```~/<gitrepo>/dev/.env``` and put:
```
export TF_VAR_do_token=<your token authentication string>
```

<h4>Next</h4>

In the command line at ```~/<gitrepo>/dev``` enter: <code>source .env</code>

<h4>Next</h4>

In command line at ```~/<gitrepo>/dev``` enter: <code>terraform init</code>

<h4>Next</h4>

Open <b>main.tf</b> at ```~/<gitrepo>/dev/main.tf``` and put:


<details>
    <summary>
        main.tf
    </summary>

    

</details>

<h4>Next</h4>

Open <b>main.tf</b> at ```~/<gitrepo>/dev/main.tf``` and put:


<details>
    <summary>
        main.tf
    </summary>

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

</details>

<h4>Next</h4>

Open <b>bastion.tf</b> at ```~/<gitrepo>/dev/bastion.tf``` and put:


<details>
    <summary>
        main.tf
    </summary>

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

</details>

<h4>Next</h4>

Open <b>main.tf</b> at ```~/<gitrepo>/dev/main.tf``` and put:


<details>
    <summary>
        main.tf
    </summary>

    

</details>

<h4>Next</h4>

Open <b>main.tf</b> at ```~/<gitrepo>/dev/main.tf``` and put:


<details>
    <summary>
        main.tf
    </summary>

    

</details>

<h4>Next</h4>

Open <b>main.tf</b> at ```~/<gitrepo>/dev/main.tf``` and put:


<details>
    <summary>
        main.tf
    </summary>

    

</details>

<h4>Next</h4>

In <b>terraform.tfvars</b> at ```~/<gitrepo>/dev/terraform.tvars``` enter:

<details>
    <summary>
        terraform.tvars
    </summary>

    droplet_count = 3
</details

<h4>Next</h4>

In <b>variables.tf</b> at ```~/<gitrepo>/dev/variables.tf``` enter:

<details>
    <summary>
        variables.tf
    </summary>
    
    variable "do_token" {}

    variable "region" {
        type = string
        default = "sfo3"
    }

    variable "droplet_count" {
        type = number
        default = 2
    }
</details


<h4>Next</h4>

In ```~/<gitrepo>/dev``` enter: <code>terraform apply</code>



