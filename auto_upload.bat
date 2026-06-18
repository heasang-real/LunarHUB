@echo off
chcp 65001 >nul
title LunarHUB Auto Uploader

:loop
echo [%time%] Uploading...
git add .
git commit -m "Auto-update: %date% %time%"
git push origin main
echo [%time%] Success! wait 10m...
timeout /t 600 /nobreak
echo.
goto loop