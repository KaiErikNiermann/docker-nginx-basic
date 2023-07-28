# Use the official Nginx base image from Docker Hub
FROM nginx

# Set the working directory in the container
WORKDIR /usr/share/nginx/html

# Copy the contents of the ~/docker-nginx/data directory to the container's /usr/share/nginx/html directory
COPY ./data /usr/share/nginx/html

# Copy the default.conf file from the ~/docker-nginx/ directory to the container's /etc/nginx/conf.d/ directory
COPY ./default.conf /etc/nginx/conf.d/default.conf

# Expose port 80 for incoming HTTP traffic
EXPOSE 80

# Start the Nginx server in the background as a daemon
CMD ["nginx", "-g", "daemon off;"]
