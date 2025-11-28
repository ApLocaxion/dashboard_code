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



