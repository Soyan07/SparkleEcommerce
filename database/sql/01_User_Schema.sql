-- =====================================================
-- USER SCHEMA - All Customer/Buyer Tables
-- Database: SparkleEcommerce
-- Single clean file - NO duplicates
-- =====================================================

USE SparkleEcommerce;
GO

-- User Wallets
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'wallets')
    EXEC('CREATE SCHEMA wallets');
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'UserWallets' AND schema_id = SCHEMA_ID('wallets'))
BEGIN
    CREATE TABLE wallets.UserWallets (
        Id INT PRIMARY KEY IDENTITY(1,1),
        UserId NVARCHAR(450) NOT NULL,
        Balance DECIMAL(18,2) NOT NULL DEFAULT 0,
        Currency NVARCHAR(3) NOT NULL DEFAULT 'BDT',
        IsActive BIT NOT NULL DEFAULT 1,
        IsLocked BIT NOT NULL DEFAULT 0,
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT FK_UserWallets_Users FOREIGN KEY (UserId) REFERENCES AspNetUsers(Id)
    );
END
GO

PRINT '✅ User schema complete!';
