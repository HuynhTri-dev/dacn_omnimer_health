# Checklist Deploy OmniMer Health trên VPS

## ✅ Files đã được tạo/cập nhật

### Docker Configuration

- [x] `3T-FIT/Dockerfile` - AI Service Docker image
- [x] `omnimer_health_server/Dockerfile` - Backend API Docker image
- [x] `adminpage/Dockerfile` - Admin Dashboard Docker image
- [x] `docker-compose.yml` - Production compose file
- [x] `docker-compose.dev.yml` - Development compose file

### Docker Ignore Files

- [x] `3T-FIT/.dockerignore`
- [x] `omnimer_health_server/.dockerignore`
- [x] `adminpage/.dockerignore`

### Documentation

- [x] `README.md` - Updated project documentation
- [x] `DEPLOYMENT.md` - Comprehensive deployment guide
- [x] `deploy.sh` - Automated deployment script

## 📋 Cấu hình Services

### 1. Backend Server (Node.js + TypeScript)

- **Port**: 8000
- **Framework**: Express.js
- **Build**: Multi-stage (builder + production)
- **Entry point**: `dist/server.js`
- **Environment**: `.env` file required

### 2. AI Service (Python + FastAPI)

- **Port**: 8888
- **Framework**: FastAPI + Uvicorn
- **Models**: Copied from `artifacts_unified/`
- **Entry point**: `ai_server.app.main:app`

### 3. Admin Dashboard (React + Vite)

- **Port**: 3000 (mapped from 80)
- **Framework**: React + Vite
- **Server**: Nginx
- **Build output**: `dist/`
- **SPA routing**: Configured in Nginx

## 🔧 Các thay đổi quan trọng

### 3T-FIT/Dockerfile

```diff
+ # Copy the artifacts_unified directory (contains trained models)
+ COPY artifacts_unified ./artifacts_unified
```

### adminpage/Dockerfile

```diff
- COPY --from=builder /app/build /usr/share/nginx/html
+ COPY --from=builder /app/dist /usr/share/nginx/html

+ # Create nginx config for SPA routing
+ RUN echo 'server { ... }' > /etc/nginx/conf.d/default.conf
```

### omnimer_health_server/Dockerfile

```diff
- RUN npm run build
+ RUN npx tsc

- EXPOSE 8080
+ EXPOSE 8000

- CMD ["node", "dist/main.js"]
+ CMD ["node", "dist/server.js"]
```

### docker-compose.yml

```diff
+ # Added adminpage service
+ adminpage:
+   container_name: omnimer_health_admin
+   build:
+     context: ./adminpage
+   ports:
+     - "3000:80"

+ # Added network configuration
+ networks:
+   omnimer_network:
+     driver: bridge

+ # Added restart policies
+ restart: unless-stopped
```

## 🚀 Hướng dẫn Deploy

### Quick Start

```bash
# 1. Clone/Upload code lên VPS
git clone <repo> dacn_omnimer_health
cd dacn_omnimer_health

# 2. Cấu hình environment
cd omnimer_health_server
cp .env.example .env
nano .env  # Edit với thông tin của bạn
cd ..

# 3. Deploy với script
chmod +x deploy.sh
./deploy.sh

# Hoặc manual
docker-compose up -d --build
```

### Development Mode

```bash
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d --build
```

## 🔍 Kiểm tra sau khi deploy

### Health Checks

```bash
# Backend API
curl http://localhost:8000
curl http://localhost:8000/api-docs

# AI Service
curl http://localhost:8888

# Admin Dashboard
curl http://localhost:3000
```

### Container Status

```bash
docker-compose ps
docker-compose logs -f
```

### Expected Output

```
NAME                        STATUS    PORTS
omnimer_health_backend      Up        0.0.0.0:8000->8000/tcp
omnimer_health_ai           Up        0.0.0.0:8888->8888/tcp
omnimer_health_admin        Up        0.0.0.0:3000->80/tcp
```

## 🌐 Nginx Reverse Proxy (Optional)

Nếu muốn sử dụng domain names:

```nginx
# /etc/nginx/sites-available/omnimer-health

# Backend API
server {
    listen 80;
    server_name api.yourdomain.com;
    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}

# AI Service
server {
    listen 80;
    server_name ai.yourdomain.com;
    location / {
        proxy_pass http://localhost:8888;
    }
}

# Admin Dashboard
server {
    listen 80;
    server_name admin.yourdomain.com;
    location / {
        proxy_pass http://localhost:3000;
    }
}
```

Enable và restart:

```bash
sudo ln -s /etc/nginx/sites-available/omnimer-health /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

## 🔒 SSL với Let's Encrypt

```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d api.yourdomain.com -d ai.yourdomain.com -d admin.yourdomain.com
```

## 📊 Monitoring

### Resource Usage

```bash
docker stats
```

### Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f ai_service
docker-compose logs -f adminpage
```

## 🛠️ Troubleshooting

### Port already in use

```bash
sudo lsof -i :8000
sudo kill -9 <PID>
```

### Container won't start

```bash
docker-compose logs <service_name>
docker inspect <container_name>
```

### Rebuild specific service

```bash
docker-compose up -d --build <service_name>
```

### Clean rebuild

```bash
docker-compose down -v
docker system prune -a
docker-compose up -d --build
```

## 📦 Production Checklist

- [ ] `.env` file configured với production values
- [ ] Database connection tested
- [ ] Redis connection tested
- [ ] AI models (`artifacts_unified/`) present
- [ ] Firewall configured (ports 80, 443, 22)
- [ ] SSL certificates installed
- [ ] Nginx reverse proxy configured
- [ ] Backup strategy in place
- [ ] Monitoring setup
- [ ] Log rotation configured

## 🔄 Update Strategy

```bash
# 1. Pull latest code
git pull origin main

# 2. Rebuild and restart
docker-compose up -d --build

# 3. Check logs
docker-compose logs -f
```

## 📞 Support

Xem chi tiết tại:

- `README.md` - Project overview
- `DEPLOYMENT.md` - Detailed deployment guide
- `docs/` - Additional documentation
