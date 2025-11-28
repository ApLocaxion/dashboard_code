@echo off
setlocal enabledelayedexpansion

echo ============================================
echo   Dev Stack Bootstrap
echo ============================================
echo.

:: ---------------------------------------------------------
:: STEP 1 — Start Docker Desktop and wait for engine
:: ---------------------------------------------------------
set "STEP=Starting Docker Desktop"
echo [STEP] !STEP!

start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe" >NUL 2>&1

echo Waiting for Docker Engine to be ready...

:wait_docker
docker info >NUL 2>&1
if errorlevel 1 (
    echo   Docker is not ready yet... retrying in 3 seconds
    timeout /t 3 /nobreak >NUL
    goto :wait_docker
)

echo   Docker Engine is running.
echo.

:: ---------------------------------------------------------
:: STEP 2 — Git Pull
:: ---------------------------------------------------------
set "STEP=git pull --force"
echo [STEP] !STEP!
git pull --force
if errorlevel 1 goto :fail

:: ---------------------------------------------------------
:: STEP 3 — Stop running containers (if any)
:: ---------------------------------------------------------
echo.
set "STEP=Stopping running containers"
echo [STEP] !STEP!

for /f "delims=" %%I in ('docker ps -q') do (
    echo   Stopping container %%I
    docker stop %%I >NUL 2>&1
)

:: ---------------------------------------------------------
:: STEP 4 — Remove all containers (if any)
:: ---------------------------------------------------------
echo.
set "STEP=Removing containers"
echo [STEP] !STEP!

for /f "delims=" %%I in ('docker ps -aq') do (
    echo   Removing container %%I
    docker rm -f %%I >NUL 2>&1
)

:: ---------------------------------------------------------
:: STEP 5 — Build images
:: ---------------------------------------------------------
echo.
set "STEP=docker compose build --no-cache"
echo [STEP] !STEP!
docker compose build --no-cache
if errorlevel 1 goto :fail

:: ---------------------------------------------------------
:: STEP 6 — Start stack
:: ---------------------------------------------------------
echo.
set "STEP=docker compose up -d"
echo [STEP] !STEP!
docker compose up -d
if errorlevel 1 goto :fail

echo.
echo ============================================
echo   SUCCESS: stack is up and running.
echo ============================================
echo.

:: ---------------------------------------------------------
:: STEP 7 — Open browser
:: ---------------------------------------------------------
set "STEP=Open browser"
echo [STEP] !STEP!
echo   Opening http://localhost:8080 ...
explorer "http://localhost:8080"

echo Done.
exit /b 0

:fail
echo.
echo ********************************************
echo   FAILURE during "!STEP!" (exit code %errorlevel%).
echo ********************************************
exit /b 1
