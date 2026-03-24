-- Migration: Add Unified Feedback Features
-- Date: 2025-12-22
-- Description: Adds admin moderation and seller features to ProductReviews table
--              Creates ReviewEditHistories table for audit trail

USE [SparkleEcommerce]
GO

-- =============================================
-- 1. Add new columns to ProductReviews table
-- =============================================

-- Admin Moderation columns
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('reviews.ProductReviews') AND name = 'AdminNote')
BEGIN
    ALTER TABLE [reviews].[ProductReviews] ADD [AdminNote] NVARCHAR(MAX) NULL;
    PRINT 'Added AdminNote column';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('reviews.ProductReviews') AND name = 'IsAdminNoteVisible')
BEGIN
    ALTER TABLE [reviews].[ProductReviews] ADD [IsAdminNoteVisible] BIT NOT NULL DEFAULT 1;
    PRINT 'Added IsAdminNoteVisible column';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('reviews.ProductReviews') AND name = 'IsLocked')
BEGIN
    ALTER TABLE [reviews].[ProductReviews] ADD [IsLocked] BIT NOT NULL DEFAULT 0;
    PRINT 'Added IsLocked column';
END
GO

-- Seller Feature columns
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('reviews.ProductReviews') AND name = 'IsPinned')
BEGIN
    ALTER TABLE [reviews].[ProductReviews] ADD [IsPinned] BIT NOT NULL DEFAULT 0;
    PRINT 'Added IsPinned column';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('reviews.ProductReviews') AND name = 'LastEditedAt')
BEGIN
    ALTER TABLE [reviews].[ProductReviews] ADD [LastEditedAt] DATETIME2 NULL;
    PRINT 'Added LastEditedAt column';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('reviews.ProductReviews') AND name = 'EditCount')
BEGIN
    ALTER TABLE [reviews].[ProductReviews] ADD [EditCount] INT NOT NULL DEFAULT 0;
    PRINT 'Added EditCount column';
END
GO

-- =============================================
-- 2. Create ReviewEditHistories table
-- =============================================

IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('reviews.ReviewEditHistories') AND type = 'U')
BEGIN
    CREATE TABLE [reviews].[ReviewEditHistories] (
        [Id] INT IDENTITY(1,1) NOT NULL,
        [ProductReviewId] INT NOT NULL,
        [PreviousComment] NVARCHAR(MAX) NULL,
        [NewComment] NVARCHAR(MAX) NULL,
        [PreviousRating] INT NULL,
        [NewRating] INT NULL,
        [EditedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        [EditedBy] NVARCHAR(450) NOT NULL DEFAULT '',
        [EditType] NVARCHAR(50) NOT NULL DEFAULT 'Update',
        CONSTRAINT [PK_ReviewEditHistories] PRIMARY KEY CLUSTERED ([Id]),
        CONSTRAINT [FK_ReviewEditHistories_ProductReviews] FOREIGN KEY ([ProductReviewId]) 
            REFERENCES [reviews].[ProductReviews]([Id]) ON DELETE CASCADE
    );
    
    CREATE INDEX [IX_ReviewEditHistories_ProductReviewId] ON [reviews].[ReviewEditHistories]([ProductReviewId]);
    
    PRINT 'Created ReviewEditHistories table';
END
GO

PRINT 'Migration complete: Unified Feedback Features';
GO
