# Hướng dẫn Deploy OmniMer Health lên VPS

## Yêu cầu hệ thống

- VPS chạy Ubuntu 20.04+ hoặc Debian 11+
- Docker và Docker Compose đã được cài đặt
- Tối thiểu 2GB RAM, 2 CPU cores
- 20GB dung lượng ổ cứng trống

## Bước 1: Cài đặt Docker và Docker Compose

```bash
# Update package list
sudo apt update

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker --version
docker-compose --version
```

## Bước 2: Clone hoặc Upload source code lên VPS

### Option 1: Clone từ Git

```bash
git clone <repository-url> dacn_omnimer_health
cd dacn_omnimer_health
```

### Option 2: Upload qua SCP

```bash
# Từ máy local
scp -r dacn_omnimer_health user@your-vps-ip:/home/user/
```

## Bước 3: Cấu hình môi trường

Tạo file `.env` trong thư mục `omnimer_health_server/`:

```bash
cd omnimer_health_server
cp .env.example .env
nano .env
```

Cập nhật các biến môi trường:

```env
PORT=8000
NODE_ENV=production

# Database
MONGODB_URI=mongodb://your-mongodb-uri
# hoặc
DATABASE_URL=postgresql://user:password@host:port/database

# Redis
REDIS_HOST=your-redis-host
REDIS_PORT=6379
REDIS_PASSWORD=your-redis-password

# JWT
JWT_SECRET=your-super-secret-jwt-key
JWT_EXPIRES_IN=7d

# AI Service URL
AI_SERVICE_URL=http://ai_service:8888

# Other configs...
```

## Bước 4: Build và chạy services

```bash
# Quay về thư mục gốc
cd ..

# Build và start tất cả services
docker-compose up -d --build

# Kiểm tra logs
docker-compose logs -f

# Kiểm tra trạng thái containers
docker-compose ps
```

## Bước 5: Kiểm tra services

```bash
# Backend API
curl http://localhost:8000

# AI Service
curl http://localhost:8888

# Admin Dashboard
curl http://localhost:3000
```

## Bước 6: Cấu hình Nginx Reverse Proxy (Khuyến nghị)

Cài đặt Nginx trên VPS:

```bash
sudo apt install nginx -y
```

Tạo file config:

```bash
sudo nano /etc/nginx/sites-available/omnimer-health
```

Nội dung config:

```nginx
# Backend API
server {
    listen 80;
    server_name api.yourdomain.com;

    location / {
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# AI Service
server {
    listen 80;
    server_name ai.yourdomain.com;

    location / {
        proxy_pass http://localhost:8888;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}

# Admin Dashboard
server {
    listen 80;
    server_name admin.yourdomain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

Enable site và restart Nginx:

```bash
sudo ln -s /etc/nginx/sites-available/omnimer-health /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

## Bước 7: Cài đặt SSL với Let's Encrypt (Khuyến nghị)

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Obtain SSL certificates
sudo certbot --nginx -d api.yourdomain.com -d ai.yourdomain.com -d admin.yourdomain.com

# Auto-renewal
sudo certbot renew --dry-run
```

## Quản lý Docker Compose

```bash
# Xem logs
docker-compose logs -f [service_name]

# Restart service
docker-compose restart [service_name]

# Stop all services
docker-compose down

# Start all services
docker-compose up -d

# Rebuild service
docker-compose up -d --build [service_name]

# Remove all containers and volumes
docker-compose down -v
```

## Monitoring và Troubleshooting

### Kiểm tra resource usage

```bash
docker stats
```

### Xem logs chi tiết

```bash
# Backend
docker-compose logs -f backend

# AI Service
docker-compose logs -f ai_service

# Admin
docker-compose logs -f adminpage
```

### Vào container để debug

```bash
docker exec -it omnimer_health_backend sh
docker exec -it omnimer_health_ai bash
docker exec -it omnimer_health_admin sh
```

## Backup và Restore

### Backup

```bash
# Backup database (nếu dùng MongoDB local)
docker exec omnimer_health_backend mongodump --out /backup

# Backup volumes
docker run --rm -v dacn_omnimer_health_data:/data -v $(pwd):/backup ubuntu tar czf /backup/backup.tar.gz /data
```

## Cập nhật ứng dụng

```bash
# Pull latest code
git pull origin main

# Rebuild và restart
docker-compose up -d --build

# Hoặc rebuild từng service
docker-compose up -d --build backend
docker-compose up -d --build ai_service
docker-compose up -d --build adminpage
```

## Ports Summary

- **8000**: Backend API (Node.js)
- **8888**: AI Service (FastAPI)
- **3000**: Admin Dashboard (React/Nginx)

## Firewall Configuration

```bash
# Allow SSH
sudo ufw allow 22/tcp

# Allow HTTP/HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Enable firewall
sudo ufw enable
```

## Performance Optimization

### Tăng giới hạn file descriptors

```bash
echo "fs.file-max = 65535" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

### Docker resource limits

Thêm vào `docker-compose.yml`:

```yaml
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: "1.0"
          memory: 1G
        reservations:
          cpus: "0.5"
          memory: 512M
```

## Troubleshooting Common Issues

### Container không start

```bash
docker-compose logs [service_name]
docker inspect [container_name]
```

### Port đã được sử dụng

```bash
sudo lsof -i :8000
sudo kill -9 [PID]
```

### Out of memory

```bash
# Tăng swap
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

## Support

Nếu gặp vấn đề, kiểm tra logs và documentation tại thư mục `docs/`.
