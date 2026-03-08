@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM =====================================================
REM 🌾 农作物种植生产管理系统 - 一键启动脚本 (Windows)
REM Crop Management System - One-Click Startup (Windows)
REM =====================================================

REM !! 请以 管理员身份 运行此脚本 !!

set "PROJECT_ROOT=%~dp0"
set "BACKEND_DIR=%PROJECT_ROOT%backend"
set "FRONTEND_DIR=%PROJECT_ROOT%frontend"
set "ADMIN_DIR=%PROJECT_ROOT%admin"
set "SQL_DIR=%PROJECT_ROOT%sql"

REM Database config
set "DB_HOST=localhost"
set "DB_PORT=3306"
set "DB_NAME=crop_management"
set "DB_USER=root"
set "DB_PASS=ab123168"

REM Ports
set "BACKEND_PORT=8080"
set "FRONTEND_PORT=3000"
set "ADMIN_PORT=3002"

echo.
echo ╔═══════════════════════════════════════════════════════╗
echo ║                                                       ║
echo ║  🌾  农作物种植生产管理系统 — 一键启动脚本 (Windows)  ║
echo ║      Crop Management System — One-Click Start         ║
echo ║                                                       ║
echo ╚═══════════════════════════════════════════════════════╝
echo.

REM =====================================================
REM STEP 1: 检查并安装依赖 (Chocolatey)
REM =====================================================
echo [STEP 1/5] 检查并安装依赖环境...
echo.

REM Check Chocolatey
where choco >nul 2>&1
if errorlevel 1 (
    echo [!] Chocolatey 未安装，正在安装...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    if errorlevel 1 (
        echo [X] Chocolatey 安装失败
        pause
        exit /b 1
    )
    REM Refresh PATH
    call refreshenv >nul 2>&1
    set "PATH=%ALLUSERSPROFILE%\chocolatey\bin;%PATH%"
    echo [V] Chocolatey 安装成功
) else (
    echo [V] Chocolatey 已安装
)

REM Check Java 17
where java >nul 2>&1
if errorlevel 1 (
    echo [!] Java 17 未安装，正在通过 Chocolatey 安装...
    choco install temurin17 -y
    call refreshenv >nul 2>&1
    where java >nul 2>&1
    if errorlevel 1 (
        echo [X] Java 17 安装失败
        pause
        exit /b 1
    )
    echo [V] Java 17 安装成功
) else (
    echo [V] Java 已安装
)

REM Check Maven
where mvn >nul 2>&1
if errorlevel 1 (
    echo [!] Maven 未安装，正在通过 Chocolatey 安装...
    choco install maven -y
    call refreshenv >nul 2>&1
    where mvn >nul 2>&1
    if errorlevel 1 (
        echo [X] Maven 安装失败
        pause
        exit /b 1
    )
    echo [V] Maven 安装成功
) else (
    echo [V] Maven 已安装
)

REM Check Node.js
where node >nul 2>&1
if errorlevel 1 (
    echo [!] Node.js 未安装，正在通过 Chocolatey 安装...
    choco install nodejs-lts -y
    call refreshenv >nul 2>&1
    where node >nul 2>&1
    if errorlevel 1 (
        echo [X] Node.js 安装失败
        pause
        exit /b 1
    )
    echo [V] Node.js 安装成功
) else (
    echo [V] Node.js 已安装
)

REM Check pnpm
where pnpm >nul 2>&1
if errorlevel 1 (
    echo [!] pnpm 未安装，正在通过 Chocolatey 安装...
    choco install pnpm -y
    call refreshenv >nul 2>&1
    where pnpm >nul 2>&1
    if errorlevel 1 (
        echo [X] pnpm 安装失败
        pause
        exit /b 1
    )
    echo [V] pnpm 安装成功
) else (
    echo [V] pnpm 已安装
)

REM Check MySQL
where mysql >nul 2>&1
if errorlevel 1 (
    echo [!] MySQL 未安装，正在通过 Chocolatey 安装...
    choco install mysql -y
    call refreshenv >nul 2>&1
    where mysql >nul 2>&1
    if errorlevel 1 (
        echo [!] MySQL 安装失败或需要重启终端
    ) else (
        echo [V] MySQL 安装成功
    )
) else (
    echo [V] MySQL 已安装
)

REM Check MySQL service
echo.
echo 检查 MySQL 服务...
sc query MySQL >nul 2>&1
if errorlevel 1 (
    sc query MySQL80 >nul 2>&1
    if errorlevel 1 (
        sc query MySQL83 >nul 2>&1
        if errorlevel 1 (
            echo [!] MySQL 服务可能未运行，请手动启动
        ) else (
            echo [V] MySQL 服务正在运行
        )
    ) else (
        echo [V] MySQL 服务正在运行
    )
) else (
    echo [V] MySQL 服务正在运行
)

echo.

REM =====================================================
REM STEP 2: 检查并初始化数据库
REM =====================================================
echo [STEP 2/5] 检查并初始化数据库...
echo.

where mysql >nul 2>&1
if not errorlevel 1 (
    REM Test connection
    mysql -h%DB_HOST% -P%DB_PORT% -u%DB_USER% -p%DB_PASS% -e "SELECT 1;" >nul 2>&1
    if errorlevel 1 (
        echo [X] 无法连接到 MySQL
        echo     请检查 MySQL 是否正在运行，以及用户名密码是否正确
        pause
        exit /b 1
    )

    if exist "%SQL_DIR%\init.sql" (
        mysql -h%DB_HOST% -P%DB_PORT% -u%DB_USER% -p%DB_PASS% -e "SHOW DATABASES LIKE 'crop_management';" 2>nul | findstr "crop_management" >nul
        if errorlevel 1 (
            echo 数据库 %DB_NAME% 不存在，正在创建并导入数据...
            mysql -h%DB_HOST% -P%DB_PORT% -u%DB_USER% -p%DB_PASS% --default-character-set=utf8mb4 < "%SQL_DIR%\init.sql" 2>nul
            if not errorlevel 1 (
                echo   [V] 数据库结构初始化成功 (init.sql)
            ) else (
                echo   [X] 数据库初始化失败
            )
            if exist "%SQL_DIR%\data.sql" (
                mysql -h%DB_HOST% -P%DB_PORT% -u%DB_USER% -p%DB_PASS% --default-character-set=utf8mb4 %DB_NAME% < "%SQL_DIR%\data.sql" 2>nul
                if not errorlevel 1 (
                    echo   [V] 测试数据导入成功 (data.sql)
                ) else (
                    echo   [!] 测试数据导入失败（可能已存在）
                )
            )
        ) else (
            echo [V] 数据库 %DB_NAME% 已存在
        )
    )
) else (
    echo [!] mysql 命令不可用，跳过数据库检查
)

echo.

REM =====================================================
REM STEP 3: 检查端口占用并释放
REM =====================================================
echo [STEP 3/5] 检查端口占用...
echo.

call :kill_port %BACKEND_PORT% "后端服务"
call :kill_port %FRONTEND_PORT% "用户端"
call :kill_port %ADMIN_PORT% "管理端"

echo.

REM =====================================================
REM STEP 4: 编译后端 & 安装前端依赖
REM =====================================================
echo [STEP 4/5] 编译后端 ^& 安装前端依赖...
echo.

REM Compile backend
if not exist "%BACKEND_DIR%\target\classes" (
    echo 后端未编译，正在编译...
    cd /d "%BACKEND_DIR%"
    call mvn compile -q
    if errorlevel 1 (
        echo [X] 后端编译失败
        pause
        exit /b 1
    )
    echo [V] 后端编译成功
    cd /d "%PROJECT_ROOT%"
) else (
    echo [V] 后端已编译
)

REM Install frontend dependencies
if not exist "%FRONTEND_DIR%\node_modules" (
    echo 用户端依赖未安装，正在安装...
    cd /d "%FRONTEND_DIR%"
    call pnpm install
    if errorlevel 1 (
        echo [X] 用户端依赖安装失败
        pause
        exit /b 1
    )
    echo [V] 用户端依赖安装成功
    cd /d "%PROJECT_ROOT%"
) else (
    echo [V] 用户端依赖已安装
)

REM Install admin dependencies
if not exist "%ADMIN_DIR%\node_modules" (
    echo 管理端依赖未安装，正在安装...
    cd /d "%ADMIN_DIR%"
    call pnpm install
    if errorlevel 1 (
        echo [X] 管理端依赖安装失败
        pause
        exit /b 1
    )
    echo [V] 管理端依赖安装成功
    cd /d "%PROJECT_ROOT%"
) else (
    echo [V] 管理端依赖已安装
)

echo.

REM =====================================================
REM STEP 5: 启动所有服务
REM =====================================================
echo [STEP 5/5] 启动所有服务...
echo.

REM Start backend (separate window, errors visible)
echo   启动后端服务...
cd /d "%BACKEND_DIR%"
start "🌾 后端服务 - Backend (Port %BACKEND_PORT%)" cmd /k "title 🌾 后端服务 - Backend (Port %BACKEND_PORT%) && mvn spring-boot:run 2>&1"
cd /d "%PROJECT_ROOT%"
echo   [V] 后端服务已启动 (新窗口)

REM Wait a moment
timeout /t 3 /nobreak >nul

REM Start frontend (separate window, errors visible)
echo   启动用户端...
cd /d "%FRONTEND_DIR%"
start "🌾 用户端 - Frontend (Port %FRONTEND_PORT%)" cmd /k "title 🌾 用户端 - Frontend (Port %FRONTEND_PORT%) && pnpm dev 2>&1"
cd /d "%PROJECT_ROOT%"
echo   [V] 用户端已启动 (新窗口)

REM Wait a moment
timeout /t 2 /nobreak >nul

REM Start admin (separate window, errors visible)
echo   启动管理端...
cd /d "%ADMIN_DIR%"
start "🌾 管理端 - Admin (Port %ADMIN_PORT%)" cmd /k "title 🌾 管理端 - Admin (Port %ADMIN_PORT%) && pnpm dev 2>&1"
cd /d "%PROJECT_ROOT%"
echo   [V] 管理端已启动 (新窗口)

echo.

REM =====================================================
REM 打印启动信息
REM =====================================================
echo.
echo ╔═══════════════════════════════════════════════════════╗
echo ║            V  所有服务已启动完成！                    ║
echo ╚═══════════════════════════════════════════════════════╝
echo.
echo 访问地址:
echo   后端 API:    http://localhost:%BACKEND_PORT%
echo   用户端门户:  http://localhost:%FRONTEND_PORT%
echo   管理后台:    http://localhost:%ADMIN_PORT%
echo.
echo 测试账号（密码均为 123456）:
echo   ┌──────────┬──────────────┬──────────────┐
echo   │ 角色     │ 用户名       │ 密码         │
echo   ├──────────┼──────────────┼──────────────┤
echo   │ 管理员   │ admin        │ 123456       │
echo   │ 技术员   │ tech01       │ 123456       │
echo   │ 种植户   │ farmer01     │ 123456       │
echo   └──────────┴──────────────┴──────────────┘
echo.
echo 提示:
echo   - 每个服务在独立的命令行窗口中运行，报错信息会直接显示在对应窗口中
echo   - 关闭对应的命令行窗口即可停止对应的服务
echo   - 或运行 stop.bat 停止所有服务
echo.
pause
goto :eof

REM =====================================================
REM Function: Kill process by port
REM =====================================================
:kill_port
set "P=%~1"
set "N=%~2"
set "FOUND=0"
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%P% " ^| findstr "LISTENING" 2^>nul') do (
    if "%%a" NEQ "0" (
        echo [!] 端口 %P% (%N%) 被占用 (PID: %%a)，正在释放...
        taskkill /F /PID %%a >nul 2>&1
        set "FOUND=1"
    )
)
if "!FOUND!"=="1" (
    echo   [V] 端口 %P% 已释放
) else (
    echo [V] 端口 %P% (%N%) 可用
)
goto :eof
