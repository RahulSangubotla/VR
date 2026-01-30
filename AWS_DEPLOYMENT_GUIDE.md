# VR Kahoot - AWS Deployment Guide

## Complete Step-by-Step Guide: From AWS Instance to Live Application

### Prerequisites
- AWS Account with appropriate permissions
- Your GitHub repository: `https://github.com/RahulSangubotla/VR.git`
- Basic knowledge of AWS Console

---

## Step 1: Create AWS EC2 Instance

### 1.1 Launch Instance
1. **Login to AWS Console** → Navigate to EC2 Dashboard
2. **Click "Launch Instance"**
3. **Configure Instance:**
   - **Name:** `vr-kahoot-server`
   - **AMI:** Ubuntu Server 22.04 LTS (Free tier eligible)
   - **Instance Type:** `t2.medium` (recommended) or `t3.medium` for better performance
   - **Key Pair:** Create new or select existing key pair (SAVE THE .pem FILE!)
   
### 1.2 Configure Network & Security
1. **Network Settings → Edit:**
   - **VPC:** Default VPC (or your preferred)
   - **Subnet:** Public subnet (auto-assign public IP: Enable)
   - **Security Group:** Create new security group
   
2. **Security Group Rules:**
   ```
   Type            Protocol    Port Range    Source          Description
   SSH             TCP         22            Your IP/0.0.0.0/0    SSH access
   HTTP            TCP         80            0.0.0.0/0           HTTP
   HTTPS           TCP         443           0.0.0.0/0           HTTPS
   Custom TCP      TCP         8080          0.0.0.0/0           Main App
   Custom TCP      TCP         8081          0.0.0.0/0           Avatar Server
   ```

### 1.3 Storage & Launch
1. **Storage:** 20-30 GB gp3 (sufficient for the application)
2. **Advanced Details:** Leave as default
3. **Click "Launch Instance"**

---

## Step 2: Connect to Your Instance

### 2.1 SSH Connection
1. **Wait for instance to be "Running"** (2-3 minutes)
2. **Note down Public IP address** from EC2 dashboard
3. **Connect via SSH:**

```bash
# Replace with your key file and public IP
chmod 400 your-key-file.pem
ssh -i your-key-file.pem ubuntu@YOUR_PUBLIC_IP
```

**Alternative: Use AWS Connect**
- Select your instance → Click "Connect" → Use "EC2 Instance Connect"

---

## Step 3: Deploy the Application

### 3.1 Run Deployment Script
Once connected to your EC2 instance, run:

```bash
# Download and run the deployment script
curl -sSL https://raw.githubusercontent.com/RahulSangubotla/VR/main/deploy.sh -o deploy.sh
chmod +x deploy.sh
./deploy.sh
```

The script will automatically:
- ✅ Update system packages
- ✅ Install Docker & Docker Compose
- ✅ Clone your repository
- ✅ Build and start containers
- ✅ Configure networking

### 3.2 Verify Deployment
Check if services are running:
```bash
cd vr-kahoot
docker-compose ps
```

You should see both services running:
- `vr-kahoot-main` (port 8080)
- `vr-kahoot-avatar` (port 8081)

---

## Step 4: Access Your Application

### 4.1 Get Your Public URLs
```bash
# Get your public IP
curl -s http://169.254.169.254/latest/meta-data/public-ipv4
```

### 4.2 Application URLs
- **Main VR Kahoot App:** `http://YOUR_PUBLIC_IP:8080`
- **Avatar Server:** `http://YOUR_PUBLIC_IP:8081`
- **Host Interface:** `http://YOUR_PUBLIC_IP:8080/host.html`
- **Player Interface:** `http://YOUR_PUBLIC_IP:8080/index.html`
- **VR Theater:** `http://YOUR_PUBLIC_IP:8080/theater.html`

---

## Step 5: Test Your Application

### 5.1 Host Interface Test
1. Open: `http://YOUR_PUBLIC_IP:8080/host.html`
2. You should see the Kahoot host dashboard
3. Try starting a game to test functionality

### 5.2 Player Interface Test
1. Open: `http://YOUR_PUBLIC_IP:8080/index.html` (on another device/browser)
2. Enter a player name and join the game
3. Verify real-time communication works

### 5.3 VR Interface Test
1. Open: `http://YOUR_PUBLIC_IP:8080/theater.html`
2. Test VR functionality (requires VR headset)

---

## Step 6: Domain Setup (Optional)

### 6.1 Using Route 53 (Recommended)
1. **Purchase domain** in Route 53 or use existing
2. **Create A Record:**
   - **Name:** `vr-kahoot.yourdomain.com`
   - **Type:** A
   - **Value:** Your EC2 Public IP

### 6.2 Configure Reverse Proxy with Nginx (Optional)
For production, consider setting up Nginx:
```bash
# Install Nginx
sudo apt install nginx -y

# Configure reverse proxy (example config)
sudo nano /etc/nginx/sites-available/vr-kahoot
```

---

## Step 7: Monitoring & Maintenance

### 7.1 View Application Logs
```bash
cd vr-kahoot
docker-compose logs -f                    # All services
docker-compose logs -f vr-kahoot-main    # Main app only
docker-compose logs -f avatar-server     # Avatar server only
```

### 7.2 Restart Services
```bash
cd vr-kahoot
docker-compose restart                    # Restart all
docker-compose restart vr-kahoot-main    # Restart main app
```

### 7.3 Update Application
```bash
cd vr-kahoot
git pull origin main                      # Pull latest changes
docker-compose down                       # Stop services
docker-compose up -d --build             # Rebuild and start
```

### 7.4 Monitor Resources
```bash
# Check system resources
htop
df -h                                     # Disk usage
docker stats                             # Container resource usage
```

---

## Troubleshooting

### Common Issues & Solutions

**Issue: Connection Refused**
- Check security group allows traffic on ports 8080/8081
- Verify containers are running: `docker-compose ps`

**Issue: Build Failed**
- Check Docker installation: `docker --version`
- Verify repository access: `git pull`

**Issue: Out of Disk Space**
- Clean Docker: `docker system prune -a`
- Check disk usage: `df -h`

**Issue: Memory Issues**
- Upgrade to larger instance type (t2.medium → t2.large)
- Monitor with: `free -h`

### Support Commands
```bash
# Service status
systemctl status docker

# Container logs
docker logs vr-kahoot-main
docker logs vr-kahoot-avatar

# Network connectivity
curl localhost:8080
curl localhost:8081

# Process monitoring
ps aux | grep docker
netstat -tulpn | grep :808
```

---

## Security Recommendations

1. **Restrict SSH Access:** Update security group to allow SSH only from your IP
2. **Use HTTPS:** Set up SSL certificates (Let's Encrypt + Nginx)
3. **Regular Updates:** Keep system and Docker updated
4. **Backup:** Regular snapshots of your EC2 instance
5. **Monitoring:** Set up CloudWatch alarms for resource usage

---

## Cost Optimization

- **Use t3.medium during development** (better performance/cost)
- **Stop instance when not in use** (save compute costs)
- **Use Elastic IP** if you need static IP
- **Monitor usage** with AWS Cost Explorer

---

**🎉 Congratulations!** Your VR Kahoot application is now live on AWS!

**Next Steps:**
- Share the URLs with your users
- Monitor performance and logs
- Scale up instance if needed
- Consider load balancing for high traffic