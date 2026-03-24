@echo off
echo ================================================
echo SPARKLE ECOMMERCE - SQL SERVER SETUP  
echo ================================================
echo.

echo [1/3] Building the project...
cd /d "%~dp0..\.."
dotnet build
if %errorlevel% neq 0 (
    echo Build failed!
    pause
    exit /b 1
)

echo.
echo [2/3] Database is ready (using existing SparkleEcommerce database)
echo Connection: Server=.\SQLEXPRESS;Database=SparkleEcommerce
echo.

echo [3/3] Starting the application...
echo.
echo ================================================
echo IMPORTANT: The application will start now
echo Wait 5-10 seconds, then open browser to:
echo http://localhost:5279
echo ================================================
echo.

cd "Sparkle.Api"
dotnet watch run

pause
