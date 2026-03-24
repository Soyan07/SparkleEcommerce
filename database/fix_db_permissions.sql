-- Fix Database Permissions for Sparkle Ecommerce
USE master;
GO

-- Enable the Windows login if not already enabled
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'DESKTOP-JRGH1SB\User')
BEGIN
    CREATE LOGIN [DESKTOP-JRGH1SB\User] FROM WINDOWS;
END
GO

-- Switch to the SparkleEcommerce database
USE SparkleEcommerce;
GO

-- Create user for the login if not exists
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'DESKTOP-JRGH1SB\User')
BEGIN
    CREATE USER [DESKTOP-JRGH1SB\User] FOR LOGIN [DESKTOP-JRGH1SB\User];
END
GO

-- Grant db_owner role to the user
ALTER ROLE db_owner ADD MEMBER [DESKTOP-JRGH1SB\User];
GO

PRINT 'Database permissions fixed successfully!';
GO
