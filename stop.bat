@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM =====================================================
REM 🌾 农作物种植生产管理系统 - 停止脚本 (Windows)
REM Crop Management System - Stop Script (Windows)
REM =====================================================

set "BACKEND_PORT=8080"
set "FRONTEND_PORT=3000"
set "ADMIN_PORT=3002"

echo.
echo =====================================================
echo 正在停止所有服务...
echo =====================================================
echo.

REM Function: Kill process by port
set "KILLED=0"

REM Kill backend
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%BACKEND_PORT% " ^| findstr "LISTENING"') do (
    echo 停止后端服务 (PID: %%a)...
    taskkill /F /PID %%a >nul 2>&1
    if not errorlevel 1 (
        echo [✓] 后端服务已停止
        set "KILLED=1"
    )
)

REM Kill frontend
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%FRONTEND_PORT% " ^| findstr "LISTENING"') do (
    echo 停止前端服务 (PID: %%a)...
    taskkill /F /PID %%a >nul 2>&1
    if not errorlevel 1 (
        echo [✓] 前端服务已停止
        set "KILLED=1"
    )
)

REM Kill admin
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%ADMIN_PORT% " ^| findstr "LISTENING"') do (
    echo 停止管理端服务 (PID: %%a)...
    taskkill /F /PID %%a >nul 2>&1
    if not errorlevel 1 (
        echo [✓] 管理端服务已停止
        set "KILLED=1"
    )
)

REM Note: We only kill processes by port to avoid killing unrelated Java/Node processes
REM If you need to kill all Java/Node processes, uncomment the sections below:
REM
REM REM Also kill Java processes (backend) - WARNING: This kills ALL Java processes
REM echo.
REM echo 检查 Java 进程...
REM for /f "tokens=2" %%a in ('tasklist ^| findstr /i "java.exe"') do (
REM     echo 停止 Java 进程 (PID: %%a)...
REM     taskkill /F /PID %%a >nul 2>&1
REM     if not errorlevel 1 (
REM         echo [✓] Java 进程已停止
REM         set "KILLED=1"
REM     )
REM )
REM
REM REM Also kill Node processes (frontend/admin) - WARNING: This kills ALL Node processes
REM echo.
REM echo 检查 Node 进程...
REM for /f "tokens=2" %%a in ('tasklist ^| findstr /i "node.exe"') do (
REM     echo 停止 Node 进程 (PID: %%a)...
REM     taskkill /F /PID %%a >nul 2>&1
REM     if not errorlevel 1 (
REM         echo [✓] Node 进程已停止
REM         set "KILLED=1"
REM     )
REM )

if "%KILLED%"=="0" (
    echo [信息] 未找到运行中的服务
) else (
    echo.
    echo [✓] 所有服务已停止
)

echo.
pause
