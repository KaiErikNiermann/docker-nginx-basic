# Use the official Node.js base image from Docker Hub
FROM node:latest

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json to the container
COPY ./backend/package*.json ./

# Install dependencies
RUN npm install

COPY ./backend .

EXPOSE 3000

CMD ["node", "app.js"]
