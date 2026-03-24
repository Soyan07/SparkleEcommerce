@echo off
echo ========================================
echo  Sparkle Ecommerce - Database Reset
echo ========================================
echo.
echo This will DROP and RECREATE the database.
echo ALL DATA WILL BE LOST!
echo.
pause

cd "C:\Users\Minhajul Islam\Desktop\Sparkle Ecommerce\Sparkle.Api"

echo.
echo Dropping database...
dotnet ef database drop -f

echo.
echo Applying migrations and seeding...
dotnet run

echo.
echo Done! Database has been reset.
pause
