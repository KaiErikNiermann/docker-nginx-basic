# Docker/Nginx/DigitalOcean web-server

## basic idea and technologies

This is a basic example of a simple server making use of various technologies such as:

- `nginx` : Web server and reverse proxy
- `DigitalOcean Droplet` : Cloud VM which is running the server
- `docker-compose` : To orchestrate the `nginx` and `express` server containers
- `certbot` : To get the SSL certificates
- `workflow` : To automatically deploy the server via ssh to the vm

## In more detail

So there are various aspects to this, but we can break it down into parts. 

### 1. The nginx server

The core aspect here is the nginx server, we created a custom config to run a basic server which listenes on all network interfaces on port `80`. This configuration is defined in `default.conf`. This configuration is then copied to the `/etc/nginx/conf.d/` folder.

After this when the server runs it includes this configuration in its main `nginx.conf` file.

### 2. nginx Dockerfile 

The nginx docker image by default looks in `/usr/share/nginx/html` for content so we copy over the contents of the `data` folder here. 

#### html

We then define our custom `index.html` page in the nginx config with the following `location` block, which is then accessable via the url `asdfxyz.xyz`

```text
location / {
    root /usr/share/nginx/html/html;
    index index.html index.htm;
}
```

#### Image

For the image we define the location using the following block

```text
location /image/ {
    root /usr/share/nginx/html/;
}
```

The image is then accessed via the url `asdfxyz.xyz/image/_33A7500.JPG`

### 3. node Dockerfile and Docker compose

To test out the reverse proxy functionality. That is, on a specific (or all) routes, we redirect the request somewhere else, such as another server running on the same machine.

Doing so is rather simple, we first setup a basic express server in `backend/app.js`

#### server and node Dockerfile

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

Keeping in line with the Docker philosophy we create another container for the server which just exposes the port it runs on and then runs the server.

#### docker-compose

Now since we have two Dockerfiles, once to run the `nginx` server in the root directory and one to run the node server in the backend directory, we preferably need some way to build and run both of them easily, this is where docker-compose comes in handy, its a nice way to manage multiple containers via a simple `.yml` file.

Ignoring the `certbot` stuff for the time being you should see two containers `backend` which is running the node server and `nginx` which is running the nginx server. Both containers preform a 1:1 mapping of the VM port to the containers exposed port. Aside from that they just use whats defined in the dockerfile to build.

To then build and run the containers we use the command `docker-compose up -d --build`

- `-d` if we want it to run in the background

And to shut the containers down we use `docker-compose down`

#### reverse proxy

Here is where the spicy part comes in, if we for example want the route `asdfxyz.xyz/api/` to access content being served by the node server what we can do is use `proxy_pass` in a location block to redirect the request to that of the server. Which is exactly what is happening here.

```text
location /api/ {
    # backend is the name of the container, dont use `localhost`
    proxy_pass http://backend:3000/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}
```

### 4. Certbot and SSL

Finally we use certbot to get an SSL certificate for the domain. Doing this isn't too hard. We simply need to add the certbot container to the compose file such as we are doing here.

```yml
  ...
  certbot:
    image: certbot/certbot:latest
    container_name: certbot
    volumes:
      - ./certbot/conf:/etc/letsencrypt:rw
      - ./certbot/www:/var/www/certbot:rw
    depends_on:
      - nginx
    command: certonly --webroot -w /var/www/certbot --email example@example.com -d your_domain.com --agree-tos --force-renewal
```

To then get the certificate we can run just the certbot container using the command `docker compose up -d certbot` and then we can check the logs to see if we have acquired the certificate for the domain `docker logs certbot`.

### 5. The workflow

Finally to automate the deployment process we can do a simply ssh into the vm and then just build and run the containers.

#### Setup SSH and known hosts

While there should be some premade actions for this I think its just nice to see how to do it manually. So you simply add the SSH key to the appropraite file, give it the correct premissions and then add the hostname (public ip of the VM) to the list of known hosts.

#### Make sure vm is running

This is where you can get a bit spicy using something like Terraform to define your infrastructure and then running it in case your VM is not active, or you can use whatever cli tools to define the infrastructure that way. I just added a basic running check.

#### Deployment

For the actual deployment since we set the ssh key we can simply do `ssh username@hostname ' echo "you are in the vm" '` to run the required commands in the vm.
