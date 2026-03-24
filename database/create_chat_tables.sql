-- =====================================================
-- Sparkle Ecommerce Chat System Schema
-- Creates support schema and chat tables
-- =====================================================

USE [SparkleEcommerce];
GO

-- Create support schema if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'support')
BEGIN
    EXEC('CREATE SCHEMA support');
    PRINT 'Created schema: support';
END
ELSE
BEGIN
    PRINT 'Schema support already exists';
END
GO

-- Create Chats table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[support].[Chats]') AND type in (N'U'))
BEGIN
    CREATE TABLE [support].[Chats] (
        [Id] INT NOT NULL IDENTITY(1,1),
        [UserId] NVARCHAR(450) NOT NULL,
        [SellerId] INT NOT NULL,
        [ProductId] INT NULL,
        [Subject] NVARCHAR(500) NULL,
        [Status] NVARCHAR(50) NOT NULL DEFAULT 'Active',
        [StartedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        [LastMessageAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        [UserUnreadCount] INT NOT NULL DEFAULT 0,
        [SellerUnreadCount] INT NOT NULL DEFAULT 0,
        [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        [UpdatedAt] DATETIME2 NULL,
        [CreatedBy] NVARCHAR(MAX) NULL,
        [UpdatedBy] NVARCHAR(MAX) NULL,
        [IsDeleted] BIT NOT NULL DEFAULT 0,
        [DeletedAt] DATETIME2 NULL,
        CONSTRAINT [PK_Chats] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_Chats_AspNetUsers_UserId] FOREIGN KEY ([UserId]) 
            REFERENCES [dbo].[AspNetUsers] ([Id]) ON DELETE NO ACTION,
        CONSTRAINT [FK_Chats_Sellers_SellerId] FOREIGN KEY ([SellerId]) 
            REFERENCES [sellers].[Sellers] ([Id]) ON DELETE NO ACTION,
        CONSTRAINT [FK_Chats_Products_ProductId] FOREIGN KEY ([ProductId]) 
            REFERENCES [catalog].[Products] ([Id]) ON DELETE SET NULL
    );
    
    PRINT 'Created table: support.Chats';
END
ELSE
BEGIN
    PRINT 'Table support.Chats already exists';
END
GO

-- Create Chats indexes
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Chats_UserId_SellerId' AND object_id = OBJECT_ID('[support].[Chats]'))
BEGIN
    CREATE INDEX [IX_Chats_UserId_SellerId] ON [support].[Chats] ([UserId], [SellerId]);
    PRINT 'Created index: IX_Chats_UserId_SellerId';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Chats_LastMessageAt' AND object_id = OBJECT_ID('[support].[Chats]'))
BEGIN
    CREATE INDEX [IX_Chats_LastMessageAt] ON [support].[Chats] ([LastMessageAt] DESC);
    PRINT 'Created index: IX_Chats_LastMessageAt';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Chats_SellerId' AND object_id = OBJECT_ID('[support].[Chats]'))
BEGIN
    CREATE INDEX [IX_Chats_SellerId] ON [support].[Chats] ([SellerId]);
    PRINT 'Created index: IX_Chats_SellerId';
END
GO

-- Create ChatMessages table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[support].[ChatMessages]') AND type in (N'U'))
BEGIN
    CREATE TABLE [support].[ChatMessages] (
        [Id] INT NOT NULL IDENTITY(1,1),
        [ChatId] INT NOT NULL,
        [SenderId] NVARCHAR(450) NOT NULL,
        [IsSeller] BIT NOT NULL,
        [Content] NVARCHAR(MAX) NOT NULL,
        [MessageType] NVARCHAR(50) NOT NULL DEFAULT 'Text',
        [AttachmentUrl] NVARCHAR(MAX) NULL,
        [AttachmentName] NVARCHAR(MAX) NULL,
        [SentAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        [ReadAt] DATETIME2 NULL,
        [IsRead] BIT NOT NULL DEFAULT 0,
        [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        [UpdatedAt] DATETIME2 NULL,
        [CreatedBy] NVARCHAR(MAX) NULL,
        [UpdatedBy] NVARCHAR(MAX) NULL,
        [IsDeleted] BIT NOT NULL DEFAULT 0,
        [DeletedAt] DATETIME2 NULL,
        CONSTRAINT [PK_ChatMessages] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_ChatMessages_Chats_ChatId] FOREIGN KEY ([ChatId]) 
            REFERENCES [support].[Chats] ([Id]) ON DELETE CASCADE,
        CONSTRAINT [FK_ChatMessages_AspNetUsers_SenderId] FOREIGN KEY ([SenderId]) 
            REFERENCES [dbo].[AspNetUsers] ([Id]) ON DELETE NO ACTION
    );
    
    PRINT 'Created table: support.ChatMessages';
END
ELSE
BEGIN
    PRINT 'Table support.ChatMessages already exists';
END
GO

-- Create ChatMessages indexes
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ChatMessages_ChatId' AND object_id = OBJECT_ID('[support].[ChatMessages]'))
BEGIN
    CREATE INDEX [IX_ChatMessages_ChatId] ON [support].[ChatMessages] ([ChatId]);
    PRINT 'Created index: IX_ChatMessages_ChatId';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ChatMessages_SentAt' AND object_id = OBJECT_ID('[support].[ChatMessages]'))
BEGIN
    CREATE INDEX [IX_ChatMessages_SentAt] ON [support].[ChatMessages] ([SentAt] DESC);
    PRINT 'Created index: IX_ChatMessages_SentAt';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ChatMessages_SenderId' AND object_id = OBJECT_ID('[support].[ChatMessages]'))
BEGIN
    CREATE INDEX [IX_ChatMessages_SenderId] ON [support].[ChatMessages] ([SenderId]);
    PRINT 'Created index: IX_ChatMessages_SenderId';
END
GO

PRINT '';
PRINT '✓ Chat system schema created successfully!';
PRINT '✓ Tables: support.Chats, support.ChatMessages';
PRINT '✓ All indexes and foreign keys configured';
GO
