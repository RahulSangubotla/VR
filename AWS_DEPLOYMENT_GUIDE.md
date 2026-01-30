# VR Kahoot - AWS FREE TIER Deployment Guide

## Complete Step-by-Step Guide: From AWS Free Tier Instance to Live Application

### Prerequisites
- AWS Account with FREE TIER access
- Your GitHub repository: `https://github.com/RahulSangubotla/VR.git`
- Basic knowledge of AWS Console

**💡 FREE TIER LIMITATIONS:**
- 750 hours/month of t2.micro instances (1 vCPU, 1GB RAM)
- 30GB EBS storage
- Limited network performance

---

## Step 1: Create AWS EC2 FREE TIER Instance

### 1.1 Launch Instance
1. **Login to AWS Console** → Navigate to EC2 Dashboard
2. **Click "Launch Instance"**
3. **Configure Instance (FREE TIER):**
   - **Name:** `vr-kahoot-free-tier`
   - **AMI:** Ubuntu Server 22.04 LTS (Free tier eligible) ✅
   - **Instance Type:** `t2.micro` ✅ (ONLY free tier option)
   - **Key Pair:** Create new or select existing key pair (SAVE THE .pem FILE!)
   
### 1.2 Configure Network & Security (FREE TIER)
1. **Network Settings → Edit:**
   - **VPC:** Default VPC (free tier)
   - **Subnet:** Public subnet (auto-assign public IP: Enable)
   - **Security Group:** Create new security group
   
2. **Security Group Rules:**
   ```
   Type            Protocol    Port Range    Source          Description
   SSH             TCP         22            Your IP         SSH access (restrict to your IP for security)
   Custom TCP      TCP         8080          0.0.0.0/0       Main App
   Custom TCP      TCP         8081          0.0.0.0/0       Avatar Server
   ```

### 1.3 Storage & Launch (FREE TIER)
1. **Storage:** 
   - **Recommended: 20GB gp3** ✅ (optimal for your app)
   - **Minimum: 15GB gp3** (tight but workable)  
   - **Maximum: 30GB gp3** (free tier limit)
   - **Storage breakdown:**
     ```
     Ubuntu OS + packages:    ~6GB
     Your VR Kahoot app:      ~1GB  
     Logs and cache:          ~2GB
     Free space buffer:       ~11GB
     ```
2. **Advanced Details:** Leave as default
3. **Click "Launch Instance"**

---

## Step 2: Connect to Your FREE TIER Instance

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

## Step 3: Deploy the Application (FREE TIER Optimized)

### 3.1 Method 1: Lightweight Deployment (RECOMMENDED for FREE TIER)
Once connected to your EC2 instance, run:

```bash
# Download and run the FREE TIER optimized deployment script
curl -sSL https://raw.githubusercontent.com/RahulSangubotla/VR/feature/vr-kahoot/deploy.sh -o deploy.sh
chmod +x deploy.sh
./deploy.sh
```

This will:
- ✅ Install Python3 and Node.js (lightweight)
- ✅ Clone your repository
- ✅ Install dependencies directly
- ✅ Start services using screen sessions
- ✅ Use minimal system resources

### 3.2 Method 2: Docker Deployment (Only if you have spare RAM)
```bash
# Only use if you're confident about memory usage
./deploy.sh --docker
```

⚠️ **WARNING:** Docker containers may consume too much RAM on t2.micro

### 3.3 Verify Deployment
Check if services are running:
```bash
# Check processes
ps aux | grep -E "(python3 main.py|node server.js)"

# Check screen sessions
screen -ls

# Monitor memory usage
free -h
```

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

## Step 7: FREE TIER Monitoring & Maintenance

### 7.1 View Application Logs (Screen Method)
```bash
screen -r main-app                        # View main app logs
screen -r avatar-server                   # View avatar server logs
# Press Ctrl+A then D to detach from screen
```

### 7.2 Restart Services (FREE TIER)
```bash
# Kill existing services
pkill -f "python3 main.py"
pkill -f "node server.js"

# Restart services
cd vr-kahoot
screen -dmS main-app bash -c "python3 main.py"
screen -dmS avatar-server bash -c "cd avatar-server && node server.js"
```

### 7.3 Update Application
```bash
cd vr-kahoot
git pull origin feature/vr-kahoot         # Pull latest changes

# Restart services
pkill -f "python3 main.py"; pkill -f "node server.js"
screen -dmS main-app bash -c "python3 main.py"
screen -dmS avatar-server bash -c "cd avatar-server && node server.js"
```

### 7.4 Monitor FREE TIER Resources
```bash
# Check memory usage (CRITICAL for t2.micro)
free -h

# Check disk usage (30GB limit)
df -h

# Monitor CPU usage
htop

# Check processes
ps aux --sort=-%mem | head -10             # Top memory consumers
```

### 7.5 FREE TIER Resource Optimization
```bash
# Clean package cache to save space
sudo apt autoremove -y
sudo apt autoclean

# Monitor swap usage (if enabled)
swapon --show
```

---

## Troubleshooting FREE TIER Issues

### Common FREE TIER Issues & Solutions

**Issue: Out of Memory (Most Common)**
```bash
# Check memory usage
free -h

# Kill unnecessary processes
sudo systemctl stop snapd
sudo systemctl disable snapd

# Restart services one by one
pkill -f "node server.js"
sleep 5
screen -dmS main-app bash -c "python3 main.py"
sleep 10
screen -dmS avatar-server bash -c "cd avatar-server && node server.js"
```

**Issue: Application Won't Start**
```bash
# Check Python dependencies
python3 -c "import fastapi, uvicorn, socketio"

# Check Node.js dependencies
cd avatar-server && npm list

# Reinstall if needed
pip3 install -r requirements.txt --user --force-reinstall
```

**Issue: Connection Refused**
- Check security group allows traffic on ports 8080/8081
- Verify processes are running: `ps aux | grep -E "(python3|node)"`
- Check if ports are listening: `sudo netstat -tulpn | grep :808`

**Issue: Disk Space Full (Monitor regularly)**
```bash
# Check available space (should keep >2GB free)
df -h

# Clean up space if needed
sudo apt autoremove -y
sudo apt autoclean
sudo journalctl --vacuum-time=3d

# Remove unnecessary packages
sudo apt remove --purge snapd
sudo apt autoremove -y

# Check largest files/directories
du -sh ~/.cache ~/.local /tmp /var/log /var/tmp 2>/dev/null

# Your app storage targets:
# Total usage should be: ~15GB used, ~5GB free (on 20GB storage)
```

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

## FREE TIER Cost Management & Limitations

### Understanding FREE TIER Limits
- **EC2 Hours:** 750 hours/month of t2.micro (only 1 instance 24/7)
- **Storage:** 30GB EBS storage (recommended: 20GB for your app)
- **Data Transfer:** 15GB/month outbound
- **Instance Type:** ONLY t2.micro (1 vCPU, 1GB RAM)

### Storage Usage Monitoring
```bash
# Check disk usage (monitor regularly)
df -h

# Check largest directories
du -sh /* 2>/dev/null | sort -hr | head -5

# Your app should use ~1GB total:
du -sh ~/vr-kahoot                 # App files: ~37MB
du -sh ~/.local                    # Python deps: ~200MB  
du -sh ~/vr-kahoot/avatar-server/node_modules  # Node deps: ~30MB
```

### Cost Optimization Tips
1. **Stop instance when not needed:**
   ```bash
   # Stop instance (preserves data, stops billing)
   sudo shutdown -h now
   ```

2. **Monitor usage:** Check AWS Billing Dashboard regularly

3. **Clean up regularly:**
   ```bash
   # Weekly cleanup
   sudo apt autoremove -y && sudo apt autoclean
   ```

4. **Use CloudWatch Free Tier:** Monitor your application

### Performance Expectations on FREE TIER
- **Concurrent Users:** 10-20 users max (due to 1GB RAM)
- **Response Time:** Slightly slower than paid instances
- **Reliability:** Good for development/demo, not production

---

## Security Recommendations for FREE TIER

1. **Restrict SSH Access:** 
   - Security group: SSH only from YOUR IP (not 0.0.0.0/0)
   
2. **Keep Software Updated:**
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

3. **Monitor Access:** Check /var/log/auth.log for unauthorized access

4. **Use Strong Passwords:** For any additional services

---

**🎉 Congratulations!** Your VR Kahoot application is now live on AWS FREE TIER!

**FREE TIER Deployment Summary:**
✅ Cost: $0 (within free tier limits)
✅ Performance: Suitable for 10-20 concurrent users
✅ Uptime: 24/7 for 750 hours/month
✅ Memory: Optimized for 1GB RAM
✅ Storage: Uses <10GB of 30GB allowance

**Next Steps:**
- Monitor your AWS billing dashboard
- Test with real users
- Consider upgrading to paid tier for production use