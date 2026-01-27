#!/bin/bash

# DeviceHub 后端部署脚本
# 使用方法: ./deploy.sh [环境]
# 环境: dev | prod (默认: dev)

set -e

ENV=${1:-dev}
echo "🚀 开始部署 DeviceHub 后端 [$ENV 环境]"

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ Docker 未安装，请先安装 Docker"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose 未安装，请先安装 Docker Compose"
    exit 1
fi

# 设置环境变量
if [ "$ENV" = "prod" ]; then
    export SECRET_KEY=$(openssl rand -hex 32)
    echo "✅ 已生成生产环境 SECRET_KEY"
fi

# 构建并启动服务
echo "📦 构建 Docker 镜像..."
docker-compose build

echo "🔄 启动服务..."
docker-compose up -d

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 10

# 检查服务状态
if curl -s http://localhost:8000/health | grep -q "healthy"; then
    echo "✅ 服务已成功启动!"
    echo ""
    echo "📋 服务信息:"
    echo "   - API 地址: http://localhost:8000"
    echo "   - API 文档: http://localhost:8000/docs"
    echo "   - 数据库: localhost:5432"
    echo ""
    echo "🔧 常用命令:"
    echo "   - 查看日志: docker-compose logs -f"
    echo "   - 停止服务: docker-compose down"
    echo "   - 重启服务: docker-compose restart"
else
    echo "❌ 服务启动失败，请检查日志"
    docker-compose logs
    exit 1
fi
