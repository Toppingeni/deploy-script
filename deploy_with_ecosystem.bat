@echo off
setlocal enabledelayedexpansion
if "%~1"=="" (
    echo Usage: deploy_with_ecosystem.bat [start^|stop^|restart^|status^|logs] [appName] [configFile^]
    exit /b 1
)

if "%~2"=="" (
    echo [ERROR] Application name is required
    echo Usage: deploy_with_ecosystem.bat [start^|stop^|restart^|status^|logs] [appName] [configFile^]
    exit /b 1
)

set action=%~1
set appName=%~2

set configFile=ecosystem.config.cjs
if not "%~3"=="" (
    set configFile=%~3
)

where pm2 >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] PM2 is not installed or not in PATH
    exit /b 1
)

if /i "%action%"=="start" (
    call :CheckRunning
    if !isRunning! equ 1 (
        echo [INFO] %appName% is already running, restarting...
        pm2 restart "%appName%"
    ) else (
        :: เช็คว่ามีไฟล์ config มั้ย เฉพาะตอน start ใหม่
        if not exist "%configFile%" (
            echo [ERROR] Config file "%configFile%" not found
            exit /b 1
        )
        echo [INFO] Starting %appName% using "%configFile%"...
        pm2 start "%configFile%" --only "%appName%"
        pm2 save
    )
) else if /i "%action%"=="stop" (
    call :CheckRunning
    if !isRunning! equ 1 (
        echo [INFO] Stopping %appName%...
        pm2 stop "%appName%"
    ) else (
        echo [INFO] %appName% is not running
    )
) else if /i "%action%"=="restart" (
    call :CheckRunning
    if !isRunning! equ 1 (
        echo [INFO] Restarting %appName%...
        pm2 restart "%appName%"
    ) else (
        :: ยังไม่รันมาก่อน ให้ start จาก config แทน
        if not exist "%configFile%" (
            echo [ERROR] Config file "%configFile%" not found
            exit /b 1
        )
        echo [INFO] %appName% is not running, starting instead using "%configFile%"...
        pm2 start "%configFile%" --only "%appName%"
        pm2 save
    )
) else if /i "%action%"=="status" (
    pm2 show "%appName%"
) else if /i "%action%"=="logs" (
    pm2 logs "%appName%"
) else (
    echo [ERROR] Invalid action: %action%
    echo Usage: deploy.bat [start^|stop^|restart^|status^|logs] [appName] [configFile^]
    exit /b 1
)

exit /b 0

set isRunning=0
pm2 list | findstr /i /c:" %appName% " >nul && set isRunning=1
goto :eof
