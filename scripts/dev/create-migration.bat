@echo off
REM ============================================
REM Sparkle E-Commerce - Database Migration Script
REM ============================================
REM This script creates and applies EF Core migrations.
REM 
REM IMPORTANT: Stop 'dotnet watch run' before running this script!
REM
REM Usage:
REM   1. Stop any running dotnet watch processes
REM   2. Run: .\create-migration.bat
REM ============================================

cd /d "%~dp0..\.."

echo.
echo ================================
echo Sparkle Database Migration Tool
echo ================================
echo.

REM Check if dotnet watch is running
tasklist /FI "IMAGENAME eq dotnet.exe" 2>NUL | find /I /N "dotnet.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo [WARNING] dotnet.exe is running. 
    echo Please stop 'dotnet watch run' first, then run this script again.
    echo.
    pause
    exit /b 1
)

REM Temporarily rename Directory.Build.props to bypass custom paths
echo [1/5] Preparing project configuration...
if exist "Directory.Build.props" (
    rename "Directory.Build.props" "Directory.Build.props.bak"
)

REM Restore packages
echo [2/5] Restoring packages...
dotnet restore --no-cache

REM Create migration
echo [3/5] Creating database migration...
dotnet ef migrations add Phase1To3Entities --project Sparkle.Infrastructure --startup-project Sparkle.Api

REM Restore Directory.Build.props
echo [4/5] Restoring project configuration...
if exist "Directory.Build.props.bak" (
    rename "Directory.Build.props.bak" "Directory.Build.props"
)
dotnet restore

REM Ask user if they want to apply the migration
echo.
set /p APPLY="[5/5] Apply migration to database? (Y/N): "
if /I "%APPLY%"=="Y" (
    echo Applying migration...
    dotnet ef database update --project Sparkle.Infrastructure --startup-project Sparkle.Api
    echo.
    echo [SUCCESS] Migration applied!
) else (
    echo.
    echo [INFO] Migration created but NOT applied.
    echo Run 'dotnet ef database update --project Sparkle.Infrastructure --startup-project Sparkle.Api' when ready.
)

echo.
echo Done!
pause
