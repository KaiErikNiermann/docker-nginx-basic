# Use the official Nginx base image from Docker Hub
FROM node:latest

# Install Nginx
RUN apt-get -y update && apt-get -y install nginx

WORKDIR /usr/share/nginx/html

# Copy the contents of the ~/docker-nginx/data directory to the container's /usr/share/nginx/html directory
COPY ./data .

# Copy the default.conf file from the ~/docker-nginx/ directory to the container's /etc/nginx/conf.d/ directory
COPY ./default.conf /etc/nginx/sites-available/default

# Expose port 80 for incoming HTTP traffic
EXPOSE 80

# Start the Nginx server in the background as a daemon
CMD ["nginx", "-g", "daemon off;"]
