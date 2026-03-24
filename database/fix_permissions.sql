-- Fix SQL Server database permissions for Windows user
USE master;
GO

-- Create login for current Windows user if not exists
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'DESKTOP-JRGH1SB\User')
BEGIN
    CREATE LOGIN [DESKTOP-JRGH1SB\User] FROM WINDOWS;
    PRINT 'Created login for DESKTOP-JRGH1SB\User';
END
ELSE
    PRINT 'Login already exists';
GO

-- Grant access to SparkleEcommerce database
USE SparkleEcommerce;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'DESKTOP-JRGH1SB\User')
BEGIN
    CREATE USER [DESKTOP-JRGH1SB\User] FOR LOGIN [DESKTOP-JRGH1SB\User];
    PRINT 'Created database user';
END
GO

-- Grant db_owner role
ALTER ROLE db_owner ADD MEMBER [DESKTOP-JRGH1SB\User];
PRINT 'Granted db_owner role';
GO
