#!/bin/bash

# =====================================================
# 🌾 农作物种植生产管理系统 - 停止脚本
# Crop Management System - Stop Script
# =====================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PIDS_DIR="$PROJECT_ROOT/.pids"

# Ports
BACKEND_PORT=8080
FRONTEND_PORT=3000
ADMIN_PORT=3002

echo -e "${BLUE}正在停止所有服务...${NC}"

# Function: Kill process by PID file
kill_by_pidfile() {
    local pidfile=$1
    local service=$2
    
    if [ -f "$pidfile" ]; then
        PID=$(cat "$pidfile")
        if ps -p "$PID" > /dev/null 2>&1; then
            echo -e "${YELLOW}停止 $service (PID: $PID)...${NC}"
            kill "$PID" 2>/dev/null || true
            sleep 1
            # Force kill if still running
            if ps -p "$PID" > /dev/null 2>&1; then
                kill -9 "$PID" 2>/dev/null || true
            fi
            echo -e "${GREEN}✓ $service 已停止${NC}"
        else
            echo -e "${YELLOW}$service 进程不存在 (PID: $PID)${NC}"
        fi
        rm -f "$pidfile"
    fi
}

# Function: Kill process by port
kill_by_port() {
    local port=$1
    local service=$2
    
    PIDS=$(lsof -ti:$port 2>/dev/null || echo "")
    if [ -n "$PIDS" ]; then
        echo -e "${YELLOW}停止 $service (端口: $port)...${NC}"
        echo "$PIDS" | xargs kill -9 2>/dev/null || true
        echo -e "${GREEN}✓ $service 已停止${NC}"
    fi
}

# Kill by PID files
if [ -d "$PIDS_DIR" ]; then
    kill_by_pidfile "$PIDS_DIR/backend.pid" "后端服务"
    kill_by_pidfile "$PIDS_DIR/frontend.pid" "前端服务"
    kill_by_pidfile "$PIDS_DIR/admin.pid" "管理端服务"
fi

# Kill by ports (backup method)
kill_by_port $BACKEND_PORT "后端服务"
kill_by_port $FRONTEND_PORT "前端服务"
kill_by_port $ADMIN_PORT "管理端服务"

# Cleanup PID directory
if [ -d "$PIDS_DIR" ]; then
    rm -rf "$PIDS_DIR"
    echo -e "${GREEN}✓ 已清理 PID 目录${NC}"
fi

echo -e "${GREEN}✓ 所有服务已停止${NC}"
