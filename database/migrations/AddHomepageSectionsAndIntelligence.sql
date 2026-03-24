-- =====================================================
-- SPARKLE ECOMMERCE: HOMEPAGE SECTIONS & INTELLIGENCE
-- Migration Script for New Features
-- =====================================================
-- This script creates tables for:
-- 1. Homepage Section Management (manual and automated)
-- 2. User Behavior Analytics
-- 3. Intelligent Product Analysis & Recommendations
-- 4. Sales Metrics Snapshots
-- =====================================================

-- Create Content Schema
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'content')
BEGIN
    EXEC sp_executesql N'CREATE SCHEMA content'
END
GO

-- =====================================================
-- HOMEPAGE SECTIONS TABLE
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[content].[HomepageSections]') AND type in (N'U'))
BEGIN
    CREATE TABLE [content].[HomepageSections] (
        [Id] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
        [Name] NVARCHAR(255) NOT NULL,
        [Slug] NVARCHAR(255) NOT NULL UNIQUE,
        [DisplayTitle] NVARCHAR(255) NOT NULL,
        [Description] NVARCHAR(MAX) NULL,
        [SectionType] NVARCHAR(50) NOT NULL, -- CategoryShop, TrendingProducts, FlashSale, RecommendedProducts
        [BackgroundColor] NVARCHAR(20) NULL,
        [BannerImageUrl] NVARCHAR(500) NULL,
        [DisplayOrder] INT NOT NULL DEFAULT 0,
        [IsActive] BIT NOT NULL DEFAULT 1,
        [MaxProductsToDisplay] INT NOT NULL DEFAULT 12,
        [ProductsPerRow] INT NOT NULL DEFAULT 4,
        [LayoutType] NVARCHAR(50) NOT NULL DEFAULT 'Grid', -- Grid, Carousel, List
        [CardSize] NVARCHAR(50) NOT NULL DEFAULT 'Medium', -- Small, Medium, Large
        [UseAutomatedSelection] BIT NOT NULL DEFAULT 1,
        [UseManualSelection] BIT NOT NULL DEFAULT 0,
        [ShowRating] BIT NOT NULL DEFAULT 1,
        [ShowPrice] BIT NOT NULL DEFAULT 1,
        [ShowDiscount] BIT NOT NULL DEFAULT 1,
        [LastAutomationRunTime] DATETIME2 NULL,
        [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        [UpdatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        [CreatedByUserId] NVARCHAR(450) NULL,
        CONSTRAINT [FK_HomepageSections_User] FOREIGN KEY([CreatedByUserId]) REFERENCES [dbo].[AspNetUsers]([Id]) ON DELETE SET NULL
    )
    
    -- Indexes for performance
    CREATE INDEX [IX_HomepageSections_Slug] ON [content].[HomepageSections]([Slug])
    CREATE INDEX [IX_HomepageSections_IsActive_DisplayOrder] ON [content].[HomepageSections]([IsActive], [DisplayOrder])
    CREATE INDEX [IX_HomepageSections_SectionType] ON [content].[HomepageSections]([SectionType])
    
    PRINT 'Created [content].[HomepageSections] table'
END
GO

-- =====================================================
-- HOMEPAGE SECTION PRODUCTS TABLE
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[content].[HomepageSectionProducts]') AND type in (N'U'))
BEGIN
    CREATE TABLE [content].[HomepageSectionProducts] (
        [Id] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
        [SectionId] INT NOT NULL,
        [ProductId] INT NOT NULL,
        [DisplayOrder] INT NOT NULL,
        [PromotionalText] NVARCHAR(255) NULL,
        [BadgeText] NVARCHAR(50) NULL, -- New, Best Seller, Limited, etc.
        [IsActive] BIT NOT NULL DEFAULT 1,
        [AddedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT [FK_HomepageSectionProducts_Section] FOREIGN KEY([SectionId]) REFERENCES [content].[HomepageSections]([Id]) ON DELETE CASCADE,
        CONSTRAINT [FK_HomepageSectionProducts_Product] FOREIGN KEY([ProductId]) REFERENCES [catalog].[Products]([Id]) ON DELETE RESTRICT
    )
    
    -- Indexes
    CREATE INDEX [IX_HomepageSectionProducts_SectionId_IsActive] ON [content].[HomepageSectionProducts]([SectionId], [IsActive])
    CREATE INDEX [IX_HomepageSectionProducts_ProductId] ON [content].[HomepageSectionProducts]([ProductId])
    CREATE UNIQUE INDEX [IX_HomepageSectionProducts_SectionProduct] ON [content].[HomepageSectionProducts]([SectionId], [ProductId])
    
    PRINT 'Created [content].[HomepageSectionProducts] table'
END
GO

-- =====================================================
-- HOMEPAGE SECTION CATEGORIES TABLE
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[content].[HomepageSectionCategories]') AND type in (N'U'))
BEGIN
    CREATE TABLE [content].[HomepageSectionCategories] (
        [Id] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
        [SectionId] INT NOT NULL,
        [CategoryId] INT NOT NULL,
        [DisplayOrder] INT NOT NULL,
        [CustomDisplayTitle] NVARCHAR(255) NULL,
        [ProductCountToShow] INT NOT NULL DEFAULT 6,
        [IsActive] BIT NOT NULL DEFAULT 1,
        CONSTRAINT [FK_HomepageSectionCategories_Section] FOREIGN KEY([SectionId]) REFERENCES [content].[HomepageSections]([Id]) ON DELETE CASCADE,
        CONSTRAINT [FK_HomepageSectionCategories_Category] FOREIGN KEY([CategoryId]) REFERENCES [catalog].[Categories]([Id]) ON DELETE RESTRICT
    )
    
    -- Indexes
    CREATE INDEX [IX_HomepageSectionCategories_SectionId] ON [content].[HomepageSectionCategories]([SectionId])
    CREATE INDEX [IX_HomepageSectionCategories_CategoryId] ON [content].[HomepageSectionCategories]([CategoryId])
    CREATE UNIQUE INDEX [IX_HomepageSectionCategories_SectionCategory] ON [content].[HomepageSectionCategories]([SectionId], [CategoryId])
    
    PRINT 'Created [content].[HomepageSectionCategories] table'
END
GO

-- =====================================================
-- TRENDING PRODUCT SUGGESTIONS TABLE
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[content].[TrendingProductSuggestions]') AND type in (N'U'))
BEGIN
    CREATE TABLE [content].[TrendingProductSuggestions] (
        [Id] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
        [ProductId] INT NOT NULL,
        [ConfidenceScore] DECIMAL(5,2) NOT NULL, -- 0-100
        [SalesCount] INT NOT NULL,
        [ViewCount] INT NOT NULL,
        [WishlistCount] INT NOT NULL,
        [AverageRating] DECIMAL(3,2) NOT NULL,
        [SalesGrowthRate] DECIMAL(8,2) NOT NULL, -- Percentage
        [CalculatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        [ExpiresAt] DATETIME2 NOT NULL,
        [IsActive] BIT NOT NULL DEFAULT 1,
        [AnalysisPeriod] NVARCHAR(50) NOT NULL DEFAULT 'Last30Days',
        [Rank] INT NOT NULL DEFAULT 0,
        CONSTRAINT [FK_TrendingProductSuggestions_Product] FOREIGN KEY([ProductId]) REFERENCES [catalog].[Products]([Id]) ON DELETE RESTRICT
    )
    
    -- Indexes for performance
    CREATE INDEX [IX_TrendingProductSuggestions_ProductId_CalculatedAt] ON [content].[TrendingProductSuggestions]([ProductId], [CalculatedAt])
    CREATE INDEX [IX_TrendingProductSuggestions_IsActive_ExpiresAt] ON [content].[TrendingProductSuggestions]([IsActive], [ExpiresAt])
    CREATE INDEX [IX_TrendingProductSuggestions_Rank] ON [content].[TrendingProductSuggestions]([Rank]) WHERE [IsActive] = 1
    CREATE INDEX [IX_TrendingProductSuggestions_ConfidenceScore] ON [content].[TrendingProductSuggestions]([ConfidenceScore]) WHERE [IsActive] = 1
    
    PRINT 'Created [content].[TrendingProductSuggestions] table'
END
GO

-- =====================================================
-- FLASH SALE PRODUCT SUGGESTIONS TABLE
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[content].[FlashSaleProductSuggestions]') AND type in (N'U'))
BEGIN
    CREATE TABLE [content].[FlashSaleProductSuggestions] (
        [Id] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
        [ProductId] INT NOT NULL,
        [SuggestedDiscountPercentage] DECIMAL(5,2) NOT NULL,
        [SuggestedFlashPrice] DECIMAL(18,2) NOT NULL,
        [SuggestionReason] NVARCHAR(255) NOT NULL,
        [CurrentInventory] INT NOT NULL,
        [RecommendedQuantityForFlash] INT NOT NULL,
        [ExpectedSalesBoost] DECIMAL(8,2) NOT NULL, -- Percentage
        [EstimatedRevenueLift] DECIMAL(18,2) NOT NULL,
        [CalculatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        [ExpiresAt] DATETIME2 NOT NULL,
        [IsActive] BIT NOT NULL DEFAULT 1,
        [PriorityScore] DECIMAL(8,2) NOT NULL,
        CONSTRAINT [FK_FlashSaleProductSuggestions_Product] FOREIGN KEY([ProductId]) REFERENCES [catalog].[Products]([Id]) ON DELETE RESTRICT
    )
    
    -- Indexes
    CREATE INDEX [IX_FlashSaleProductSuggestions_ProductId_CalculatedAt] ON [content].[FlashSaleProductSuggestions]([ProductId], [CalculatedAt])
    CREATE INDEX [IX_FlashSaleProductSuggestions_IsActive_ExpiresAt] ON [content].[FlashSaleProductSuggestions]([IsActive], [ExpiresAt])
    CREATE INDEX [IX_FlashSaleProductSuggestions_PriorityScore] ON [content].[FlashSaleProductSuggestions]([PriorityScore]) WHERE [IsActive] = 1
    
    PRINT 'Created [content].[FlashSaleProductSuggestions] table'
END
GO

-- =====================================================
-- USER BEHAVIOR ANALYTICS TABLE
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[content].[UserBehaviorAnalytics]') AND type in (N'U'))
BEGIN
    CREATE TABLE [content].[UserBehaviorAnalytics] (
        [Id] BIGINT NOT NULL PRIMARY KEY IDENTITY(1,1),
        [UserId] NVARCHAR(450) NOT NULL,
        [ActionType] NVARCHAR(50) NOT NULL, -- ProductView, ProductSearch, AddToCart, AddToWishlist, Purchase
        [ProductId] INT NULL,
        [CategoryId] INT NULL,
        [SearchTerm] NVARCHAR(255) NULL,
        [TimeSpentSeconds] INT NULL,
        [DeviceType] NVARCHAR(50) NULL, -- Mobile, Tablet, Desktop
        [SessionId] NVARCHAR(450) NULL,
        [ActionDateTime] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        [IpAddress] NVARCHAR(50) NULL,
        [UserAgent] NVARCHAR(500) NULL,
        CONSTRAINT [FK_UserBehaviorAnalytics_User] FOREIGN KEY([UserId]) REFERENCES [dbo].[AspNetUsers]([Id]) ON DELETE RESTRICT,
        CONSTRAINT [FK_UserBehaviorAnalytics_Product] FOREIGN KEY([ProductId]) REFERENCES [catalog].[Products]([Id]) ON DELETE SET NULL,
        CONSTRAINT [FK_UserBehaviorAnalytics_Category] FOREIGN KEY([CategoryId]) REFERENCES [catalog].[Categories]([Id]) ON DELETE SET NULL
    )
    
    -- Indexes for fast analysis queries
    CREATE INDEX [IX_UserBehaviorAnalytics_UserId_ActionDateTime] ON [content].[UserBehaviorAnalytics]([UserId], [ActionDateTime])
    CREATE INDEX [IX_UserBehaviorAnalytics_ProductId_ActionDateTime] ON [content].[UserBehaviorAnalytics]([ProductId], [ActionDateTime])
    CREATE INDEX [IX_UserBehaviorAnalytics_ActionType_DateTime] ON [content].[UserBehaviorAnalytics]([ActionType], [ActionDateTime])
    CREATE INDEX [IX_UserBehaviorAnalytics_SearchTerm] ON [content].[UserBehaviorAnalytics]([SearchTerm]) WHERE [ActionType] = 'ProductSearch'
    
    PRINT 'Created [content].[UserBehaviorAnalytics] table'
END
GO

-- =====================================================
-- SALES METRICS SNAPSHOTS TABLE
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[content].[SalesMetricsSnapshots]') AND type in (N'U'))
BEGIN
    CREATE TABLE [content].[SalesMetricsSnapshots] (
        [Id] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
        [ProductId] INT NOT NULL,
        [TotalSales] INT NOT NULL,
        [TotalRevenue] DECIMAL(18,2) NOT NULL,
        [AverageSellingPrice] DECIMAL(18,2) NOT NULL,
        [UniqueBuyers] INT NOT NULL,
        [PageViews] INT NOT NULL,
        [SearchImpressions] INT NOT NULL,
        [ClickThroughRate] DECIMAL(8,2) NOT NULL, -- Percentage
        [ConversionRate] DECIMAL(8,2) NOT NULL, -- Percentage
        [AverageRating] DECIMAL(3,2) NOT NULL,
        [ReviewCount] INT NOT NULL,
        [ReturnRate] DECIMAL(8,2) NOT NULL, -- Percentage
        [PeriodStartDate] DATETIME2 NOT NULL,
        [PeriodEndDate] DATETIME2 NOT NULL,
        [SalesGrowthRate] DECIMAL(8,2) NOT NULL, -- Percentage
        [SalesTrend] NVARCHAR(50) NOT NULL DEFAULT 'Stable', -- Up, Down, Stable
        [SnapshotDateTime] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT [FK_SalesMetricsSnapshots_Product] FOREIGN KEY([ProductId]) REFERENCES [catalog].[Products]([Id]) ON DELETE RESTRICT
    )
    
    -- Indexes
    CREATE INDEX [IX_SalesMetricsSnapshots_ProductId_SnapshotDateTime] ON [content].[SalesMetricsSnapshots]([ProductId], [SnapshotDateTime])
    CREATE INDEX [IX_SalesMetricsSnapshots_PeriodDates] ON [content].[SalesMetricsSnapshots]([PeriodStartDate], [PeriodEndDate])
    CREATE INDEX [IX_SalesMetricsSnapshots_SalesTrend] ON [content].[SalesMetricsSnapshots]([SalesTrend])
    
    PRINT 'Created [content].[SalesMetricsSnapshots] table'
END
GO

-- =====================================================
-- HOMEPAGE SECTION AUDIT LOG TABLE
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[content].[HomepageSectionAuditLogs]') AND type in (N'U'))
BEGIN
    CREATE TABLE [content].[HomepageSectionAuditLogs] (
        [Id] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
        [SectionId] INT NOT NULL,
        [ChangeType] NVARCHAR(50) NOT NULL, -- Created, Updated, ProductAdded, ProductRemoved, etc.
        [PropertyName] NVARCHAR(255) NOT NULL,
        [OldValue] NVARCHAR(MAX) NULL,
        [NewValue] NVARCHAR(MAX) NULL,
        [ChangedByUserId] NVARCHAR(450) NULL,
        [ChangedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        [IsAutomatedChange] BIT NOT NULL DEFAULT 0,
        [Notes] NVARCHAR(MAX) NULL,
        CONSTRAINT [FK_HomepageSectionAuditLogs_Section] FOREIGN KEY([SectionId]) REFERENCES [content].[HomepageSections]([Id]) ON DELETE CASCADE,
        CONSTRAINT [FK_HomepageSectionAuditLogs_User] FOREIGN KEY([ChangedByUserId]) REFERENCES [dbo].[AspNetUsers]([Id]) ON DELETE SET NULL
    )
    
    -- Indexes
    CREATE INDEX [IX_HomepageSectionAuditLogs_SectionId_ChangedAt] ON [content].[HomepageSectionAuditLogs]([SectionId], [ChangedAt])
    CREATE INDEX [IX_HomepageSectionAuditLogs_ChangedByUserId] ON [content].[HomepageSectionAuditLogs]([ChangedByUserId])
    CREATE INDEX [IX_HomepageSectionAuditLogs_ChangeType] ON [content].[HomepageSectionAuditLogs]([ChangeType])
    
    PRINT 'Created [content].[HomepageSectionAuditLogs] table'
END
GO

-- =====================================================
-- SAMPLE DATA INITIALIZATION
-- =====================================================

-- Insert default homepage sections (if not exists)
IF NOT EXISTS (SELECT 1 FROM [content].[HomepageSections] WHERE [Slug] = 'shop-by-category')
BEGIN
    INSERT INTO [content].[HomepageSections] 
    ([Name], [Slug], [DisplayTitle], [SectionType], [DisplayOrder], [IsActive], [LayoutType], [CardSize], [ProductsPerRow])
    VALUES 
    ('Shop by Category', 'shop-by-category', 'Shop by Category', 'CategoryShop', 1, 1, 'Grid', 'Medium', 3),
    ('Trending Products', 'trending-products', 'Trending Now', 'TrendingProducts', 2, 1, 'Carousel', 'Medium', 4),
    ('Flash Sales', 'flash-sales', 'Incredible Deals', 'FlashSale', 3, 1, 'Grid', 'Large', 4),
    ('Recommended for You', 'recommended-for-you', 'Just For You', 'RecommendedProducts', 4, 1, 'Carousel', 'Medium', 5)
    
    PRINT 'Inserted default homepage sections'
END
GO

-- =====================================================
-- SUMMARY
-- =====================================================
PRINT '======================================'
PRINT 'Homepage Sections & Intelligence Setup Complete'
PRINT '======================================'
PRINT 'Tables created:'
PRINT '  - content.HomepageSections'
PRINT '  - content.HomepageSectionProducts'
PRINT '  - content.HomepageSectionCategories'
PRINT '  - content.TrendingProductSuggestions'
PRINT '  - content.FlashSaleProductSuggestions'
PRINT '  - content.UserBehaviorAnalytics'
PRINT '  - content.SalesMetricsSnapshots'
PRINT '  - content.HomepageSectionAuditLogs'
PRINT ''
PRINT 'Features enabled:'
PRINT '  ✓ Manual product section management'
PRINT '  ✓ Automated intelligent analysis'
PRINT '  ✓ User behavior tracking'
PRINT '  ✓ Trending product detection'
PRINT '  ✓ Flash sale recommendations'
PRINT '  ✓ Complete audit logging'
PRINT '  ✓ Dynamic layout and card sizing'
PRINT '======================================'
