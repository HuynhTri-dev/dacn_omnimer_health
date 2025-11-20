# Stage 1: Build React app
FROM node:18-alpine AS builder

# Thư mục làm việc trong container
WORKDIR /app

# Copy package.json & package-lock.json trước để tận dụng cache
COPY package*.json ./

# Cài dependencies
RUN npm install

# Copy toàn bộ source code
COPY . .

# Build React app production (Vite outputs to dist/)
RUN npm run build

# Stage 2: Serve với NGINX
FROM nginx:alpine

# Copy build từ stage trước sang thư mục html của NGINX
COPY --from=builder /app/dist /usr/share/nginx/html

# Create nginx config for SPA routing
RUN echo 'server { \
    listen 80; \
    server_name _; \
    root /usr/share/nginx/html; \
    index index.html; \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Command chạy NGINX
CMD ["nginx", "-g", "daemon off;"]
