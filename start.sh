#!/bin/bash

# =====================================================
# 🌾 农作物种植生产管理系统 - 一键启动脚本 (macOS)
# Crop Management System - One-Click Startup (macOS)
# =====================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

# Directories
BACKEND_DIR="$PROJECT_ROOT/backend"
FRONTEND_DIR="$PROJECT_ROOT/frontend"
ADMIN_DIR="$PROJECT_ROOT/admin"
SQL_DIR="$PROJECT_ROOT/sql"
PIDS_DIR="$PROJECT_ROOT/.pids"
LOGS_DIR="$PROJECT_ROOT/.logs"

# Database config
DB_HOST="localhost"
DB_PORT="3306"
DB_NAME="crop_management"
DB_USER="root"
DB_PASS="ab123168"

# Ports
BACKEND_PORT=8080
FRONTEND_PORT=3000
ADMIN_PORT=3002

# Banner
echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════╗"
echo "║                                                       ║"
echo "║   🌾  农作物种植生产管理系统 — 一键启动脚本 (macOS)   ║"
echo "║       Crop Management System — One-Click Start        ║"
echo "║                                                       ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Create directories
mkdir -p "$PIDS_DIR"
mkdir -p "$LOGS_DIR"

# =====================================================
# STEP 1: 检查并安装依赖 (Homebrew)
# =====================================================
echo -e "${CYAN}${BOLD}[STEP 1/5] 检查并安装依赖环境...${NC}"
echo ""

# Check Homebrew
if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}⏳ Homebrew 未安装，正在安装...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ $? -ne 0 ]; then
        echo -e "${RED}✗ Homebrew 安装失败，请手动安装后重试${NC}"
        exit 1
    fi
    # Add brew to PATH (Apple Silicon)
    if [ -f "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    echo -e "${GREEN}✓ Homebrew 安装成功${NC}"
else
    echo -e "${GREEN}✓ Homebrew 已安装${NC}"
fi

# Check Java 17
if ! command -v java &> /dev/null || ! java -version 2>&1 | grep -q "17"; then
    echo -e "${YELLOW}⏳ Java 17 未安装，正在通过 Homebrew 安装...${NC}"
    brew install openjdk@17
    # Link Java 17
    sudo ln -sfn "$(brew --prefix openjdk@17)/libexec/openjdk.jdk" /Library/Java/JavaVirtualMachines/openjdk-17.jdk 2>/dev/null || true
    export JAVA_HOME="$(brew --prefix openjdk@17)/libexec/openjdk.jdk/Contents/Home"
    export PATH="$JAVA_HOME/bin:$PATH"
    if java -version 2>&1 | grep -q "17"; then
        echo -e "${GREEN}✓ Java 17 安装成功${NC}"
    else
        echo -e "${RED}✗ Java 17 安装失败${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ Java 17 已安装 ($(java -version 2>&1 | head -1))${NC}"
fi

# Check Maven
if ! command -v mvn &> /dev/null; then
    echo -e "${YELLOW}⏳ Maven 未安装，正在通过 Homebrew 安装...${NC}"
    brew install maven
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Maven 安装成功${NC}"
    else
        echo -e "${RED}✗ Maven 安装失败${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ Maven 已安装 ($(mvn -version 2>&1 | head -1))${NC}"
fi

# Check Node.js
if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}⏳ Node.js 未安装，正在通过 Homebrew 安装...${NC}"
    brew install node
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Node.js 安装成功${NC}"
    else
        echo -e "${RED}✗ Node.js 安装失败${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ Node.js 已安装 ($(node -v))${NC}"
fi

# Check pnpm
if ! command -v pnpm &> /dev/null; then
    echo -e "${YELLOW}⏳ pnpm 未安装，正在通过 Homebrew 安装...${NC}"
    brew install pnpm
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ pnpm 安装成功${NC}"
    else
        echo -e "${RED}✗ pnpm 安装失败${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ pnpm 已安装 ($(pnpm -v))${NC}"
fi

# Check MySQL
if ! command -v mysql &> /dev/null; then
    echo -e "${YELLOW}⏳ MySQL 未安装，正在通过 Homebrew 安装...${NC}"
    brew install mysql
    brew services start mysql
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ MySQL 安装并启动成功${NC}"
        # Set root password
        echo -e "${YELLOW}⏳ 正在设置 MySQL root 密码...${NC}"
        mysqladmin -u root password "$DB_PASS" 2>/dev/null || true
    else
        echo -e "${RED}✗ MySQL 安装失败${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ MySQL 已安装${NC}"
    # Ensure MySQL service is running
    if ! brew services list 2>/dev/null | grep -q "mysql.*started"; then
        echo -e "${YELLOW}⏳ MySQL 服务未运行，正在启动...${NC}"
        brew services start mysql
        sleep 2
    fi
    echo -e "${GREEN}✓ MySQL 服务正在运行${NC}"
fi

echo ""

# =====================================================
# STEP 2: 检查并初始化数据库
# =====================================================
echo -e "${CYAN}${BOLD}[STEP 2/5] 检查并初始化数据库...${NC}"
echo ""

if command -v mysql &> /dev/null; then
    # Test MySQL connection
    if ! mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASS" -e "SELECT 1;" &>/dev/null; then
        echo -e "${RED}✗ 无法连接到 MySQL（host=$DB_HOST, port=$DB_PORT, user=$DB_USER）${NC}"
        echo -e "${YELLOW}  请检查 MySQL 是否正在运行，以及用户名密码是否正确${NC}"
        exit 1
    fi

    # Check if database exists
    DB_EXISTS=$(mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASS" -e "SHOW DATABASES LIKE '$DB_NAME';" 2>/dev/null | grep -c "$DB_NAME" || echo "0")

    if [ "$DB_EXISTS" -eq 0 ]; then
        echo -e "${YELLOW}⏳ 数据库 $DB_NAME 不存在，正在创建并导入数据...${NC}"

        if [ -f "$SQL_DIR/init.sql" ]; then
            mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASS" --default-character-set=utf8mb4 < "$SQL_DIR/init.sql" 2>/dev/null
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}  ✓ 数据库结构初始化成功 (init.sql)${NC}"
            else
                echo -e "${RED}  ✗ 数据库初始化失败${NC}"
                exit 1
            fi
        fi

        if [ -f "$SQL_DIR/data.sql" ]; then
            mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASS" --default-character-set=utf8mb4 "$DB_NAME" < "$SQL_DIR/data.sql" 2>/dev/null
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}  ✓ 测试数据导入成功 (data.sql)${NC}"
            else
                echo -e "${YELLOW}  ⚠ 测试数据导入失败（可能已存在）${NC}"
            fi
        fi
    else
        echo -e "${GREEN}✓ 数据库 $DB_NAME 已存在${NC}"
    fi
else
    echo -e "${RED}✗ mysql 命令不可用，跳过数据库检查${NC}"
fi

echo ""

# =====================================================
# STEP 3: 检查端口占用并释放
# =====================================================
echo -e "${CYAN}${BOLD}[STEP 3/5] 检查端口占用...${NC}"
echo ""

kill_port() {
    local port=$1
    local name=$2
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        PIDS=$(lsof -ti:$port)
        echo -e "${YELLOW}⚠ 端口 $port ($name) 被占用，正在释放...${NC}"
        echo "$PIDS" | xargs kill -9 2>/dev/null || true
        sleep 1
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
            echo -e "${RED}✗ 无法释放端口 $port${NC}"
            exit 1
        fi
        echo -e "${GREEN}  ✓ 端口 $port 已释放${NC}"
    else
        echo -e "${GREEN}✓ 端口 $port ($name) 可用${NC}"
    fi
}

kill_port $BACKEND_PORT "后端服务"
kill_port $FRONTEND_PORT "用户端"
kill_port $ADMIN_PORT "管理端"

echo ""

# =====================================================
# STEP 4: 编译后端 & 安装前端依赖
# =====================================================
echo -e "${CYAN}${BOLD}[STEP 4/5] 编译后端 & 安装前端依赖...${NC}"
echo ""

# Compile backend
if [ ! -d "$BACKEND_DIR/target/classes" ]; then
    echo -e "${YELLOW}⏳ 后端未编译，正在编译...${NC}"
    cd "$BACKEND_DIR"
    mvn compile -q 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ 后端编译成功${NC}"
    else
        echo -e "${RED}✗ 后端编译失败，请查看上方错误信息${NC}"
        exit 1
    fi
    cd "$PROJECT_ROOT"
else
    echo -e "${GREEN}✓ 后端已编译${NC}"
fi

# Install frontend dependencies
if [ ! -d "$FRONTEND_DIR/node_modules" ]; then
    echo -e "${YELLOW}⏳ 用户端依赖未安装，正在安装...${NC}"
    cd "$FRONTEND_DIR"
    pnpm install 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ 用户端依赖安装成功${NC}"
    else
        echo -e "${RED}✗ 用户端依赖安装失败${NC}"
        exit 1
    fi
    cd "$PROJECT_ROOT"
else
    echo -e "${GREEN}✓ 用户端依赖已安装${NC}"
fi

# Install admin dependencies
if [ ! -d "$ADMIN_DIR/node_modules" ]; then
    echo -e "${YELLOW}⏳ 管理端依赖未安装，正在安装...${NC}"
    cd "$ADMIN_DIR"
    pnpm install 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ 管理端依赖安装成功${NC}"
    else
        echo -e "${RED}✗ 管理端依赖安装失败${NC}"
        exit 1
    fi
    cd "$PROJECT_ROOT"
else
    echo -e "${GREEN}✓ 管理端依赖已安装${NC}"
fi

echo ""

# =====================================================
# STEP 5: 启动所有服务
# =====================================================
echo -e "${CYAN}${BOLD}[STEP 5/5] 启动所有服务...${NC}"
echo ""

# Cleanup function
cleanup() {
    echo ""
    echo -e "${YELLOW}正在停止所有服务...${NC}"
    # Kill tail process
    if [ -n "$TAIL_PID" ]; then
        kill "$TAIL_PID" 2>/dev/null || true
    fi
    # Kill services
    for pidfile in "$PIDS_DIR"/*.pid; do
        if [ -f "$pidfile" ]; then
            PID=$(cat "$pidfile")
            kill "$PID" 2>/dev/null || true
        fi
    done
    # Force kill by ports
    lsof -ti:$BACKEND_PORT | xargs kill -9 2>/dev/null || true
    lsof -ti:$FRONTEND_PORT | xargs kill -9 2>/dev/null || true
    lsof -ti:$ADMIN_PORT | xargs kill -9 2>/dev/null || true
    # Cleanup
    rm -rf "$PIDS_DIR"
    echo -e "${GREEN}✓ 所有服务已停止${NC}"
    exit 0
}

trap cleanup INT TERM

# Clear old logs
> "$LOGS_DIR/backend.log"
> "$LOGS_DIR/frontend.log"
> "$LOGS_DIR/admin.log"

# Start backend
echo -e "${BLUE}  ⏳ 启动后端服务...${NC}"
cd "$BACKEND_DIR"
nohup mvn spring-boot:run > "$LOGS_DIR/backend.log" 2>&1 &
BACKEND_PID=$!
echo $BACKEND_PID > "$PIDS_DIR/backend.pid"
cd "$PROJECT_ROOT"
echo -e "${GREEN}  ✓ 后端服务已启动 (PID: $BACKEND_PID)${NC}"

# Start frontend (用户端)
echo -e "${BLUE}  ⏳ 启动用户端...${NC}"
cd "$FRONTEND_DIR"
nohup pnpm dev > "$LOGS_DIR/frontend.log" 2>&1 &
FRONTEND_PID=$!
echo $FRONTEND_PID > "$PIDS_DIR/frontend.pid"
cd "$PROJECT_ROOT"
echo -e "${GREEN}  ✓ 用户端已启动 (PID: $FRONTEND_PID)${NC}"

# Start admin (管理端)
echo -e "${BLUE}  ⏳ 启动管理端...${NC}"
cd "$ADMIN_DIR"
nohup pnpm dev:linux > "$LOGS_DIR/admin.log" 2>&1 &
ADMIN_PID=$!
echo $ADMIN_PID > "$PIDS_DIR/admin.pid"
cd "$PROJECT_ROOT"
echo -e "${GREEN}  ✓ 管理端已启动 (PID: $ADMIN_PID)${NC}"

# Wait for services to be ready
echo ""
echo -e "${YELLOW}⏳ 等待服务启动（约 30 秒）...${NC}"
MAX_WAIT=60
WAIT=0
BACKEND_READY=false
FRONTEND_READY=false
ADMIN_READY=false

while [ $WAIT -lt $MAX_WAIT ]; do
    if [ "$BACKEND_READY" = false ] && lsof -Pi :$BACKEND_PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "${GREEN}  ✓ 后端服务已就绪 (端口 $BACKEND_PORT)${NC}"
        BACKEND_READY=true
    fi
    if [ "$FRONTEND_READY" = false ] && lsof -Pi :$FRONTEND_PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "${GREEN}  ✓ 用户端已就绪 (端口 $FRONTEND_PORT)${NC}"
        FRONTEND_READY=true
    fi
    if [ "$ADMIN_READY" = false ] && lsof -Pi :$ADMIN_PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "${GREEN}  ✓ 管理端已就绪 (端口 $ADMIN_PORT)${NC}"
        ADMIN_READY=true
    fi
    if [ "$BACKEND_READY" = true ] && [ "$FRONTEND_READY" = true ] && [ "$ADMIN_READY" = true ]; then
        break
    fi
    sleep 2
    WAIT=$((WAIT + 2))
done

echo ""

if [ "$BACKEND_READY" = false ]; then
    echo -e "${RED}  ⚠ 后端服务启动超时，请查看日志: $LOGS_DIR/backend.log${NC}"
fi
if [ "$FRONTEND_READY" = false ]; then
    echo -e "${RED}  ⚠ 用户端启动超时，请查看日志: $LOGS_DIR/frontend.log${NC}"
fi
if [ "$ADMIN_READY" = false ]; then
    echo -e "${RED}  ⚠ 管理端启动超时，请查看日志: $LOGS_DIR/admin.log${NC}"
fi

# =====================================================
# 打印启动信息
# =====================================================
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║            ✅  所有服务已启动完成！                  ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}📌 访问地址:${NC}"
echo -e "   后端 API:    ${BLUE}http://localhost:$BACKEND_PORT${NC}"
echo -e "   用户端门户:  ${BLUE}http://localhost:$FRONTEND_PORT${NC}"
echo -e "   管理后台:    ${BLUE}http://localhost:$ADMIN_PORT${NC}"
echo ""
echo -e "${CYAN}🔑 测试账号（密码均为 ${BOLD}123456${NC}${CYAN}）:${NC}"
echo -e "   ┌──────────┬──────────────┬──────────────┐"
echo -e "   │ ${BOLD}角色${NC}     │ ${BOLD}用户名${NC}       │ ${BOLD}密码${NC}         │"
echo -e "   ├──────────┼──────────────┼──────────────┤"
echo -e "   │ 管理员   │ ${YELLOW}admin${NC}        │ ${YELLOW}123456${NC}       │"
echo -e "   │ 技术员   │ ${YELLOW}tech01${NC}       │ ${YELLOW}123456${NC}       │"
echo -e "   │ 种植户   │ ${YELLOW}farmer01${NC}     │ ${YELLOW}123456${NC}       │"
echo -e "   └──────────┴──────────────┴──────────────┘"
echo ""
echo -e "${CYAN}📋 日志文件:${NC}"
echo -e "   后端日志:   ${MAGENTA}$LOGS_DIR/backend.log${NC}"
echo -e "   用户端日志: ${MAGENTA}$LOGS_DIR/frontend.log${NC}"
echo -e "   管理端日志: ${MAGENTA}$LOGS_DIR/admin.log${NC}"
echo ""
echo -e "${YELLOW}💡 按 Ctrl+C 停止所有服务${NC}"
echo -e "${YELLOW}📺 下方实时显示所有服务日志（包括错误输出）...${NC}"
echo ""
echo -e "${CYAN}═══════════════════ 实时日志 ═══════════════════${NC}"
echo ""

# Tail all logs in real-time (including errors)
tail -f "$LOGS_DIR/backend.log" "$LOGS_DIR/frontend.log" "$LOGS_DIR/admin.log" &
TAIL_PID=$!

# Wait for tail or signal
wait $TAIL_PID 2>/dev/null || true

# Keep script running
while true; do
    sleep 1
done
