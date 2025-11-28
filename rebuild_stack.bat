@echo off
setlocal enabledelayedexpansion

set STEP=git pull --force
echo Running !STEP!
git pull --force
if errorlevel 1 goto :fail

echo.
set STEP=stopping running containers
echo Running !STEP!
for /f "delims=" %%i in ('docker ps -q') do docker stop %%i >NUL
if errorlevel 1 goto :fail

echo.
set STEP=removing containers
echo Running !STEP!
for /f "delims=" %%i in ('docker ps -aq') do docker rm -f %%i >NUL
if errorlevel 1 goto :fail

echo.
set STEP=docker compose build --no-cache
echo Running !STEP!
docker compose build --no-cache
if errorlevel 1 goto :fail

echo.
set STEP=docker compose up -d
echo Running !STEP!
docker compose up -d
if errorlevel 1 goto :fail

echo.
echo SUCCESS: stack is up.
REM Open browser to http://localhost:8080
start "" "http://localhost:8080"
exit /b 0

:fail
echo FAILURE during "!STEP!" (exit code %errorlevel%).
exit /b 1
