# Use the official Nginx base image from Docker Hub
FROM nginx:latest

RUN rm /etc/nginx/conf.d/*
RUN apt-get update
RUN apt-get upgrade

# copying default conf and some basic content
COPY ./default.conf /etc/nginx/conf.d/default.conf

COPY ./data /usr/share/nginx/html

EXPOSE 80
EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
