resource "digitalocean_droplet" "web-server" {
  image  = "ubuntu-20-04-x64"
  name   = "web-server"
  region = "fra1"
  size   = "s-1vcpu-1gb"
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

  provisioner "file" {
    source = "setup_docker.sh"
    destination = "/tmp/setup_docker.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup_docker.sh",
      "sudo /tmp/setup_docker.sh"
    ]
  }
}
