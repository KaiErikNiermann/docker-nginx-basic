resource "digitalocean_droplet" "www-1" {
  image  = "ubuntu-20-04-x64"
  name   = "www-1"
  region = "fra1"
  size   = "s-1vcpu-1gb"
  user_data = file("setup_docker.sh")
  ssh_keys = [
    data.digitalocean_ssh_key.main-server-key.id
  ]

  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = file(var.pvt_key)
    timeout     = "2m"
  }
}
