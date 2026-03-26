-- Initialize SparkleEcommerce Database
-- This script runs when the SQL Server container starts

-- Wait for SQL Server to be ready
WAITFOR DELAY '00:00:05';

-- Create database if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'SparkleEcommerce')
BEGIN
    CREATE DATABASE [SparkleEcommerce];
    PRINT 'Database [SparkleEcommerce] created successfully.';
END
ELSE
BEGIN
    PRINT 'Database [SparkleEcommerce] already exists.';
END

-- Set as default database for SA user
USE master;
GO
ALTER LOGIN [sa] WITH DEFAULT_DATABASE = [SparkleEcommerce];
PRINT 'Set [SparkleEcommerce] as default database for SA login.';

-- Verify
SELECT name as DatabaseName, state_desc FROM sys.databases WHERE name = 'SparkleEcommerce';
