# SereneAI Waitlist - Production Deployment Guide

This guide covers deploying the SereneAI waitlist application on Ubuntu 24.04 server using Docker.

## Prerequisites

- Ubuntu 24.04 server
- Docker and Docker Compose installed
- Domain name pointed to your server (optional but recommended)
- SSL certificate (Let's Encrypt recommended)

## Quick Start

### 1. Install Docker on Ubuntu 24.04

```bash
# Update package index
sudo apt update

# Install required packages
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index again
sudo apt update

# Install Docker
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add your user to docker group
sudo usermod -aG docker $USER

# Log out and back in for group changes to take effect
```

### 2. Clone and Setup Application

```bash
# Clone the repository
git clone <your-repo-url> serenews-waitlist
cd serenews-waitlist

# Copy production environment file
cp .env.production .env

# Generate application key
docker run --rm -v $(pwd):/app -w /app php:8.3-cli php -r "echo 'base64:' . base64_encode(random_bytes(32)) . PHP_EOL;"

# Update .env file with the generated key and your settings
nano .env
```

### 3. Configure Environment Variables

Edit the `.env` file and update the following:

```bash
# Application settings
APP_KEY=base64:YOUR_GENERATED_KEY_HERE
APP_URL=https://yourdomain.com

# Cloudflare Turnstile (get from Cloudflare dashboard)
TURNSTILE_SITE_KEY=your_site_key
TURNSTILE_SECRET_KEY=your_secret_key

# Optional: Email settings for notifications
MAIL_MAILER=smtp
MAIL_HOST=your_smtp_host
MAIL_PORT=587
MAIL_USERNAME=your_email
MAIL_PASSWORD=your_password
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=noreply@yourdomain.com
```

### 4. Build and Deploy

```bash
# Build the Docker image
docker-compose build

# Start the application
docker-compose up -d

# Check if everything is running
docker-compose ps

# View logs
docker-compose logs -f
```

### 5. Setup SSL with Let's Encrypt (Recommended)

```bash
# Install Certbot
sudo apt install -y certbot

# Stop the application temporarily
docker-compose down

# Generate SSL certificate
sudo certbot certonly --standalone -d yourdomain.com

# Create nginx SSL configuration
sudo mkdir -p /etc/nginx/ssl
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem /etc/nginx/ssl/
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem /etc/nginx/ssl/
```

Create an SSL-enabled nginx configuration:

```bash
# Create nginx-ssl.conf
cat > nginx-ssl.conf << 'EOF'
server {
    listen 80;
    server_name yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourdomain.com;
    
    ssl_certificate /etc/nginx/ssl/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/privkey.pem;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF
```

Update docker-compose.yml to use port 8080:

```yaml
services:
  app:
    ports:
      - "8080:80"  # Changed from 80:80
```

Install and configure nginx as reverse proxy:

```bash
# Install nginx
sudo apt install -y nginx

# Copy SSL configuration
sudo cp nginx-ssl.conf /etc/nginx/sites-available/serenews
sudo ln -s /etc/nginx/sites-available/serenews /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default

# Test nginx configuration
sudo nginx -t

# Start nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# Start the application
docker-compose up -d
```

## Maintenance

### Updating the Application

```bash
# Pull latest changes
git pull origin main

# Rebuild and restart
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Backup Database

```bash
# Create backup
cp database/database.sqlite database/database.sqlite.backup.$(date +%Y%m%d_%H%M%S)

# Or copy from running container
docker-compose exec app cp /var/www/html/database/database.sqlite /var/www/html/database/database.sqlite.backup.$(date +%Y%m%d_%H%M%S)
```

### View Logs

```bash
# Application logs
docker-compose logs -f app

# Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### Monitor Resources

```bash
# Check container stats
docker stats

# Check disk usage
df -h

# Check memory usage
free -h
```

## Security Considerations

1. **Firewall**: Configure UFW to only allow necessary ports
   ```bash
   sudo ufw enable
   sudo ufw allow ssh
   sudo ufw allow 80
   sudo ufw allow 443
   ```

2. **Regular Updates**: Keep your system and Docker images updated
   ```bash
   sudo apt update && sudo apt upgrade -y
   docker-compose pull
   ```

3. **SSL Certificate Renewal**: Set up automatic renewal
   ```bash
   # Add to crontab
   echo "0 12 * * * /usr/bin/certbot renew --quiet" | sudo crontab -
   ```

4. **Environment Variables**: Never commit `.env` file to version control

5. **Database Backups**: Set up regular automated backups

## Troubleshooting

### Common Issues

1. **Port 80 already in use**:
   ```bash
   sudo netstat -tulpn | grep :80
   sudo systemctl stop apache2  # if Apache is running
   ```

2. **Permission issues with SQLite**:
   ```bash
   sudo chown -R www-data:www-data database/
   sudo chmod 664 database/database.sqlite
   ```

3. **Container won't start**:
   ```bash
   docker-compose logs app
   docker-compose down
   docker system prune -f
   docker-compose up --build
   ```

4. **SSL certificate issues**:
   ```bash
   sudo certbot certificates
   sudo certbot renew --dry-run
   ```

## Performance Optimization

The Docker configuration includes several optimizations:

- **Multi-stage build** for smaller image size
- **PHP OPcache** enabled for better performance
- **Nginx gzip compression** for faster loading
- **Static file caching** with long expiry headers
- **Health checks** for container monitoring
- **Resource limits** to prevent memory issues

## Support

For issues or questions:
1. Check the application logs
2. Review this deployment guide
3. Check Docker and nginx configurations
4. Ensure all environment variables are set correctly