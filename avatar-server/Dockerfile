# Use Node.js 18 as base image
FROM node:18-slim

# Set working directory
WORKDIR /app

# Copy package.json first to leverage Docker cache
COPY package.json .

# Install dependencies
RUN npm install

# Copy the application code
COPY server.js .

# Expose the port the app runs on
EXPOSE 8081

# Run the application
CMD ["npm", "start"]