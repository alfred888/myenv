#!/bin/bash

# 显示颜色
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Docker 环境检查 ===${NC}\n"

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker 未安装${NC}"
    exit 1
fi

# 检查 Docker 服务状态
echo -e "${GREEN}Docker 服务状态：${NC}"
if systemctl is-active --quiet docker 2>/dev/null; then
    echo -e "${GREEN}Docker 服务正在运行${NC}"
elif service docker status &>/dev/null; then
    echo -e "${GREEN}Docker 服务正在运行${NC}"
else
    echo -e "${RED}Docker 服务未运行${NC}"
fi

# 显示 Docker 版本信息
echo -e "\n${GREEN}Docker 版本信息：${NC}"
docker version --format '{{.Server.Version}}' 2>/dev/null || echo "无法获取版本信息"

# 显示 Docker 系统信息
echo -e "\n${GREEN}Docker 系统信息：${NC}"
docker info 2>/dev/null | grep -E "Server Version|Operating System|Kernel Version|Total Memory|CPUs" || echo "无法获取系统信息"

# 显示镜像列表
echo -e "\n${GREEN}本地镜像列表：${NC}"
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedSince}}" 2>/dev/null || echo "无法获取镜像列表"

# 显示运行中的容器
echo -e "\n${GREEN}运行中的容器：${NC}"
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "没有运行中的容器"

# 显示所有容器（包括已停止的）
echo -e "\n${GREEN}所有容器状态：${NC}"
docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "没有容器"

# 显示 Docker 磁盘使用情况
echo -e "\n${GREEN}Docker 磁盘使用情况：${NC}"
docker system df -v 2>/dev/null || echo "无法获取磁盘使用情况"

echo -e "\n${BLUE}=== 检查完成 ===${NC}" 