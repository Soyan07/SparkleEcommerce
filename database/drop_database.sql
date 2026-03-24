-- Drop SparkleEcommerce database
USE master;
GO

IF EXISTS(SELECT * FROM sys.databases WHERE name='SparkleEcommerce')
BEGIN
    ALTER DATABASE SparkleEcommerce SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE SparkleEcommerce;
    PRINT 'Database SparkleEcommerce dropped successfully';
END
ELSE
BEGIN
    PRINT 'Database SparkleEcommerce does not exist';
END
GO
