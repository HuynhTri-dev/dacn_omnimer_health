#!/bin/bash

# OmniMer Health Deployment Script
# This script helps deploy the application on VPS

set -e

echo "🚀 OmniMer Health Deployment Script"
echo "===================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed!${NC}"
    echo "Please install Docker first: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose is not installed!${NC}"
    echo "Please install Docker Compose first"
    exit 1
fi

echo -e "${GREEN}✅ Docker and Docker Compose are installed${NC}"

# Check if .env file exists
if [ ! -f "omnimer_health_server/.env" ]; then
    echo -e "${YELLOW}⚠️  .env file not found in omnimer_health_server/${NC}"
    echo "Creating from .env.example..."
    if [ -f "omnimer_health_server/.env.example" ]; then
        cp omnimer_health_server/.env.example omnimer_health_server/.env
        echo -e "${YELLOW}⚠️  Please edit omnimer_health_server/.env with your configuration${NC}"
        read -p "Press enter to continue after editing .env file..."
    else
        echo -e "${RED}❌ .env.example not found!${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✅ Environment file exists${NC}"

# Ask for deployment mode
echo ""
echo "Select deployment mode:"
echo "1) Development (with hot reload)"
echo "2) Production (optimized build)"
read -p "Enter choice [1-2]: " mode

if [ "$mode" == "1" ]; then
    echo -e "${YELLOW}📦 Building and starting in DEVELOPMENT mode...${NC}"
    docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d --build
elif [ "$mode" == "2" ]; then
    echo -e "${YELLOW}📦 Building and starting in PRODUCTION mode...${NC}"
    docker-compose up -d --build
else
    echo -e "${RED}❌ Invalid choice${NC}"
    exit 1
fi

# Wait for services to start
echo ""
echo -e "${YELLOW}⏳ Waiting for services to start...${NC}"
sleep 10

# Check service health
echo ""
echo "🔍 Checking service health..."

# Check backend
if curl -s http://localhost:8000 > /dev/null; then
    echo -e "${GREEN}✅ Backend is running on http://localhost:8000${NC}"
else
    echo -e "${RED}❌ Backend is not responding${NC}"
fi

# Check AI service
if curl -s http://localhost:8888 > /dev/null; then
    echo -e "${GREEN}✅ AI Service is running on http://localhost:8888${NC}"
else
    echo -e "${RED}❌ AI Service is not responding${NC}"
fi

# Check admin
if curl -s http://localhost:3000 > /dev/null; then
    echo -e "${GREEN}✅ Admin Dashboard is running on http://localhost:3000${NC}"
else
    echo -e "${RED}❌ Admin Dashboard is not responding${NC}"
fi

echo ""
echo "📊 Container Status:"
docker-compose ps

echo ""
echo -e "${GREEN}✅ Deployment completed!${NC}"
echo ""
echo "📝 Useful commands:"
echo "  - View logs: docker-compose logs -f"
echo "  - Stop services: docker-compose down"
echo "  - Restart: docker-compose restart"
echo "  - View status: docker-compose ps"
echo ""
echo "🌐 Access points:"
echo "  - Backend API: http://localhost:8000"
echo "  - API Docs: http://localhost:8000/api-docs"
echo "  - AI Service: http://localhost:8888"
echo "  - Admin Dashboard: http://localhost:3000"
