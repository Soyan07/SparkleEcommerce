-- =====================================================
-- ADMIN SCHEMA - All Administration Tables
-- Database: SparkleEcommerce
-- Single clean file - NO duplicates
-- =====================================================

USE SparkleEcommerce;
GO

-- Wallet Transactions (shared by users and sellers)
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'wallets')
    EXEC('CREATE SCHEMA wallets');
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'WalletTransactions' AND schema_id = SCHEMA_ID('wallets'))
BEGIN
    CREATE TABLE wallets.WalletTransactions (
        Id INT PRIMARY KEY IDENTITY(1,1),
        UserId NVARCHAR(450) NULL,
        SellerId INT NULL,
        TransactionType NVARCHAR(50) NOT NULL,
        Source NVARCHAR(100) NOT NULL,
        Amount DECIMAL(18,2) NOT NULL,
        BalanceBefore DECIMAL(18,2) NOT NULL,
        BalanceAfter DECIMAL(18,2) NOT NULL,
        ReferenceType NVARCHAR(50) NULL,
        ReferenceId NVARCHAR(100) NULL,
        Status NVARCHAR(50) NOT NULL DEFAULT 'Completed',
        Description NVARCHAR(500) NULL,
        TransactionDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE()
    );
END
GO

PRINT '✅ Admin schema complete!';
