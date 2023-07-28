# Use the official Node.js base image from Docker Hub
FROM node:latest

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json to the container
COPY package*.json ./

# Install dependencies
RUN npm install
RUN npm install pm2@latest -g

COPY . .

EXPOSE 3000

CMD ["pm2", "start", "app.js"]
