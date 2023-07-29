# Use the official Node.js base image from Docker Hub
FROM node:latest

# Set the working directory inside the container
WORKDIR /app

# Copy package.json, package-lock.json and app.js
COPY ./backend .

RUN npm install

EXPOSE 3000

CMD ["node", "app.js"]
