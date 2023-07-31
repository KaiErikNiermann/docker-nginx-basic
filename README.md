# Docker/Nginx/DigitalOcean Web Server

## Disclaimer

This is a *very* basic configuration, while I will likely work on improving it, it most likely is not a very secure setup, so I do not recommend using this for hosting sensitive information.

## Table of Contents

- [Docker/Nginx/DigitalOcean Web Server](#dockernginxdigitalocean-web-server)
  - [Disclaimer](#disclaimer)
  - [Table of Contents](#table-of-contents)
  - [Why](#why)
  - [Basic Idea and Technologies](#basic-idea-and-technologies)
  - [In More Detail](#in-more-detail)
    - [1. The Nginx Server](#1-the-nginx-server)
    - [2. Nginx Dockerfile](#2-nginx-dockerfile)
      - [HTML](#html)
      - [Image](#image)
    - [3. Node Dockerfile and Docker Compose](#3-node-dockerfile-and-docker-compose)
      - [Server and Node Dockerfile](#server-and-node-dockerfile)
      - [Docker Compose](#docker-compose)
      - [Reverse Proxy](#reverse-proxy)
    - [4. Certbot and SSL](#4-certbot-and-ssl)
      - [Note](#note)
    - [5. The Workflow](#5-the-workflow)
      - [Setup SSH and Known Hosts](#setup-ssh-and-known-hosts)
      - [Make Sure VM is Running](#make-sure-vm-is-running)
      - [Deployment](#deployment)
    - [Resources](#resources)

## Why

While there are likely more straightforward approaches when it comes to manually setting up some hosting configuration, this was personally a nice exploration into some of the more manual aspects of hosting and deployment, and I hope it helps anyone else aswell. Additionally its nice to have a reference for some of the fundamentals.

## Basic Idea and Technologies

This is a basic example of a simple server making use of various technologies such as:

- `nginx`: Web server and reverse proxy
- `DigitalOcean Droplet`: Cloud VM which is running the server
- `docker-compose`: To orchestrate the `nginx` and `express` server containers
- `certbot`: To get the SSL certificates
- `workflow`: To automatically deploy the server via SSH to the VM

## In More Detail

So there are various aspects to this, but we can break it down into parts.

### 1. The Nginx Server

The core aspect here is the Nginx server. We created a custom config to run a basic server which listens on all network interfaces on port `80`. This configuration is defined in `default.conf`. This configuration is then copied to the `/etc/nginx/conf.d/` folder. After this, when the server runs, it includes this configuration in its main `nginx.conf` file.

### 2. Nginx Dockerfile

The Nginx Docker image by default looks in `/usr/share/nginx/html` for content, so we copy over the contents of the `data` folder here.

#### HTML

We then define our custom `index.html` page in the Nginx config with the following `location` block, which is then accessible via the URL `asdfxyz.xyz`

```text
location / {
    root /usr/share/nginx/html/html;
    index index.html index.htm;
}
```

#### Image

For the image, we define the location using the following block

```text
location /image/ {
    root /usr/share/nginx/html/;
}
```

The image is then accessed via the URL `asdfxyz.xyz/image/_33A7500.JPG`

### 3. Node Dockerfile and Docker Compose

To test out the reverse proxy functionality, that is, on a specific (or all) routes, we redirect the request somewhere else, such as another server running on the same machine.

Doing so is rather simple. We first set up a basic express server in `backend/app.js`

#### Server and Node Dockerfile

```js
const express = require('express');
const app = express();
const port = 3000;

// Route to serve the HTML page
app.get('/', (req, res) => {
  res.send('<h1>Hello, World!</h1>');
});

// Start the server
app.listen(port, () => {
  console.log(`Server is running`);
});
```

Keeping in line with the Docker philosophy, we create another container for the server which just exposes the port it runs on and then runs the server.

#### Docker Compose

Now, since we have two Dockerfiles, one to run the `nginx` server in the root directory and one to run the node server in the backend directory, we preferably need some way to build and run both of them easily. This is where docker-compose comes in handy; it's a nice way to manage multiple containers via a simple `.yml` file.

Ignoring the `certbot` stuff for the time being, you should see two containers: `backend`, which is running the node server, and `nginx`, which is running the Nginx server. Both containers perform a 1:1 mapping of the VM port to the containers exposed port. Aside from that, they just use what's defined in the Dockerfile to build.

To then build and run the containers, we use the command `docker-compose up -d --build`

- `-d`: if we want it to run in the background

And to shut the containers down, we use `docker-compose down`

#### Reverse Proxy

Here is where the spicy part comes in. If we, for example, want the route `asdfxyz.xyz/api/` to access content being served by the node server, what we can do is use `proxy_pass` in a location block to redirect the request to that of the server. Which is exactly what is happening here.

```text
location /api/ {
    # backend is the name of the container, don't use `localhost`
    proxy_pass http://backend:3000/;
    ... 
}
```

### 4. Certbot and SSL

I would recommend you first test acquiring the certificats using the `--dry-run` flag to make sure yoru configuration is setup correctly, because you can get locked out of acquiring certificates if something fails too many times.

```bash
docker compose run --rm  certbot certonly --webroot --webroot-path /var/www/certbot/ -d example.org
```

Finally, we get the actual certificates for the domain. For this I made a bash script which you can run with `chmod +x setup_ssl.sh && ./setup_ssl.sh`. You can also just pass the volumes in the command directly, to do so alter the script below based on the official documentation, but in either case the container places the certificate files in the specified volumes on your system.

```sh
#!/bin/bash

email_arg="--email example@example.com"
domain_args="-d example.com"

docker compose run --rm --entrypoint "\
  certbot certonly --webroot -w /var/www/certbot \
    $email_arg \
    $domain_args \
    --agree-tos \
    --force-renewal" certbot
echo
```

#### Note

Honestly unless you are working with something on a larger scale I don't know if I would recommend using docker here, even [*the docs*](https://eff-certbot.readthedocs.io/en/stable/install.html#snap-recommended) advise against it because there is a much smoother [*automated method*](https://certbot.eff.org/instructions) for doing things, so just be aware of that when going into things.

### 5. The Workflow

Finally, to automate the deployment process, we can do a simple SSH into the VM and then just build and run the containers.

#### Setup SSH and Known Hosts

While there should be some premade actions for this, I think it's just nice to see how to do it manually. So you simply add the SSH key to the appropriate file, give it the correct permissions, and then add the hostname (public IP of the VM) to the list of known hosts.

#### Make Sure VM is Running

This is where you can get a bit spicy using something like Terraform to define your infrastructure and then running it in case your VM is not active, or you can use whatever CLI tools to define the infrastructure that way. I just added a basic running check.

#### Deployment

For the actual deployment, since we set the SSH key, we can simply do `ssh username@hostname 'echo "you are in the vm"'` to run the required commands in the VM.

### Resources

These are most of the resources that I used in the processes of learning about how to set this up and getting everything working smoothly

- [*nginx beginners guide*](http://nginx.org/en/docs/beginners_guide.html)
- [*docker nginx guide*](https://www.baeldung.com/linux/nginx-docker-container)
- [*cerbot docker guide 1*](https://mindsers.blog/post/https-using-nginx-certbot-docker/)
- [*certbot docker guide 2*](https://www.programonaut.com/setup-ssl-with-docker-nginx-and-lets-encrypt/)
- [*applied example docker/nginx/svelte*](https://github.com/woollysammoth/sveltekit-docker-nginx)
- [*certbot docs*](https://eff-certbot.readthedocs.io/en/stable/)
- [*basic nginx security*](https://www.acunetix.com/blog/web-security-zone/hardening-nginx/)
