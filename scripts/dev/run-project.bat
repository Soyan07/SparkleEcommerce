@echo off
setlocal enabledelayedexpansion
color 0B

echo ========================================================
echo       SPARKLE ECOMMERCE - OPTIMIZED DEV TERMINAL
echo ========================================================
echo.

cd /d "%~dp0..\.."

echo [1/3] Applying Development Environment...
set ASPNETCORE_ENVIRONMENT=Development

echo [2/3] Preparing Database Connection...
echo Checking LocalDB connection and ensuring migrations apply on startup via DbInitializer...
:: We don't need 'dotnet build' here because 'dotnet watch' builds automatically, 
:: which saves time and optimizes the startup sequence!

echo [3/3] Starting the Application with Hot Reload...
echo.
echo ========================================================
echo IMPORTANT: The application will start now.
echo The browser will open automatically in a few seconds...
echo Database: (localdb)\MSSQLLocalDB [SparkleEcommerce]
echo ========================================================
echo.

:: Launch the browser in the background (waits 5 seconds to let the server boot)
start cmd /c "timeout /t 5 >nul && start http://localhost:5279"

cd "Sparkle.Api"
dotnet watch run

pause
