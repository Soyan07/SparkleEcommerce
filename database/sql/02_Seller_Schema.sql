-- =====================================================
-- SELLER SCHEMA - All Vendor/Seller Tables
-- Database: SparkleEcommerce
-- Single clean file - NO duplicates
-- =====================================================

USE SparkleEcommerce;
GO

-- Seller Wallets
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'wallets')
    EXEC('CREATE SCHEMA wallets');
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SellerWallets' AND schema_id = SCHEMA_ID('wallets'))
BEGIN
    CREATE TABLE wallets.SellerWallets (
        Id INT PRIMARY KEY IDENTITY(1,1),
        SellerId INT NOT NULL,
        AvailableBalance DECIMAL(18,2) NOT NULL DEFAULT 0,
        PendingBalance DECIMAL(18,2) NOT NULL DEFAULT 0,
        TotalEarnings DECIMAL(18,2) NOT NULL DEFAULT 0,
        TotalWithdrawn DECIMAL(18,2) NOT NULL DEFAULT 0,
        Currency NVARCHAR(3) NOT NULL DEFAULT 'BDT',
        IsActive BIT NOT NULL DEFAULT 1,
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT FK_SellerWallets_Sellers FOREIGN KEY (SellerId) REFERENCES Sellers(Id)
    );
END
GO

-- Withdrawal Requests
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'WithdrawalRequests' AND schema_id = SCHEMA_ID('wallets'))
BEGIN
    CREATE TABLE wallets.WithdrawalRequests (
        Id INT PRIMARY KEY IDENTITY(1,1),
        SellerId INT NOT NULL,
        Amount DECIMAL(18,2) NOT NULL,
        Status NVARCHAR(50) NOT NULL DEFAULT 'Pending',
        BankName NVARCHAR(200) NOT NULL,
        AccountNumber NVARCHAR(50) NOT NULL,
        AccountHolderName NVARCHAR(200) NOT NULL,
        BranchName NVARCHAR(200) NULL,
        RoutingNumber NVARCHAR(50) NULL,
        ProcessedBy NVARCHAR(450) NULL,
        ProcessedAt DATETIME2 NULL,
        RejectionReason NVARCHAR(500) NULL,
        TransactionReference NVARCHAR(100) NULL,
        RequestDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT FK_WithdrawalRequests_Sellers FOREIGN KEY (SellerId) REFERENCES Sellers(Id)
    );
END
GO

PRINT '✅ Seller schema complete!';
