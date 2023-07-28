# Use the official Node.js base image from Docker Hub
FROM node:latest

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json to the container
COPY ./backend/package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the backend code to the container
COPY ./backend .

# Expose the port on which the backend server will run (adjust if your backend uses a different port)
EXPOSE 3000

# Start the Node.js backend using pm2
CMD ["pm2", "start", "app.js"]
