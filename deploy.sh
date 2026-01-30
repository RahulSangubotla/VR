#!/bin/bash

# VR Kahoot Deployment Script for AWS EC2
# This script should be run on the EC2 instance

set -e  # Exit on any error

echo "🚀 Starting VR Kahoot deployment..."

# Update system packages
echo "📦 Updating system packages..."
sudo apt update -y

# Install Docker if not already installed
if ! command -v docker &> /dev/null; then
    echo "🐳 Installing Docker..."
    sudo apt install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker $USER
fi

# Install Docker Compose if not already installed
if ! command -v docker-compose &> /dev/null; then
    echo "🐙 Installing Docker Compose..."
    sudo apt install -y docker-compose
fi

# Clone the repository if not already present
if [ ! -d "vr-kahoot" ]; then
    echo "📥 Cloning repository..."
    git clone https://github.com/RahulSangubotla/VR.git vr-kahoot
fi

# Navigate to project directory
cd vr-kahoot

# Pull latest changes
echo "🔄 Pulling latest changes..."
git pull origin main

# Stop existing containers if running
echo "🛑 Stopping existing containers..."
docker-compose down || true

# Build and start the application
echo "🏗️  Building and starting containers..."
docker-compose up -d --build

# Show running containers
echo "✅ Deployment completed! Running containers:"
docker-compose ps

echo ""
echo "🌐 Your VR Kahoot application is now running!"
echo "   Main App: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"
echo "   Avatar Server: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8081"
echo ""
echo "📊 To view logs:"
echo "   docker-compose logs -f"
echo ""
echo "🔧 To restart services:"
echo "   docker-compose restart"