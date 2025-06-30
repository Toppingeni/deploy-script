@echo off
setlocal enabledelayedexpansion

:: Check if minimum parameters are passed
if "%~1"=="" (
    echo Usage: deploy.bat [start^|stop^|restart^|status^|logs] [appName]
    exit /b 1
)

if "%~2"=="" (
    echo [ERROR] Application name is required
    echo Usage: deploy.bat [start^|stop^|restart^|status^|logs] [appName]
    exit /b 1
)

:: Configuration
set action=%~1
set appName=%~2
set entryPoint=.\build\server.js

:: Check if PM2 is installed
where pm2 >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] PM2 is not installed or not in PATH
    exit /b 1
)

:: Main logic
if /i "%action%"=="start" (
    call :CheckRunning
    if !isRunning! equ 1 (
        echo [INFO] %appName% is already running, restarting...
        pm2 restart %appName%
    ) else (
        echo [INFO] Starting %appName%...
        pm2 start "%entryPoint%" --name "%appName%"
        pm2 save
    )
) else if /i "%action%"=="stop" (
    call :CheckRunning
    if !isRunning! equ 1 (
        echo [INFO] Stopping %appName%...
        pm2 stop %appName%
    ) else (
        echo [INFO] %appName% is not running
    )
) else if /i "%action%"=="restart" (
    call :CheckRunning
    if !isRunning! equ 1 (
        echo [INFO] Restarting %appName%...
        pm2 restart %appName%
    ) else (
        echo [INFO] %appName% is not running, starting instead...
        pm2 start "%entryPoint%" --name "%appName%"
        pm2 save
    )
) else if /i "%action%"=="status" (
    pm2 show %appName%
) else if /i "%action%"=="logs" (
    pm2 logs %appName%
) else (
    echo [ERROR] Invalid action: %action%
    echo Usage: deploy.bat [start^|stop^|restart^|status^|logs] [appName]
    exit /b 1
)

exit /b 0

:CheckRunning
set isRunning=0
pm2 list | findstr /i /c:"%appName%" >nul && set isRunning=1
goto :eof