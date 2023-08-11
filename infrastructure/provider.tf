terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "do_token" {} # personal access token
variable "pvt_key" {}  # private key for login

provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "main-server-key" {
  name = "main-server-key"
}
