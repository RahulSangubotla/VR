#!/bin/bash

# VR Kahoot AWS FREE TIER Deployment Script
# Optimized for t2.micro instances with limited resources
# This script should be run on the EC2 instance

set -e  # Exit on any error

echo "🚀 Starting VR Kahoot FREE TIER deployment..."
echo "⚠️  Optimizing for t2.micro instance with 1GB RAM..."

# Update system packages
echo "📦 Updating system packages..."
sudo apt update -y

# Install Python3 and pip (lightweight alternative to Docker for free tier)
echo "🐍 Installing Python and Node.js..."
sudo apt install -y python3 python3-pip nodejs npm

# Optional: Install Docker for those who want containerized deployment
# Note: Docker might be resource-intensive on t2.micro
if [ "$1" == "--docker" ]; then
    if ! command -v docker &> /dev/null; then
        echo "🐳 Installing Docker (WARNING: Heavy for free tier)..."
        sudo apt install -y docker.io
        sudo systemctl start docker
        sudo systemctl enable docker
        sudo usermod -aG docker $USER
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        echo "🐙 Installing Docker Compose..."
        sudo apt install -y docker-compose
    fi
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
git pull origin feature/vr-kahoot || git pull origin main

# Install Python dependencies
echo "📦 Installing Python dependencies..."
pip3 install -r requirements.txt --user

# Install Node.js dependencies for avatar server
echo "� Installing Node.js dependencies..."
(cd avatar-server && npm install)

# Create a systemd service for auto-restart (free tier friendly)
echo "⚙️  Setting up services..."

# Stop any existing processes
pkill -f "python3 main.py" || true
pkill -f "node server.js" || true
sleep 2

# Start services using screen (keeps running after SSH disconnect)
echo "🏗️  Starting services with screen (FREE TIER method)..."

# Start avatar server in detached screen
screen -dmS avatar-server bash -c "cd avatar-server && node server.js"

# Start main app in detached screen  
screen -dmS main-app bash -c "python3 main.py"

# Show running processes
echo "✅ Services started! Running processes:"
ps aux | grep -E "(python3 main.py|node server.js)" | grep -v grep || echo "No processes found - checking screen sessions..."

# List screen sessions
echo "📺 Screen sessions:"
screen -ls
echo "✅ Deployment completed! Running processes:"
ps aux | grep -E "(python3 main.py|node server.js)" | grep -v grep || echo "No processes found - checking screen sessions..."

# List screen sessions
echo "📺 Screen sessions:"
screen -ls

echo ""
echo "🌐 Your VR Kahoot application should be running!"
echo "   Main App: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"
echo "   Avatar Server: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8081"
echo ""
echo "� FREE TIER Management Commands:"
echo "   View main app logs:    screen -r main-app"
echo "   View avatar logs:      screen -r avatar-server" 
echo "   Detach from screen:    Ctrl+A then D"
echo "   Kill all services:     pkill -f 'python3 main.py'; pkill -f 'node server.js'"
echo "   Restart main app:      screen -dmS main-app bash -c 'python3 main.py'"
echo "   Restart avatar:        screen -dmS avatar-server bash -c 'cd avatar-server && node server.js'"
echo ""
echo "💡 For Docker deployment (if you have enough RAM), run: ./deploy.sh --docker"
echo "📊 Monitor resources:     htop or free -h"