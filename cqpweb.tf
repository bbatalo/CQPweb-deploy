data "template_file" "user_data_cqpweb" {
  template = file("./scripts/add-setup-cqpweb.yaml")
}

resource "digitalocean_volume" "cqpweb-data" {
  region                  = "sgp1"
  name                    = "cqpweb-data"
  size                    = 50
  initial_filesystem_type = "ext4"
  description             = "Volume for all CQPweb data."
}

resource "digitalocean_droplet" "cqpweb" {
  image              = "ubuntu-20-04-x64"
  name               = "cqpweb"
  region             = "sgp1"
  size               = "s-1vcpu-1gb"
  monitoring         = true
  private_networking = true
  ssh_keys = [
    data.digitalocean_ssh_key.bojan.id
  ]

  user_data = data.template_file.user_data_cqpweb.rendered

  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = file(var.pvt_key)
    timeout     = "2m"
  }
}

resource "digitalocean_volume_attachment" "cqpweb-data-attachment" {
  droplet_id = digitalocean_droplet.cqpweb.id
  volume_id  = digitalocean_volume.cqpweb-data.id
}
