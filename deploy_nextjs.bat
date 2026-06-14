@echo off
setlocal enabledelayedexpansion
:: nextjs deploy via PM2 - start runs the Next.js binary directly with node
:: (pm2 start npm fails on Windows: PM2 runs NPM.CMD as a JS module)
:: pm2 inherits env from the calling shell; the workflow sets PORT/APP_BASE_PATH

if "%~1"=="" (
    echo Usage: deploy_nextjs.bat [start^|stop^|restart^|status^|logs] [appName]
    exit /b 1
)
if "%~2"=="" (
    echo [ERROR] Application name is required
    exit /b 1
)

set action=%~1
set appName=%~2

where pm2 >/dev/null 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] PM2 is not installed or not in PATH
    exit /b 1
)

if /i "%action%"=="start" (
    echo [INFO] Starting %appName% from a clean slate...
    pm2 delete "%appName%" >/dev/null 2>&1
    pm2 start node_modules/next/dist/bin/next --name "%appName%" --interpreter node -- start
    pm2 save
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
        echo [INFO] Restarting %appName% with updated env...
        pm2 restart %appName% --update-env
    ) else (
        echo [INFO] %appName% is not running, starting instead...
        pm2 start node_modules/next/dist/bin/next --name "%appName%" --interpreter node -- start
        pm2 save
    )
) else if /i "%action%"=="status" (
    pm2 show %appName%
) else if /i "%action%"=="logs" (
    pm2 logs %appName%
) else (
    echo [ERROR] Invalid action: %action%
    exit /b 1
)

exit /b 0

:CheckRunning
set isRunning=0
pm2 list | findstr /i /c:"%appName%" >/dev/null && set isRunning=1
goto :eof
