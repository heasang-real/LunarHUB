@echo off
title LunarHUB Auto Git Push

:loop
cd /d "C:\Users\junya\OneDrive\Documents\yap\Development\LunarHUB"

git add .

git diff --cached --quiet
if not %errorlevel%==0 (
git commit -m "Auto Update %date% %time%"
git push origin main
)

echo [%date% %time%] Checked. Waiting 1 hour...
timeout /t 3600 /nobreak >nul

goto loop