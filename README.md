# Docker/Nginx/DigitalOcean web-server

## basic idea and technologies

This is a basic example of a simple server making use of various technologies such as:

- `nginx` : Web server and reverse proxy
- `DigitalOcean Droplet` : Cloud VM which is running the server
- `docker-compose` : To orchestrate the `nginx` and `express` server containers
- `certbot` : To get the SSL certificates
- `workflow` : To automatically deploy the server via ssh to the vm
