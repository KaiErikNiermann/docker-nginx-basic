# Use the official Nginx base image from Docker Hub
FROM nginx:latest

RUN rm /etc/nginx/conf.d/*

COPY ./default.conf /etc/nginx/conf.d/default.conf

COPY ./data /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
