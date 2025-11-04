@echo off
setlocal enabledelayedexpansion

:: ตรวจว่ามีพารามิเตอร์ไหม
if "%~1"=="" (
  echo Usage: createconfigpm2.bat [path]
  exit /b 1
)

:: รับ path ที่ส่งเข้ามา
set TARGET_PATH=%~1

:: ตั้งชื่อไฟล์ config
set CONFIG_FILE=%TARGET_PATH%\ecosystem.config.cjs

:: สร้างโฟลเดอร์ logs ถ้ายังไม่มี
if not exist "%TARGET_PATH%\logs" mkdir "%TARGET_PATH%\logs"

:: เขียนไฟล์ config
(
echo module.exports = {
echo   apps: [
echo     {
echo       name: 'kim-pai-repair-flow',
echo       cwd: '%TARGET_PATH%',
echo       script: 'dist\\server\\node-build.mjs',
echo       interpreter: 'node',
echo       env: {
echo         NODE_ENV: 'production',
echo       },
echo       time: true,
echo       out_file: 'logs\\out.log',
echo       error_file: 'logs\\error.log',
echo       exec_mode: 'fork',
echo       instances: 1,
echo       windowsHide: false,
echo     },
echo   ],
echo };
) > "%CONFIG_FILE%"

echo.
echo ✅ Created PM2 config: %CONFIG_FILE%
