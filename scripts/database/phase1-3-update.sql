-- Phase 1-3 Schema Updates
-- Run this script to add missing columns and tables

-- Create schemas if not exists
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'catalog') EXEC('CREATE SCHEMA catalog');
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'sellers') EXEC('CREATE SCHEMA sellers');
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'orders') EXEC('CREATE SCHEMA orders');
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'logistics') EXEC('CREATE SCHEMA logistics');
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'support') EXEC('CREATE SCHEMA support');
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'wallets') EXEC('CREATE SCHEMA wallets');
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'system') EXEC('CREATE SCHEMA [system]');
GO

-- 1. Add AdminSubRole to AspNetUsers if not exists

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'AspNetUsers' AND COLUMN_NAME = 'AdminSubRole')
    ALTER TABLE AspNetUsers ADD AdminSubRole INT NULL;

-- 2. Add moderation fields to Products if not exists
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'catalog' AND TABLE_NAME = 'Products' AND COLUMN_NAME = 'ModerationStatus')
    ALTER TABLE catalog.Products ADD ModerationStatus INT NOT NULL DEFAULT 1;

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'catalog' AND TABLE_NAME = 'Products' AND COLUMN_NAME = 'ModerationNotes')
    ALTER TABLE catalog.Products ADD ModerationNotes NVARCHAR(MAX) NULL;

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'catalog' AND TABLE_NAME = 'Products' AND COLUMN_NAME = 'ModeratedAt')
    ALTER TABLE catalog.Products ADD ModeratedAt DATETIME2 NULL;

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'catalog' AND TABLE_NAME = 'Products' AND COLUMN_NAME = 'ModeratedBy')
    ALTER TABLE catalog.Products ADD ModeratedBy NVARCHAR(256) NULL;

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'catalog' AND TABLE_NAME = 'Products' AND COLUMN_NAME = 'DeliveryTypeEligibility')
    ALTER TABLE catalog.Products ADD DeliveryTypeEligibility NVARCHAR(MAX) NULL;

-- 3. Add Seller Type fields if not exists
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'sellers' AND TABLE_NAME = 'Sellers' AND COLUMN_NAME = 'Type')
    ALTER TABLE sellers.Sellers ADD [Type] INT NOT NULL DEFAULT 0;

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'sellers' AND TABLE_NAME = 'Sellers' AND COLUMN_NAME = 'NearestHubId')
    ALTER TABLE sellers.Sellers ADD NearestHubId INT NULL;

-- 4. Add DeliveryMode to Orders if not exists
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'orders' AND TABLE_NAME = 'Orders' AND COLUMN_NAME = 'DeliveryMode')
    ALTER TABLE orders.Orders ADD DeliveryMode INT NOT NULL DEFAULT 0;

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'orders' AND TABLE_NAME = 'Orders' AND COLUMN_NAME = 'AssignedHubId')
    ALTER TABLE orders.Orders ADD AssignedHubId INT NULL;

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'orders' AND TABLE_NAME = 'Orders' AND COLUMN_NAME = 'PickupRiderId')
    ALTER TABLE orders.Orders ADD PickupRiderId INT NULL;

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'orders' AND TABLE_NAME = 'Orders' AND COLUMN_NAME = 'DeliveryRiderId')
    ALTER TABLE orders.Orders ADD DeliveryRiderId INT NULL;

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'orders' AND TABLE_NAME = 'Orders' AND COLUMN_NAME = 'DeliveryAttempts')
    ALTER TABLE orders.Orders ADD DeliveryAttempts INT NOT NULL DEFAULT 0;

-- 5. Create logistics schema if not exists
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'logistics')
    EXEC('CREATE SCHEMA logistics');

-- 6. Create Hubs table if not exists
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'logistics' AND TABLE_NAME = 'Hubs')
BEGIN
    CREATE TABLE logistics.Hubs (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        HubCode NVARCHAR(50) NOT NULL,
        Name NVARCHAR(200) NOT NULL,
        [Type] INT NOT NULL,
        [Address] NVARCHAR(500) NOT NULL,
        Area NVARCHAR(100) NOT NULL,
        District NVARCHAR(100) NOT NULL,
        Division NVARCHAR(100) NOT NULL,
        PostalCode NVARCHAR(20) NULL,
        Latitude FLOAT NULL,
        Longitude FLOAT NULL,
        Capacity INT NOT NULL DEFAULT 1000,
        CurrentInventory INT NOT NULL DEFAULT 0,
        OperationalStatus INT NOT NULL DEFAULT 0,
        ContactPhone NVARCHAR(20) NULL,
        ContactEmail NVARCHAR(100) NULL,
        ManagerName NVARCHAR(100) NULL,
        ManagerPhone NVARCHAR(20) NULL,
        OperatingHours NVARCHAR(MAX) NULL,
        ServiceAreas NVARCHAR(MAX) NULL,
        ParentHubId INT NULL,
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        UpdatedAt DATETIME2 NULL,
        CreatedBy NVARCHAR(256) NULL,
        UpdatedBy NVARCHAR(256) NULL,
        IsDeleted BIT NOT NULL DEFAULT 0,
        DeletedAt DATETIME2 NULL
    );
    CREATE UNIQUE INDEX IX_Hubs_HubCode ON logistics.Hubs(HubCode);
END;

-- 7. Create Riders table if not exists
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'logistics' AND TABLE_NAME = 'Riders')
BEGIN
    CREATE TABLE logistics.Riders (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        RiderCode NVARCHAR(50) NOT NULL,
        Name NVARCHAR(200) NOT NULL,
        Phone NVARCHAR(20) NOT NULL,
        Email NVARCHAR(100) NULL,
        NidNumber NVARCHAR(50) NULL,
        VehicleType NVARCHAR(50) NULL,
        VehicleNumber NVARCHAR(50) NULL,
        AssignedHubId INT NULL,
        [Type] INT NOT NULL DEFAULT 0,
        [Status] INT NOT NULL DEFAULT 0,
        CurrentLatitude FLOAT NULL,
        CurrentLongitude FLOAT NULL,
        LastLocationUpdate DATETIME2 NULL,
        TotalDeliveries INT NOT NULL DEFAULT 0,
        SuccessfulDeliveries INT NOT NULL DEFAULT 0,
        Rating DECIMAL(18,2) NOT NULL DEFAULT 5.0,
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        UpdatedAt DATETIME2 NULL,
        CreatedBy NVARCHAR(256) NULL,
        UpdatedBy NVARCHAR(256) NULL,
        IsDeleted BIT NOT NULL DEFAULT 0,
        DeletedAt DATETIME2 NULL
    );
    CREATE UNIQUE INDEX IX_Riders_RiderCode ON logistics.Riders(RiderCode);
END;

-- 8. Create HubInventory table if not exists
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'logistics' AND TABLE_NAME = 'HubInventory')
BEGIN
    CREATE TABLE logistics.HubInventory (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        HubId INT NOT NULL,
        OrderId INT NOT NULL,
        [Status] NVARCHAR(50) NOT NULL,
        BarcodeScanned NVARCHAR(100) NULL,
        QCPassed BIT NOT NULL DEFAULT 0,
        QCNotes NVARCHAR(500) NULL,
        QCPerformedBy NVARCHAR(256) NULL,
        QCPerformedAt DATETIME2 NULL,
        ReceivedAt DATETIME2 NOT NULL,
        SortedAt DATETIME2 NULL,
        DispatchedAt DATETIME2 NULL,
        DispatchedTo NVARCHAR(256) NULL,
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        UpdatedAt DATETIME2 NULL,
        CreatedBy NVARCHAR(256) NULL,
        UpdatedBy NVARCHAR(256) NULL,
        IsDeleted BIT NOT NULL DEFAULT 0,
        DeletedAt DATETIME2 NULL
    );
END;

-- 9. Create PickupRequests table if not exists
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'logistics' AND TABLE_NAME = 'PickupRequests')
BEGIN
    CREATE TABLE logistics.PickupRequests (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        PickupNumber NVARCHAR(50) NOT NULL,
        OrderId INT NOT NULL,
        SellerId INT NOT NULL,
        AssignedRiderId INT NULL,
        DestinationHubId INT NULL,
        [Status] INT NOT NULL DEFAULT 0,
        ScheduledAt DATETIME2 NOT NULL,
        AssignedAt DATETIME2 NULL,
        PickedUpAt DATETIME2 NULL,
        DeliveredToHubAt DATETIME2 NULL,
        PickupAddress NVARCHAR(500) NOT NULL,
        PickupPhone NVARCHAR(20) NOT NULL,
        PickupLatitude FLOAT NULL,
        PickupLongitude FLOAT NULL,
        AttemptCount INT NOT NULL DEFAULT 0,
        FailureReason NVARCHAR(500) NULL,
        NextAttemptAt DATETIME2 NULL,
        Notes NVARCHAR(MAX) NULL,
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        UpdatedAt DATETIME2 NULL,
        CreatedBy NVARCHAR(256) NULL,
        UpdatedBy NVARCHAR(256) NULL,
        IsDeleted BIT NOT NULL DEFAULT 0,
        DeletedAt DATETIME2 NULL
    );
    CREATE UNIQUE INDEX IX_PickupRequests_PickupNumber ON logistics.PickupRequests(PickupNumber);
END;

-- 10. Create DeliveryAssignments table if not exists
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'logistics' AND TABLE_NAME = 'DeliveryAssignments')
BEGIN
    CREATE TABLE logistics.DeliveryAssignments (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        DeliveryNumber NVARCHAR(50) NOT NULL,
        OrderId INT NOT NULL,
        RiderId INT NOT NULL,
        SourceHubId INT NULL,
        [Status] INT NOT NULL DEFAULT 0,
        AssignedAt DATETIME2 NOT NULL,
        PickedFromHubAt DATETIME2 NULL,
        DeliveredAt DATETIME2 NULL,
        AttemptCount INT NOT NULL DEFAULT 0,
        FailureReason NVARCHAR(500) NULL,
        NextAttemptAt DATETIME2 NULL,
        DeliveryPhoto NVARCHAR(500) NULL,
        ReceiverName NVARCHAR(200) NULL,
        ReceiverRelation NVARCHAR(100) NULL,
        Signature NVARCHAR(MAX) NULL,
        CodAmount DECIMAL(18,2) NULL,
        CodCollected BIT NOT NULL DEFAULT 0,
        Notes NVARCHAR(MAX) NULL,
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        UpdatedAt DATETIME2 NULL,
        CreatedBy NVARCHAR(256) NULL,
        UpdatedBy NVARCHAR(256) NULL,
        IsDeleted BIT NOT NULL DEFAULT 0,
        DeletedAt DATETIME2 NULL
    );
    CREATE UNIQUE INDEX IX_DeliveryAssignments_DeliveryNumber ON logistics.DeliveryAssignments(DeliveryNumber);
END;

-- 11. Create AuditLogs table if not exists
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'system' AND TABLE_NAME = 'AuditLogs')
BEGIN
    CREATE TABLE [system].AuditLogs (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        UserId NVARCHAR(256) NOT NULL,
        UserRole NVARCHAR(50) NOT NULL,
        AdminSubRole INT NULL,
        [Action] NVARCHAR(100) NOT NULL,
        EntityType NVARCHAR(100) NOT NULL,
        EntityId NVARCHAR(100) NULL,
        OldValues NVARCHAR(MAX) NULL,
        NewValues NVARCHAR(MAX) NULL,
        IpAddress NVARCHAR(50) NULL,
        UserAgent NVARCHAR(500) NULL,
        AdditionalData NVARCHAR(MAX) NULL,
        [Timestamp] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        UpdatedAt DATETIME2 NULL,
        CreatedBy NVARCHAR(256) NULL,
        UpdatedBy NVARCHAR(256) NULL,
        IsDeleted BIT NOT NULL DEFAULT 0,
        DeletedAt DATETIME2 NULL
    );
END;

-- 12. Create Disputes table if not exists
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'support' AND TABLE_NAME = 'Disputes')
BEGIN
    CREATE TABLE support.Disputes (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        DisputeNumber NVARCHAR(50) NOT NULL,
        OrderId INT NOT NULL,
        OrderItemId INT NULL,
        UserId NVARCHAR(450) NOT NULL,
        SellerId INT NULL,
        [Type] INT NOT NULL,
        [Status] INT NOT NULL DEFAULT 0,
        [Subject] NVARCHAR(500) NOT NULL,
        [Description] NVARCHAR(MAX) NOT NULL,
        Evidence NVARCHAR(MAX) NULL,
        SellerResponse NVARCHAR(MAX) NULL,
        SellerEvidence NVARCHAR(MAX) NULL,
        AssignedTo NVARCHAR(256) NULL,
        AssignedAt DATETIME2 NULL,
        ResolutionType INT NOT NULL DEFAULT 0,
        ResolutionDetails NVARCHAR(MAX) NULL,
        RefundAmount DECIMAL(18,2) NULL,
        ResolvedAt DATETIME2 NULL,
        ResolvedBy NVARCHAR(256) NULL,
        IsEscalated BIT NOT NULL DEFAULT 0,
        EscalationReason NVARCHAR(500) NULL,
        EscalatedAt DATETIME2 NULL,
        [Priority] NVARCHAR(20) NOT NULL DEFAULT 'Medium',
        OpenedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        ClosedAt DATETIME2 NULL,
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        UpdatedAt DATETIME2 NULL,
        CreatedBy NVARCHAR(256) NULL,
        UpdatedBy NVARCHAR(256) NULL,
        IsDeleted BIT NOT NULL DEFAULT 0,
        DeletedAt DATETIME2 NULL
    );
    CREATE UNIQUE INDEX IX_Disputes_DisputeNumber ON support.Disputes(DisputeNumber);
END;

-- 13. Create SellerPenalties table if not exists
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'sellers' AND TABLE_NAME = 'SellerPenalties')
BEGIN
    CREATE TABLE sellers.SellerPenalties (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        SellerId INT NOT NULL,
        OrderId INT NULL,
        DisputeId INT NULL,
        Reason INT NOT NULL,
        [Status] INT NOT NULL DEFAULT 0,
        Amount DECIMAL(18,2) NOT NULL,
        [Description] NVARCHAR(500) NULL,
        AppealReason NVARCHAR(MAX) NULL,
        AppealedAt DATETIME2 NULL,
        AppealDecision NVARCHAR(500) NULL,
        AppealDecidedAt DATETIME2 NULL,
        IsDeducted BIT NOT NULL DEFAULT 0,
        DeductedAt DATETIME2 NULL,
        DeductedFromPayoutId INT NULL,
        AppliedBy NVARCHAR(256) NULL,
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        UpdatedAt DATETIME2 NULL,
        CreatedBy NVARCHAR(256) NULL,
        UpdatedBy NVARCHAR(256) NULL,
        IsDeleted BIT NOT NULL DEFAULT 0,
        DeletedAt DATETIME2 NULL
    );
END;

-- 14. Create LedgerEntries table if not exists
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'wallets' AND TABLE_NAME = 'LedgerEntries')
BEGIN
    CREATE TABLE wallets.LedgerEntries (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        EntryNumber NVARCHAR(50) NOT NULL,
        OrderId INT NULL,
        SellerId INT NULL,
        UserId NVARCHAR(256) NULL,
        EntryType INT NOT NULL,
        TransactionType NVARCHAR(20) NOT NULL DEFAULT 'Credit',
        Amount DECIMAL(18,2) NOT NULL,
        BalanceBefore DECIMAL(18,2) NOT NULL,
        BalanceAfter DECIMAL(18,2) NOT NULL,
        Reference NVARCHAR(200) NULL,
        [Description] NVARCHAR(500) NULL,
        IsEscrowHeld BIT NOT NULL DEFAULT 0,
        EscrowReleasedAt DATETIME2 NULL,
        EntryDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        UpdatedAt DATETIME2 NULL,
        CreatedBy NVARCHAR(256) NULL,
        UpdatedBy NVARCHAR(256) NULL,
        IsDeleted BIT NOT NULL DEFAULT 0,
        DeletedAt DATETIME2 NULL
    );
END;

PRINT 'Schema update completed successfully!';
